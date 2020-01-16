#!/bin/bash

# shellcheck source=/dev/null
# shellcheck disable=2144,2010,2062,2063,2035,2059,2086,2046

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

export MAC_OS_WORK_PATH=/tmp/downloads

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# see: https://apple.stackexchange.com/a/311511/291269
function install_dmg {

    set -x

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Initialize a variable for the URL to the '.dmg'

    local -r URL="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Create temporary directory to store '.dmg'

    TMP_DIRECTORY="$(mktemp -d)"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    #  Obtain the '.dmg' via cURL

    curl -s "$URL" > "$TMP_DIRECTORY/pkg.dmg"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Mount the '.dmg' then grab its PATH

    DISK="$(sudo hdiutil attach "$TMP_DIRECTORY"/pkg.dmg | grep Volumes)"
    VOLUME="$(echo "$DISK" | cut -f 3)"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the program within the '.dmg'

    if [ -e "$VOLUME"/*.app ]; then
      sudo cp -rf "$VOLUME"/*.app /Applications
    elif [ -e "$VOLUME"/*.pkg ]; then
      package="$(ls -1 | grep *.pkg | head -1)"

      sudo installer -pkg "$VOLUME"/"$package".pkg -target /
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Eject the '.dmg'

    sudo hdiutil detach "$(echo "$DISK" | cut -f 1)"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Remove the temporary directory

    rm -rf "$TMP_DIRECTORY"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    set +x

}

# Installs an application via a DMG file.
# Parameters: $1 (required) - URL, $2 (required) - Mount path, $3 (required) - Application name.
function install_dmg_app() {
  local url="$1"
  local mount_point="/Volumes/$2"
  local app_name="$3"
  local install_path=$(get_install_path "$app_name")
  local work_file="download.dmg"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"
    mount_image "$MAC_OS_WORK_PATH/$work_file"
    install_app "$mount_point" "$app_name"
    unmount_image "$mount_point"
    verify_application "$app_name"
  fi
}

# Installs a package via a DMG file.
# Parameters: $1 (required) - URL, $2 (required) - Mount path, $3 (required) - Application name.
function install_dmg_pkg() {
  local url="$1"
  local mount_point="/Volumes/$2"
  local app_name="$3"
  local install_path=$(get_install_path "$app_name")
  local work_file="download.dmg"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"
    mount_image "$MAC_OS_WORK_PATH/$work_file"
    install_pkg "$mount_point" "$app_name"
    unmount_image "$mount_point"
    printf "Installed: $app_name.\n"
    verify_application "$app_name"
  fi
}

# Installs an application via a zip file.
# Parameters: $1 (required) - URL, $2 (required) - Application name.
function install_zip_app() {
  local url="$1"
  local app_name="$2"
  local install_path=$(get_install_path "$app_name")
  local work_file="download.zip"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"

    (
      printf "Preparing...\n"
      cd "$MAC_OS_WORK_PATH"
      unzip -q "$work_file"
      find . -type d -name "$app_name" -print -exec cp -pR {} . > /dev/null 2>&1 \;
    )

    install_app "$MAC_OS_WORK_PATH" "$app_name"
    printf "Installed: $app_name.\n"
    verify_application "$app_name"
  fi
}

# Installs a package via a zip file.
# Parameters: $1 (required) - URL, $2 (required) - Application name.
function install_zip_pkg() {
  local url="$1"
  local app_name="$2"
  local install_path=$(get_install_path "$app_name")
  local work_file="download.zip"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"

    (
      printf "Preparing...\n"
      cd "$MAC_OS_WORK_PATH"
      unzip -q "$work_file"
    )

    install_pkg "$MAC_OS_WORK_PATH" "$app_name"
    printf "Installed: $app_name.\n"
    verify_application "$app_name"
  fi
}

# Installs an application via a tar file.
# Parameters: $1 (required) - URL, $2 (required) - Application name, $3 (required) - Decompress options.
function install_tar_app() {
  local url="$1"
  local app_name="$2"
  local options="$3"
  local install_path=$(get_install_path "$app_name")
  local work_file="download.tar"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"

    (
      printf "Preparing...\n"
      cd "$MAC_OS_WORK_PATH"
      tar "$options" "$work_file"
    )

    install_app "$MAC_OS_WORK_PATH" "$app_name"
    printf "Installed: $app_name.\n"
    verify_application "$app_name"
  fi
}

# Installs program (single file).
# Parameters: $1 (required) - URL, $2 (required) - Program name.
function install_program() {
  local url="$1"
  local program_name="$2"
  local install_path=$(get_install_path "$program_name")

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$program_name"
    mv "$MAC_OS_WORK_PATH/$program_name" "$install_path"
    chmod 755 "$install_path"
    printf "Installed: $program_name.\n"
    verify_application "$program_name"
  fi
}

# Installs application code from a Git repository.
# Parameters: $1 (required) - Repository URL, $2 (required) - Install path, $3 (optional) - Git clone options.
function install_git_app() {
  local repository_url="$1"
  local app_name=$(get_file_name "$2")
  local install_path="$2"
  local options="--quiet"

  if [[ -n "$3" ]]; then
    local options="$options $3"
  fi

  if [[ ! -e "$install_path" ]]; then
    printf "Installing: $install_path/$app_name...\n"
    git clone $options "$repository_url" "$install_path"
    printf "Installed: $app_name.\n"
    verify_path "$install_path"
  fi
}

# Installs settings from a Git repository.
# Parameters: $1 (required) - Repository URL, $2 (required) - Repository version, $3 (required) - Project directory, $4 (required) - Script to run (including any arguments).
function install_git_project() {
  local repo_url="$1"
  local repo_version="$2"
  local project_dir="$3"
  local script="$4"

  git clone "$repo_url"
  (
    cd "$project_dir"
    git -c advice.detachedHead=false checkout "$repo_version"
    eval "$script"
  )
  rm -rf "$project_dir"
}

# Installs a single file.
# Parameters: $1 (required) - URL, $2 (required) - Install path.
function install_file() {
  local file_url="$1"
  local file_name=$(get_file_name "$1")
  local install_path="$2"

  if [[ ! -e "$install_path" ]]; then
    download_file "$file_url" "$file_name"
    mkdir -p "$(dirname "$install_path")"
    mv "$MAC_OS_WORK_PATH/$file_name" "$install_path"
    printf "Installed: $file_name.\n"
    verify_path "$install_path"
  fi
}

# Downloads remote file to local disk.
# Parameters: $1 (required) - URL, $2 (required) - File name, $3 (optional) - HTTP header.
function download_file() {
  local url="$1"
  local file_name="$2"
  local http_header="$3"

  printf "%s\n" "Downloading $1..."
  clean_work_path
  mkdir $MAC_OS_WORK_PATH
  curl --header "$http_header" --location --retry 3 --retry-delay 5 --fail --silent --show-error "$url" >> "$MAC_OS_WORK_PATH/$file_name"
}

# Installs an application.
# Parameters: $1 (required) - Application source path, $2 (required) - Application name.
function install_app() {
  local install_root=$(get_install_root "$2")
  local file_extension=$(get_file_extension "$2")

  printf "Installing: $install_root/$2...\n"

  case $file_extension in
    '')
      cp -a "$1/$2" "$install_root";;
    'app')
      cp -a "$1/$2" "$install_root";;
    'prefPane')
      sudo cp -pR "$1/$2" "$install_root";;
    'qlgenerator')
      sudo cp -pR "$1/$2" "$install_root" && qlmanage -r;;
    *)
      printf "ERROR: Unknown file extension: $file_extension.\n"
  esac
}

# Installs a package.
# Parameters: $1 (required) - Package source path, $2 (required) - Application name.
function install_pkg() {
  local install_root=$(get_install_root "$2")

  printf "Installing: $install_root/$2...\n"
  local package=$(sudo find "$1" -maxdepth 1 -type f -name "*.pkg" -o -name "*.mpkg")
  sudo installer -pkg "$package" -target /
}

# Mounts a disk image.
# Parameters: $1 (required) - Image path.
function mount_image() {
  printf "Mounting image...\n"
  hdiutil attach -quiet -nobrowse -noautoopen "$1"
}

# Unmounts a disk image.
# Parameters: $1 (required) - Mount path.
function unmount_image() {
  printf "Unmounting image...\n"
  hdiutil detach -force "$1"
}

# Uninstalls selected application.
function uninstall_application() {
  # Only use environment keys that end with "APP_NAME".
  local keys=($(set | awk -F "=" '{print $1}' | grep ".*APP_NAME"))

  printf "Select application to uninstall:\n"
  for ((index = 0; index < ${#keys[*]}; index++)); do
    local app_file="${!keys[$index]}"
    printf "  $index: ${app_file}\n"
  done
  printf "  q: Quit/Exit\n\n"

  read -p -r "Enter selection: " response
  printf "\n"

  local regex="^[0-9]+$"
  if [[ $response =~ $regex ]]; then
    local app_file="${!keys[$response]}"
    local app_path=$(get_install_path "${app_file}")
    sudo rm -rf "$app_path"
    printf "Uninstalled: ${app_path}\n"
  fi
}

# Uninstalls selected extension.
function uninstall_extension() {
  # Only use environment keys that end with "EXTENSION_PATH".
  local keys=($(set | awk -F "=" '{print $1}' | grep ".*EXTENSION_PATH"))

  printf "Select extension to uninstall:\n"
  for ((index = 0; index < ${#keys[*]}; index++)); do
    local extension_path="${!keys[$index]}"
    printf "  $index: ${extension_path}\n"
  done
  printf "  q: Quit/Exit\n\n"

  read -p -r "Enter selection: " response
  printf "\n"

  local regex="^[0-9]+$"
  if [[ $response =~ $regex ]]; then
    local extension_path="${!keys[$response]}"
    rm -rf "${extension_path}"
    printf "Uninstalled: ${extension_path}\n"
  fi
}

# Reinstall application.
function reinstall_application() {
  uninstall_application
  bin/install_applications
}

# Reinstall extension.
function reinstall_extension() {
  uninstall_extension
  bin/install_extensions
}

# Checks for missing Homebrew formulas.
function verify_homebrew_formulas() {
  printf "Checking Homebrew formulas...\n"

  local applications="$(brew list)"

  while read -r line; do
    # Skip blank or comment lines.
    if [[ "$line" == "brew install"* ]]; then
      local application=$(printf "$line" | awk '{print $3}')

      # Exception: "gpg" is the binary but is listed as "gnugp".
      if [[ "$application" == "gpg" ]]; then
        application="gnupg"
      fi

      # Exception: "hg" is the binary but is listed as "mercurial".
      if [[ "$application" == "hg" ]]; then
        application="mercurial"
      fi

      verify_listed_application "$application" "${applications[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_homebrew_formulas"

  printf "Homebrew formula check complete.\n"
}

# Checks for missing Homebrew casks.
function verify_homebrew_casks() {
  printf "\nChecking Homebrew casks...\n"

  local applications="$(brew cask list)"

  while read -r line; do
    # Skip blank or comment lines.
    if [[ "$line" == "brew cask install"* ]]; then
      local application=$(printf "$line" | awk '{print $4}')

      # Skip: Only necessary for the purpose of licensing system preference.
      if [[ "$application" == "witch" ]]; then
        continue
      fi

      # Skip: Bug with Homebrew Cask as these apps never show up as installed.
      if [[ "$application" == "skitch" || "$application" == "openemu" ]]; then
        continue
      fi

      verify_listed_application "$application" "${applications[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_homebrew_casks"

  printf "Homebrew cask check complete.\n"
}

# Checks for missing App Store applications.
function verify_app_store_applications() {
  printf "\nChecking App Store applications...\n"

  local applications="$(mas list)"

  while read -r line; do
    # Skip blank or comment lines.
    if [[ "$line" == "mas install"* ]]; then
      local application=$(printf "$line" | awk '{print $3}')
      verify_listed_application "$application" "${applications[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_app_store"

  printf "App Store check complete.\n"
}

# Verifies listed application exists.
# Parameters: $1 (required) - The current application, $2 (required) - The application list.
function verify_listed_application() {
  local application="$1"
  local applications="$2"

  if [[ "${applications[*]}" != *"$application"* ]]; then
    printf " - Missing: $application\n"
  fi
}

# Checks for missing applications suffixed by "APP_NAME" as defined in settings.sh.
function verify_applications() {
  printf "\nChecking application software...\n"

  # Only use environment keys that end with "APP_NAME".
  local file_names=$(set | awk -F "=" '{print $1}' | grep ".*APP_NAME")

  # For each application name, check to see if the application is installed. Otherwise, skip.
  for name in $file_names; do
    # Pass the key value to verfication.
    verify_application "${!name}"
  done

  printf "Application software check complete.\n"
}

# Verifies application exists.
# Parameters: $1 (required) - The file name.
function verify_application() {
  local file_name="$1"

  # Display the missing install if not found.
  local install_path=$(get_install_path "$file_name")

  if [[ ! -e "$install_path" ]]; then
    printf " - Missing: $file_name\n"
  fi
}

# Checks for missing extensions suffixed by "EXTENSION_PATH" as defined in settings.sh.
function verify_extensions() {
  printf "\nChecking application extensions...\n"

  # Only use environment keys that end with "EXTENSION_PATH".
  local extensions=$(set | awk -F "=" '{print $1}' | grep ".*EXTENSION_PATH")

  # For each extension, check to see if the extension is installed. Otherwise, skip.
  for extension in $extensions; do
    # Evaluate/extract the key (extension) value and pass it on for verfication.
    verify_path "${!extension}"
  done

  printf "Application extension check complete.\n"
}

# Verifies path exists.
# Parameters: $1 (required) - The path.
function verify_path() {
  local path="$1"

  # Display the missing path if not found.
  if [[ ! -e "$path" ]]; then
    printf " - Missing: $path\n"
  fi
}

# Answers the full install path (including file name) for file name.
# Parameters: $1 (required) - The file name.
function get_install_path() {
  local file_name="$1"
  local install_path=$(get_install_root "$file_name")
  printf "$install_path/$file_name"
}

# Caffeinate machine.
function caffeinate_machine() {
  local pid=$(pgrep -x caffeinate)

  if [[ -n "$pid" ]]; then
    printf "Whoa, tweaker, machine is already caffeinated!\n"
  else
    caffeinate -s -u -d -i -t 3153600000 > /dev/null &
    printf "Machine caffeinated.\n"
  fi
}

# Answers the root install path for file name.
# Parameters: $1 (required) - The file name.
function get_install_root() {
  local file_name="$1"
  local file_extension=$(get_file_extension "$file_name")

  # Dynamically build the install path based on file extension.
  case $file_extension in
    '')
      printf "/usr/local/bin";;
    'app')
      printf "/Applications";;
    'prefPane')
      printf "/Library/PreferencePanes";;
    'qlgenerator')
      printf "/Library/QuickLook";;
    *)
      printf "/tmp/unknown";;
  esac
}

# Answers the file extension.
# Parameters: $1 (required) - The file name.
function get_file_extension() {
  local name=$(get_file_name "$1")
  local extension="${1##*.}" # Excludes dot.

  if [[ "$name" == "$extension" ]]; then
    printf ''
  else
    printf "$extension"
  fi
}

# Answers the file name.
# Parameters: $1 (required) - The file path.
function get_file_name() {
  printf "${1##*/}" # Answers file or directory name.
}

