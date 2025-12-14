#!/usr/bin/env python3
"""
Convert .lines format to PNG image.

Format:
  size width height
  line x1 y1 x2 y2
  line x1 y1 x2 y2
  ...
"""

import sys
from PIL import Image, ImageDraw


def parse_lines_file(filename):
    """Parse a .lines file and return (width, height, lines)."""
    with open(filename, 'r') as f:
        lines = f.readlines()

    if not lines:
        raise ValueError("Empty file")

    # Parse first line: size width height
    first_line = lines[0].strip().split()
    if len(first_line) != 3 or first_line[0] != 'size':
        raise ValueError(f"Expected 'size width height', got '{lines[0].strip()}'")

    width = int(first_line[1])
    height = int(first_line[2])

    # Parse remaining lines: line x1 y1 x2 y2
    line_coords = []
    for line in lines[1:]:
        line = line.strip()
        if not line:
            continue

        parts = line.split()
        if len(parts) != 5 or parts[0] != 'line':
            print(f"Warning: skipping invalid line: {line}", file=sys.stderr)
            continue

        x1, y1, x2, y2 = int(parts[1]), int(parts[2]), int(parts[3]), int(parts[4])
        line_coords.append((x1, y1, x2, y2))

    return width, height, line_coords


def create_png(width, height, lines, output_file):
    """Create a PNG image with the specified lines."""
    # Create white background
    img = Image.new('RGB', (width, height), color='white')
    draw = ImageDraw.Draw(img)

    # Draw black lines
    for x1, y1, x2, y2 in lines:
        draw.line([(x1, y1), (x2, y2)], fill='black', width=1)

    # Save to PNG
    img.save(output_file, 'PNG')
    print(f"Drew {len(lines)} lines")
    print(f"Saved to {output_file}")


def main():
    if len(sys.argv) < 2:
        print("Usage: lines2png.py <input.lines> [output.png]")
        print("Example: lines2png.py www.lines www.png")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) >= 3 else 'output.png'

    try:
        width, height, lines = parse_lines_file(input_file)
        print(f"Creating image: {width}x{height}")
        create_png(width, height, lines, output_file)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
