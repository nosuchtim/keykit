import re
import sys


def read_version():
    try:
        with open("VERSION", "r") as f:
            version = f.read().strip()
    except OSError as e:
        print(f"Unable to read VERSION: {e}")
        sys.exit(1)

    if not version:
        print("VERSION is empty")
        sys.exit(1)

    return version


def replace_in_file(path, pattern, replacement, required=True):
    try:
        with open(path, "r") as f:
            original = f.read()
    except OSError as e:
        print(f"Unable to read {path}: {e}")
        sys.exit(1)

    updated, count = re.subn(pattern, replacement, original, count=1)
    if count != 1:
        if required:
            print(f"Unable to update version marker in {path}")
            sys.exit(1)
        return

    if updated != original:
        with open(path, "w") as f:
            f.write(updated)


def main():
    version = read_version()

    replace_in_file(
        "index.html",
        r"Version ....",
        f"Version {version}",
        required=False,
    )
    replace_in_file(
        "src/key.h",
        r'#define KEYVERSION "[^"]*"',
        f'#define KEYVERSION "{version}"',
    )
    replace_in_file(
        "src/main.c",
        r"KeyKit [^ ]+ - Copyright",
        f"KeyKit {version} - Copyright",
    )
    for path in (
        "src/key.rc",
        "mdep/nt/key.rc",
        "mdep/ntshare/key.rc",
        "bin/key.rc",
    ):
        replace_in_file(
            path,
            r'"KeyKit \([^)]+\)"',
            f'"KeyKit ({version})"',
        )
    replace_in_file(
        "doc/macros",
        r"\.ds KV .+",
        f".ds KV {version}",
    )


if __name__ == "__main__":
    main()