# Cleans work path for temporary processing of installs.
function clean_work_path() {
  rm -rf "$MAC_OS_WORK_PATH"
}

# dock.sh - contributed by @rpavlick
# https://github.com/rpavlick/add_to_dock
function add_app_to_dock {
  # adds an application to macOS Dock
  # usage: add_app_to_dock "Application Name"
  # example add_app_to_dock "Terminal"

  app_name="${1}"
  launchservices_path="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"
  app_path=$(${launchservices_path} -dump | grep -o "/.*${app_name}.app" | grep -v -E "Backups|Caches|TimeMachine|Temporary|/Volumes/${app_name}" | uniq | sort | head -n1)
  if open -Ra "${app_path}"; then
      echo "$app_path added to the Dock."
      defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>${app_path}</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
  else
      echo "ERROR: $1 not found."
  fi
}

function add_folder_to_dock {
  # adds a folder to macOS Dock
  # usage: add_folder_to_dock "Folder Path" -s n -d n -v n
  # example: add_folder_to_dock "~/Downloads" -d 0 -s 2 -v 1
  # key:
  # -s or --sortby
  # 1 -> Name
  # 2 -> Date Added
  # 3 -> Date Modified
  # 4 -> Date Created
  # 5 -> Kind
  # -d or --displayas
  # 0 -> Stack
  # 1 -> Folder
  # -v or --viewcontentas
  # 0 -> Automatic
  # 1 -> Fan
  # 2 -> Grid
  # 3 -> List

  folder_path="${1}"
  sortby="1"
  displayas="0"
  viewcontentas="0"
  while [[ "$#" -gt 0 ]]
  do
      case $1 in
          -s|--sortby)
          if [[ $2 =~ ^[1-5]$ ]]; then
              sortby="${2}"
          fi
          ;;
          -d|--displayas)
          if [[ $2 =~ ^[0-1]$ ]]; then
              displayas="${2}"
          fi
          ;;
          -v|--viewcontentas)
          if [[ $2 =~ ^[0-3]$ ]]; then
              viewcontentas="${2}"
          fi
          ;;
      esac
      shift
  done

  if [ -d "$folder_path" ]; then
      echo "$folder_path added to the Dock."
      defaults write com.apple.dock persistent-others -array-add "<dict>
              <key>tile-data</key> <dict>
                  <key>arrangement</key> <integer>${sortby}</integer>
                  <key>displayas</key> <integer>${displayas}</integer>
                  <key>file-data</key> <dict>
                      <key>_CFURLString</key> <string>file://${folder_path}</string>
                      <key>_CFURLStringType</key> <integer>15</integer>
                  </dict>
                  <key>file-type</key> <integer>2</integer>
                  <key>showas</key> <integer>${viewcontentas}</integer>
              </dict>
              <key>tile-type</key> <string>directory-tile</string>
          </dict>"
  else
      echo "ERROR: $folder_path not found."
  fi
}

function add_spacer_to_dock {
  # adds an empty space to macOS Dock

  defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}'
}

function clear_dock {
  # removes all persistent icons from macOS Dock

  defaults write com.apple.dock persistent-apps -array
}

function reset_dock {
  # reset macOS Dock to default settings

  defaults write com.apple.dock; killall Dock
}
