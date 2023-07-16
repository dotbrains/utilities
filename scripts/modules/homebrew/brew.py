import subprocess
import sys
import platform
import argparse

cask_args = []

def parse_args():
    """
    The `parse_args` function is used to parse command line arguments for installing packages from a
    Brewfile.
    :return: The function `parse_args()` returns the parsed arguments from the command line.
    """
    parser = argparse.ArgumentParser(description="Install packages from a Brewfile.")
    parser.add_argument("-f", "--file", help="Path to the Brewfile", required=True)
    return parser.parse_args()

def install_brew():
    """
    The function `install_brew()` installs Homebrew on a macOS system using a shell command.
    """
    command = "printf \"\n\" | /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""

    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError:
        print("Error during Homebrew installation.")
        sys.exit(1)

def install_package(line):
    """
    The `install_package` function installs packages from a Brewfile, with support for cask packages on
    macOS.

    :param line: A line from the Brewfile, which is a file used by Homebrew to manage packages and
    applications on macOS and Linux
    :return: The function does not explicitly return anything.
    """
    global cask_args
    os_type = platform.system()

    # Skip comments
    if line.startswith("#"):
        return

    try:
        if line.startswith("cask_args"):
            if os_type == "Darwin":  # Only for macOS
                arg = line.split(" ")[1]
                cask_args.append(arg.split(":")[1].strip().strip('"'))
        elif line.startswith("cask"):
            if os_type == "Darwin":  # Only for macOS
                package = line.split("\"")[1]
                options = line[line.find("[") + 1 : line.find("]")].split() if "[" in line and "]" in line else []
                subprocess.run(
                    [
                        "brew",
                        "install",
                        "--cask",
                        f"--appdir={cask_args[0]}",
                        *options,
                        package,
                    ],
                    check=True,
                )
            else:
                print(f"Cask {line} skipped as it is not supported on Linux.")
        elif line.startswith("brew"):
            package = line.split("\"")[1]
            subprocess.run(["brew", "install", package], check=True)
        elif line.startswith("tap"):
            tap = line.split("\"")[1]
            subprocess.run(["brew", "tap", tap], check=True)
    except subprocess.CalledProcessError:
        print(f"Failed to install: {line}")
        sys.exit(1)

def main():
    """
    The main function checks if Homebrew is installed and if not, installs it, then reads a file line by
    line and installs packages specified in each line.
    """
    args = parse_args()

    try:
        subprocess.run(["brew", "--version"], check=True)
    except subprocess.CalledProcessError:
        print("Homebrew not found, installing...")
        install_brew()

    with open(args.file, "r") as f:
        for line in f:
            install_package(line.strip())

if __name__ == "__main__":
    main()
