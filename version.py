import os
import re
import sys

VERSION = re.compile(r"^(\d+\.\d+\.\d+)$")


def create_tag(version: str):
    """
    Creates and pushes git tags for the given version.
    :param version: The Semantic version to tag.
    """
    major = version.split(".")[0]

    commands = [
        f"git tag v{version}",
        f"git tag -f v{major}",
        f"git push --atomic -f origin main v{version} v{major}",
    ]

    for command in commands:
        os.system(command)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 version.py <version>")
        sys.exit(1)

    version = sys.argv[1]
    assert VERSION.match(version), f"{version} is not a valid Semantic version"

    create_tag(version)
