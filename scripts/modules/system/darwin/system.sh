#!/bin/bash

# shellcheck source=/dev/null
# shellcheck disable=2144,2010,2062,2063,2035

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function install_from_URL {

  set -x

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Initialize a variable for the URL
  local -r URL="$1"

  # Create temporary directory
  TMP_DIRECTORY="$(mktemp -d)"

  # Determine file name and extension
  FILE_NAME=$(basename "$URL")
  EXTENSION="${FILE_NAME##*.}"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Download the file
  curl -sL "$URL" -o "$TMP_DIRECTORY/$FILE_NAME"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Handle different file types
  case $EXTENSION in
  "zip")
    # Extract the ZIP file
    unzip -q "$TMP_DIRECTORY/$FILE_NAME" -d "$TMP_DIRECTORY"

    # Find the '.app' or '.dmg' file
    if [[ -e "$TMP_DIRECTORY"/*.app ]]; then

      APP_FILE="$TMP_DIRECTORY"/*.app
      sudo cp -rf "$APP_FILE" /Applications

    elif [[ -e "$TMP_DIRECTORY"/*.dmg ]]; then

      FILE_NAME="$TMP_DIRECTORY"/*.dmg
      install_dmg "$FILE_NAME"

    else

      echo "No .app or .dmg file found in the ZIP archive."
      rm -rf "$TMP_DIRECTORY"
      set +x
      return 1

    fi
    ;;

  "dmg")
    # Install the program from the '.dmg' file
    install_dmg "$TMP_DIRECTORY/$FILE_NAME"
    ;;

  "pkg")
    # Install the program from the '.pkg' file
    sudo installer -pkg "$TMP_DIRECTORY/$FILE_NAME" -target /
    ;;

  *)
    echo "Unsupported file type: $EXTENSION"
    rm -rf "$TMP_DIRECTORY"
    set +x
    return 1
    ;;
  esac

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Remove the temporary directory
  rm -rf "$TMP_DIRECTORY"

  set +x

}

# see: https://apple.stackexchange.com/a/311511/291269
function install_dmg {

  set -x

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Initialize a variable for the URL to the '.dmg'

  local -r TARGET="$1"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Mount the '.dmg' then grab its PATH

  DISK="$(sudo hdiutil attach "$TARGET" | grep Volumes)"
  VOLUME="$(echo "$DISK" | cut -f 3)"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Install the program within the '.dmg'

  if [[ -e "$VOLUME"/*.app ]]; then
    sudo cp -rf "$VOLUME"/*.app /Applications
  elif [[ -e "$VOLUME"/*.pkg ]]; then
    package="$(ls -1 | grep *.pkg | head -1)"

    sudo installer -pkg "$VOLUME"/"$package".pkg -target /
  fi

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Eject the '.dmg'

  sudo hdiutil detach "$(echo "$DISK" | cut -f 1)"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  set +x

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
  while [[ "$#" -gt 0 ]]; do
    case $1 in
    -s | --sortby)
      if [[ $2 =~ ^[1-5]$ ]]; then
        sortby="${2}"
      fi
      ;;
    -d | --displayas)
      if [[ $2 =~ ^[0-1]$ ]]; then
        displayas="${2}"
      fi
      ;;
    -v | --viewcontentas)
      if [[ $2 =~ ^[0-3]$ ]]; then
        viewcontentas="${2}"
      fi
      ;;
    esac
    shift
  done

  if [[ -d "$folder_path" ]]; then
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

  defaults write com.apple.dock
  killall Dock
}
