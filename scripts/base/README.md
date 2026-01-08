# Base Module

Core utility functions providing interactive prompts, colored output, execution helpers, and process management.

## Platform Support

- ✅ All platforms (macOS, Linux)

## Dependencies

- bash 3.2+
- Standard Unix utilities (tput, ps, grep)

## Functions

### Interactive Prompts

#### `answer_is_yes()`

Check if the user's response is affirmative (Y/y).

**Usage:**

```bash
ask_for_confirmation "Continue?"
if answer_is_yes; then
    echo "User confirmed"
fi
```

**Returns:** 0 if yes, 1 otherwise

---

#### `ask(question)`

Prompt user for input and store response in `$REPLY`.

**Parameters:**

- `$1` - Question to display

**Usage:**

```bash
ask "What is your name?"
name=$(get_answer)
```

---

#### `ask_for_confirmation(question)`

Prompt user for yes/no confirmation.

**Parameters:**

- `$1` - Question to display

**Usage:**

```bash
ask_for_confirmation "Delete all files?"
if answer_is_yes; then
    rm -rf *
fi
```

---

#### `ask_for_sudo()`

Request sudo privileges and keep them alive for the duration of the script.

**Usage:**

```bash
ask_for_sudo
sudo apt update
# sudo will remain active
```

---

#### `get_answer()`

Retrieve the user's last input from `$REPLY`.

**Returns:** The value of `$REPLY`

---

#### `skip_questions(args...)`

Check if script should skip interactive prompts (e.g., `-y` or `--yes` flag).

**Parameters:**

- `$@` - Command line arguments

**Usage:**

```bash
if ! skip_questions "$@"; then
    ask_for_confirmation "Install package?"
fi
```

**Returns:** 0 if `-y` or `--yes` present, 1 otherwise

---

### Execution & Process Management

#### `execute(command [message])`

Execute a command with a spinner and formatted output. Opens in a new terminal window on macOS/Linux desktop environments.

**Parameters:**

- `$1` - Command to execute
- `$2` - Optional display message (defaults to command)

**Usage:**

```bash
execute "brew install wget" "Installing wget"
```

**Returns:** Exit code of the executed command

---

#### `terminal(command)`

Open a new macOS Terminal window and execute a command (macOS only).

**Parameters:**

- `$1` - Command to execute

**Usage:**

```bash
terminal "cd $HOME && ls -la"
```

**Platform:** macOS only

---

#### `show_spinner(pid command message)`

Display an animated spinner while a process is running.

**Parameters:**

- `$1` - Process ID to monitor
- `$2` - Command being executed
- `$3` - Display message

**Usage:**

```bash
long_running_command &
show_spinner $! "long_running_command" "Processing..."
```

---

#### `kill_all_subprocesses()`

Kill all background jobs spawned by the current shell.

**Usage:**

```bash
set_trap EXIT kill_all_subprocesses
```

---

### Output Functions

#### Color Output

#### `print_in_color(text color)`

Print text in the specified color.

**Parameters:**

- `$1` - Text to print
- `$2` - Color code (1=red, 2=green, 3=yellow, 5=purple)

---

#### `print_in_green(text)`

Print text in green.

**Usage:**

```bash
print_in_green "Success!\n"
```

---

#### `print_in_red(text)`

Print text in red.

**Usage:**

```bash
print_in_red "Error!\n"
```

---

#### `print_in_yellow(text)`

Print text in yellow.

**Usage:**

```bash
print_in_yellow "Warning!\n"
```

---

#### `print_in_purple(text)`

Print text in purple.

---

#### Formatted Output

#### `ok(message)`

Print a success message with `[ok]` prefix.

**Usage:**

```bash
ok "Installation complete"
```

---

#### `bot(message)`

Print a message with bot emoji prefix.

**Usage:**

```bash
bot "Starting setup process"
```

---

#### `running(message)`

Print a "running" message (no newline).

**Usage:**

```bash
running "Installing packages"
echo "done"
```

---

#### `action(message)`

Print an action message with `[action]` prefix.

**Usage:**

```bash
action "Downloading files"
```

---

#### `warn(message)`

Print a warning message with `[warning]` prefix.

**Usage:**

```bash
warn "Configuration file not found"
```

---

#### `success(message)`

Print a success message with `[success]` prefix.

**Usage:**

```bash
success "All tests passed"
```

---

#### `error(message)`

Print an error message with `[error]` prefix.

**Usage:**

```bash
error "Failed to connect to server"
```

---

#### `cancelled(message)`

Print a cancellation message with `[cancelled]` prefix.

**Usage:**

```bash
cancelled "Operation aborted by user"
```

---

#### `print_error(message [details])`

Print a formatted error with ✖ symbol.

**Parameters:**

- `$1` - Error message
- `$2` - Optional details

---

#### `print_error_stream()`

Read error lines from stdin and print them formatted.

**Usage:**

```bash
command 2>&1 | print_error_stream
```

---

#### `print_question(message)`

Print a question with `[?]` prefix.

**Usage:**

```bash
print_question "Enter your choice: "
```

---

#### `print_result(exit_code message)`

Print success or error based on exit code.

**Parameters:**

- `$1` - Exit code (0 = success)
- `$2` - Message

**Usage:**

```bash
command
print_result $? "Operation completed"
```

---

#### `print_success(message)`

Print a formatted success message with ✔ symbol.

**Usage:**

```bash
print_success "File created successfully"
```

---

#### `print_warning(message)`

Print a formatted warning with ! symbol.

**Usage:**

```bash
print_warning "Using default configuration"
```

---

## Color Variables

```bash
COL_RESET   # Reset to default
COL_RED     # Red color
COL_GREEN   # Green color
COL_YELLOW  # Yellow color
COL_BLUE    # Blue color
bold        # Bold text
normal      # Normal text
```

**Usage:**

```bash
echo -e "${COL_GREEN}Success${COL_RESET}"
echo -e "${bold}Important${normal}"
```

## Examples

### Complete Interactive Script

```bash
#!/bin/bash

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

bot "Starting installation"

# Request sudo early
ask_for_sudo

# Interactive confirmation
ask_for_confirmation "Install dependencies?"
if answer_is_yes; then
    execute "apt-get update" "Updating package lists"
    execute "apt-get install -y build-essential" "Installing build tools"
    success "Dependencies installed"
else
    cancelled "Installation skipped"
    exit 0
fi

ok "Installation complete!"
```

### Non-Interactive Script

```bash
#!/bin/bash

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

# Skip prompts if -y flag present
if skip_questions "$@"; then
    action "Running in non-interactive mode"
fi

running "Downloading files"
if wget -q https://example.com/file; then
    success "Download complete"
else
    error "Download failed"
    exit 1
fi
```
