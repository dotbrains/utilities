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

def get_package_from_line(line):
    """
    The `get_package_from_line` function extracts the package name from a line in a Brewfile.
    :param line: A line from the Brewfile, which is a file used by Homebrew to manage packages and
    applications on macOS and Linux
    :return: The function `get_package_from_line` returns the package name from a line in a Brewfile.
    """

    return line.split("\"")[1]

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
        command = ["brew", "install"]

        if line.startswith("cask_args"):
            if os_type == "Darwin":  # Only for macOS
                arg = line.split(" ")[1]
                cask_args.append(arg.split(":")[1].strip().strip('"'))
        elif line.startswith("cask"):
            if os_type == "Darwin":  # Only for macOS
                package = get_package_from_line(line)
                options = line[line.find("{") + 1 : line.find("}")].split() if "{" in line and "}" in line else []

                command.append("--cask")

                if cask_args:
                    appdir_option = f"--appdir={cask_args[0]}"
                    command.append(appdir_option)

                command.extend(options)  # Add options only if they exist
                command.append(package)

                subprocess.run(command, check=True)
            else:
                print(f"Cask {line} skipped as it is not supported on Linux.")
        elif line.startswith("brew"):
            package = get_package_from_line(line)
            command.append(package)
            subprocess.run(command, check=True)
        elif line.startswith("tap"):
            tap = get_package_from_line(line)
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

    try:
        with open(args.file, "r") as f:
            for line in f:
                install_package(line.strip())
    except FileNotFoundError:
        print(f"File not found: {args.file}")
        sys.exit(1)

if __name__ == "__main__":
    main()
