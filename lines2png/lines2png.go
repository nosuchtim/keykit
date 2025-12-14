package main

import (
	"bufio"
	"fmt"
	"image"
	"image/color"
	"image/png"
	"math"
	"os"
	"strconv"
	"strings"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: lines2png <input.lines> [output.png]")
		fmt.Println("Example: lines2png www.lines www.png")
		os.Exit(1)
	}

	inputFile := os.Args[1]
	outputFile := "output.png"
	if len(os.Args) >= 3 {
		outputFile = os.Args[2]
	}

	// Read and parse the .lines file
	file, err := os.Open(inputFile)
	if err != nil {
		fmt.Printf("Error opening file: %v\n", err)
		os.Exit(1)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	// Read first line for size
	if !scanner.Scan() {
		fmt.Println("Error: empty file")
		os.Exit(1)
	}

	firstLine := scanner.Text()
	fields := strings.Fields(firstLine)
	if len(fields) != 3 || fields[0] != "size" {
		fmt.Printf("Error: expected 'size width height', got '%s'\n", firstLine)
		os.Exit(1)
	}

	width, err := strconv.Atoi(fields[1])
	if err != nil {
		fmt.Printf("Error parsing width: %v\n", err)
		os.Exit(1)
	}

	height, err := strconv.Atoi(fields[2])
	if err != nil {
		fmt.Printf("Error parsing height: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Creating image: %dx%d\n", width, height)

	// Create image with white background
	img := image.NewRGBA(image.Rect(0, 0, width, height))
	white := color.RGBA{255, 255, 255, 255}
	black := color.RGBA{0, 0, 0, 255}

	// Fill with white
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			img.Set(x, y, white)
		}
	}

	// Draw lines
	lineCount := 0
	for scanner.Scan() {
		line := scanner.Text()
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		fields := strings.Fields(line)
		if len(fields) != 5 || fields[0] != "line" {
			fmt.Printf("Warning: skipping invalid line: %s\n", line)
			continue
		}

		x1, _ := strconv.Atoi(fields[1])
		y1, _ := strconv.Atoi(fields[2])
		x2, _ := strconv.Atoi(fields[3])
		y2, _ := strconv.Atoi(fields[4])

		drawLine(img, x1, y1, x2, y2, black)
		lineCount++
	}

	if err := scanner.Err(); err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Drew %d lines\n", lineCount)

	// Save to PNG
	outFile, err := os.Create(outputFile)
	if err != nil {
		fmt.Printf("Error creating output file: %v\n", err)
		os.Exit(1)
	}
	defer outFile.Close()

	if err := png.Encode(outFile, img); err != nil {
		fmt.Printf("Error encoding PNG: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Saved to %s\n", outputFile)
}

// drawLine draws an anti-aliased line using Xiaolin Wu's algorithm
func drawLine(img *image.RGBA, x1, y1, x2, y2 int, col color.Color) {
	drawLineWu(img, float64(x1), float64(y1), float64(x2), float64(y2), col)
}

func drawLineWu(img *image.RGBA, x0, y0, x1, y1 float64, col color.Color) {
	r, g, b, _ := col.RGBA()
	baseR := uint8(r >> 8)
	baseG := uint8(g >> 8)
	baseB := uint8(b >> 8)

	steep := math.Abs(y1-y0) > math.Abs(x1-x0)

	if steep {
		x0, y0 = y0, x0
		x1, y1 = y1, x1
	}

	if x0 > x1 {
		x0, x1 = x1, x0
		y0, y1 = y1, y0
	}

	dx := x1 - x0
	dy := y1 - y0

	gradient := 1.0
	if dx != 0 {
		gradient = dy / dx
	}

	// Handle first endpoint
	xend := round(x0)
	yend := y0 + gradient*(xend-x0)
	xgap := rfpart(x0 + 0.5)
	xpxl1 := xend
	ypxl1 := ipart(yend)

	if steep {
		plot(img, int(ypxl1), int(xpxl1), baseR, baseG, baseB, rfpart(yend)*xgap)
		plot(img, int(ypxl1)+1, int(xpxl1), baseR, baseG, baseB, fpart(yend)*xgap)
	} else {
		plot(img, int(xpxl1), int(ypxl1), baseR, baseG, baseB, rfpart(yend)*xgap)
		plot(img, int(xpxl1), int(ypxl1)+1, baseR, baseG, baseB, fpart(yend)*xgap)
	}

	intery := yend + gradient

	// Handle second endpoint
	xend = round(x1)
	yend = y1 + gradient*(xend-x1)
	xgap = fpart(x1 + 0.5)
	xpxl2 := xend
	ypxl2 := ipart(yend)

	if steep {
		plot(img, int(ypxl2), int(xpxl2), baseR, baseG, baseB, rfpart(yend)*xgap)
		plot(img, int(ypxl2)+1, int(xpxl2), baseR, baseG, baseB, fpart(yend)*xgap)
	} else {
		plot(img, int(xpxl2), int(ypxl2), baseR, baseG, baseB, rfpart(yend)*xgap)
		plot(img, int(xpxl2), int(ypxl2)+1, baseR, baseG, baseB, fpart(yend)*xgap)
	}

	// Main loop
	if steep {
		for x := xpxl1 + 1; x < xpxl2; x++ {
			plot(img, int(ipart(intery)), int(x), baseR, baseG, baseB, rfpart(intery))
			plot(img, int(ipart(intery))+1, int(x), baseR, baseG, baseB, fpart(intery))
			intery += gradient
		}
	} else {
		for x := xpxl1 + 1; x < xpxl2; x++ {
			plot(img, int(x), int(ipart(intery)), baseR, baseG, baseB, rfpart(intery))
			plot(img, int(x), int(ipart(intery))+1, baseR, baseG, baseB, fpart(intery))
			intery += gradient
		}
	}
}

func plot(img *image.RGBA, x, y int, r, g, b uint8, brightness float64) {
	bounds := img.Bounds()
	if x < bounds.Min.X || x >= bounds.Max.X || y < bounds.Min.Y || y >= bounds.Max.Y {
		return
	}

	// Get existing pixel color (for blending with background)
	existing := img.RGBAAt(x, y)

	// Blend the line color with the existing color based on brightness
	newR := uint8(float64(r)*brightness + float64(existing.R)*(1-brightness))
	newG := uint8(float64(g)*brightness + float64(existing.G)*(1-brightness))
	newB := uint8(float64(b)*brightness + float64(existing.B)*(1-brightness))

	img.Set(x, y, color.RGBA{newR, newG, newB, 255})
}

func ipart(x float64) float64 {
	return math.Floor(x)
}

func round(x float64) float64 {
	return math.Floor(x + 0.5)
}

func fpart(x float64) float64 {
	return x - math.Floor(x)
}

func rfpart(x float64) float64 {
	return 1 - fpart(x)
}
