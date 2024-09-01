#!/bin/bash
# kwvm - Virtual Monitor Management Script
#
# This software is licensed under the GNU General Public License v3 (GPLv3) with additional terms.
# Please read the license and the additional terms at https://github.com/AndryGabry01/kwvm before modifying or distributing this software.
#
# Author: Andrea Gabriele
# Date: September 1st, 2024

# Determine the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if the configuration directory is present
CONFIG_DIR="$SCRIPT_DIR/config"
CONFIG_FILE="$CONFIG_DIR/config"
# Application name
APP_NAME="kwvm"
# Alias
ALIAS_APP="kwvm"
# Directory where monitor files will be saved
MONITOR_DIR="$SCRIPT_DIR/vmonitors"

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m'  # No Color

# Initial setup function
setup() {
  echo $CONFIG_FILE;
  if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${CYAN}Running initial setup...${NC}"

    # Create necessary directories
    mkdir -p "$SCRIPT_DIR/vmonitors"
    mkdir -p "$CONFIG_DIR"

    # Create the configuration file
    echo "# Application name" > "$CONFIG_FILE"
    echo "APP_NAME='$APP_NAME'" >> "$CONFIG_FILE"
    echo "# Directory where monitor files will be saved" >> "$CONFIG_FILE"
    echo "MONITOR_DIR='$SCRIPT_DIR/vmonitors'" >> "$CONFIG_FILE"

    echo -e "${GREEN}Setup completed. Configuration saved to $CONFIG_FILE.${NC}"

    # Check the graphical environment and operating system
    check_system

    # Prompt to create an alias
    prompt_for_alias
  fi
}

# Function to check the operating system and graphical environment
check_system() {
  echo -e "${CYAN}Checking the operating system and graphical environment...${NC}"
  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    echo -e "${GREEN}Wayland graphical environment detected.${NC}"
  elif [ "$XDG_CURRENT_DESKTOP" == "KDE" ]; then
    echo -e "${GREEN}KDE desktop environment detected.${NC}"
    if command -v krfb-virtualmonitor >/dev/null 2>&1; then
      echo -e "${GREEN}krfb-virtualmonitor is installed.${NC}"
    else
      echo -e "${RED}krfb-virtualmonitor is not installed.${NC}"
    fi
  else
    echo -e "${YELLOW}Operating system or graphical environment not recognized.${NC}"
  fi
}

# Function to generate a random password of 20 characters
generate_password() {
  local password_length=20
  local chars='A-Za-z0-9!@#$%^&*()_+='
  local password=$(</dev/urandom tr -dc "$chars" | head -c $password_length)
  echo "$password"
}

# Function to add the alias
add_alias() {
  echo "alias kwvm='$SCRIPT_DIR/$0'" >> "$HOME/.bashrc"
  source "$HOME/.bashrc"
  echo -e "${GREEN}Alias 'kwvm' successfully added.${NC}"
}

# Function to remove the alias
remove_alias() {
  sed -i "/alias kwvm=/d" "$HOME/.bashrc"
  source "$HOME/.bashrc"
  echo -e "${GREEN}Alias 'kwvm' successfully removed.${NC}"
}

# Function to prompt the user to create the alias
prompt_for_alias() {
  if grep -q "alias kwvm=" "$HOME/.bashrc"; then
    echo -e "${YELLOW}Alias 'kwvm' is already set.${NC}"
    read -p "Do you want to remove it? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      remove_alias
    fi
  else
    read -p "Do you want to create an alias 'kwvm' for this script? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      add_alias
    else
      echo -e "${YELLOW}Alias 'kwvm' not set.${NC}"
    fi
  fi
}

# Ensure the monitor directory exists
mkdir -p "$MONITOR_DIR"

# Function to check if a port is already in use
is_port_in_use() {
  local port=$1

  # Check if the port is in use by any process
  if lsof -i :$port &> /dev/null; then
    return 1  # Port in use by another process
  fi

  # Check if the port is already assigned to another monitor
  for file in "$MONITOR_DIR"/*; do
    # Initialize variable
    monitor_port=""

    # Read the port configuration from each monitor file
    while IFS='=' read -r key value; do
      case "$key" in
        port) monitor_port="$value" ;;
      esac
    done < "$file"

    if [ "$monitor_port" == "$port" ]; then
      return 1  # Port is already used by another monitor
    fi
  done

  return 0  # Port is free
}


# Function to create or modify a monitor
manage_monitor() {
  local mode=$1
  local id_or_name=$2
  local monitor_file=""
  local name=""
  local resolution=""
  local port=""
  local password=""
  local dpr=""
  local pid=""

  # Management mode
  if [ "$mode" == "edit" ]; then
    if [ -z "$id_or_name" ]; then
      echo -e "${RED}Error: Please specify an ID or name for the monitor to be modified.${NC}"
      exit 1
    fi

    monitor_file=$(find_monitor_file "$id_or_name")
    if [ -z "$monitor_file" ]; then
      echo -e "${RED}Error: Monitor with ID or name '$id_or_name' not found.${NC}"
      exit 1
    fi

    # Read monitor parameters from file
    while IFS='=' read -r key value; do
      case "$key" in
        name) name="$value" ;;
        resolution) resolution="$value" ;;
        port) port="$value" ;;
        password) password="$value" ;;
        dpr) dpr="$value" ;;
        pid) pid="$value" ;;
      esac
    done < "$monitor_file"

    echo -e "${CYAN}${BOLD}Modifying virtual monitor '${name}'...${NC}"

  else
    # Creation mode
    echo -e "${CYAN}${BOLD}Creating a new virtual monitor...${NC}"
    monitor_file=""
    default_name=""
    resolution="1920x1080"
    port="5900"
    password=$(generate_password) # Generate a random password
    dpr="1.0"
  fi

  # Prompt user for information with default values
  read -p "Monitor name: " new_name
  new_name=${new_name:-$name}
  if [[ ! "$new_name" =~ ^[a-z0-9_]+$ ]]; then
    echo -e "${RED}Error: Monitor name can only contain lowercase letters, numbers, and underscores ('_') and must not have spaces.${NC}"
    exit 1
  fi

  read -p "Resolution (e.g., 1920x1080) [default: $resolution]: " new_resolution
  new_resolution=${new_resolution:-$resolution}

  while true; do
    read -p "Port (e.g., 5900) [default: $port]: " new_port
    new_port=${new_port:-$port}

    is_port_in_use $new_port
    port_status=$?

    if [ $port_status -eq 1 ]; then
      echo -e "${YELLOW}Error: Port $new_port is already in use by another monitor. Please choose another port.${NC}"
      exit 1
    elif [ $port_status -eq 2 ]; then
      echo -e "${YELLOW}Error: Port $new_port is already in use by another process. Please choose another port.${NC}"
      exit 1
    else
      break
    fi
  done

  read -p "Password [default: $password]: " new_password
  new_password=${new_password:-$password}

  read -p "Device Pixel Ratio (e.g., 1.0) [default: $dpr]: " new_dpr
  new_dpr=${new_dpr:-$dpr}

  # Save information to a file
  if [ "$mode" == "edit" ]; then
    echo "name=$new_name" > "$monitor_file"
  else
    monitor_file="$MONITOR_DIR/$new_name"
    if [ -f "$monitor_file" ]; then
      echo -e "${RED}Error: A monitor with the name '$new_name' already exists.${NC}"
      exit 1
    fi
    echo "name=$new_name" > "$monitor_file"
  fi
  echo "resolution=$new_resolution" >> "$monitor_file"
  echo "port=$new_port" >> "$monitor_file"
  echo "password=$new_password" >> "$monitor_file"
  echo "dpr=$new_dpr" >> "$monitor_file"
  echo "pid=" >> "$monitor_file"

  if [ "$mode" == "edit" ]; then
    echo -e "${GREEN}Virtual monitor '$new_name' successfully modified!${NC}"
  else
    echo -e "${GREEN}Virtual monitor '$new_name' successfully created!${NC}"
  fi
}

# Function to delete a monitor
delete_monitor() {
  id_or_name=$1
  if [ -z "$id_or_name" ]; then
    echo -e "${RED}Error: Please specify an ID or name for the monitor to delete.${NC}"
    exit 1
  fi

  monitor_file=$(find_monitor_file "$id_or_name")
  if [ -z "$monitor_file" ]; then
    echo -e "${RED}Error: Monitor with ID or name '$id_or_name' not found.${NC}"
    exit 1
  fi

  # Confirm deletion
  read -p "Are you sure you want to delete the monitor '${monitor_file##*/}'? [y/N]: " confirm
  confirm=${confirm,,}  # Convert to lowercase
  if [[ "$confirm" != "y" ]]; then
    echo -e "${YELLOW}Deletion canceled.${NC}"
    return
  fi

  # Delete the monitor file
  rm -f "$monitor_file"
  echo -e "${GREEN}Monitor '${monitor_file##*/}' successfully deleted!${NC}"
}

# Function to list all monitors
list_monitors() {

  echo -e "${BLUE}${UNDERLINE}List of virtual monitors:${NC}"
  echo -e "${BLUE}----------------------------------------------------------------------------------------------------------------------------------------${NC}"

  # Check if there are files in MONITOR_DIR
  if [ ! "$(ls -A "$MONITOR_DIR")" ]; then
    echo -e "${YELLOW}No registered monitors. Use the 'create' or 'c' command to create a new monitor.${NC}"
    echo -e "${BLUE}----------------------------------------------------------------------------------------------------------------------------------------${NC}"
    return
  fi

  # Table header
  printf "%-5s %-15s %-15s %-10s %-20s %-15s\n" "ID" "Name" "Resolution" "Port" "Password" "Status"
  echo -e "${BLUE}----------------------------------------------------------------------------------------------------------------------------------------${NC}"

  i=1
  for file in $(ls "$MONITOR_DIR" | sort); do
    # Initialize variables
    name=""
    resolution=""
    port=""
    password=""
    dpr=""
    pid=""

    # Read file content line by line
    while IFS='=' read -r key value; do
      case "$key" in
        name) name="$value" ;;
        resolution) resolution="$value" ;;
        port) port="$value" ;;
        password) password="$value" ;;
        dpr) dpr="$value" ;;
        pid) pid="$value" ;;
      esac
    done < "$MONITOR_DIR/$file"

    # Truncate the password if too long to maintain alignment
    display_password=$password
    if [ ${#password} -gt 20 ]; then
      display_password="${password:0:17}..."
    fi

    # Check if the monitor file is complete
    if [[ -z "$name" || -z "$resolution" || -z "$port" || -z "$password" ]]; then
      # If information is missing, show an error message
      printf "%-5s %-15s %-15s %-10s %-20s ${RED}%-15s${NC} (${YELLOW}File path: $MONITOR_DIR/$file${NC})\n" "$i" "${name:-Error}" "${resolution:-Error}" "${port:-Error}" "${display_password:-Error}" "Error: Missing data"
    else
      # If all information is present, show monitor details
      if [ -z "$pid" ]; then
        printf "%-5s %-15s %-15s %-10s %-20s ${RED}%-15s${NC}\n" "$i" "$name" "$resolution" "$port" "$display_password" "Inactive"
      else
        printf "%-5s %-15s %-15s %-10s %-20s ${GREEN}%-15s${NC}\n" "$i" "$name" "$resolution" "$port" "$display_password" "Active (PID: $pid)"
      fi
    fi
    ((i++))
  done

  echo -e "${BLUE}----------------------------------------------------------------------------------------------------------------------------------------${NC}"
}

# Function to start a monitor
start_monitor() {
  id_or_name=$1
  if [ -z "$id_or_name" ]; then
    echo -e "${RED}Error: Please specify an ID or name for the monitor to start.${NC}"
    exit 1
  fi

  monitor_file=$(find_monitor_file "$id_or_name")
  if [ -z "$monitor_file" ]; then
    echo -e "${RED}Error: Monitor with ID or name '$id_or_name' not found.${NC}"
    exit 1
  fi

  # Initialize variables to avoid conflicts
  name=""
  resolution=""
  port=""
  password=""
  dpr=""
  pid=""

  # Read monitor parameters from file
  while IFS='=' read -r key value; do
    case "$key" in
      name) name="$value" ;;
      resolution) resolution="$value" ;;
      port) port="$value" ;;
      password) password="$value" ;;
      dpr) dpr="$value" ;;
      pid) pid="$value" ;;
    esac
  done < "$monitor_file"

  if [ ! -z "$pid" ]; then
    echo -e "${RED}Error: The monitor '$name' is already active (PID: $pid).${NC}"
    exit 1
  fi

  # Start the monitor and save the PID
  krfb-virtualmonitor --name "$name" --resolution "$resolution" --port "$port" --password "$password" --scale "$dpr" > /dev/null 2>&1 &
  pid=$!
  sed -i "s/^pid=.*/pid=$pid/" "$monitor_file"

  echo -e "${GREEN}Virtual monitor '$name' successfully started (PID: $pid).${NC}"
}

# Function to stop a monitor
stop_monitor() {
  id_or_name=$1
  if [ -z "$id_or_name" ]; then
    echo -e "${RED}Error: Please specify an ID or name for the monitor to stop.${NC}"
    exit 1
  fi

  monitor_file=$(find_monitor_file "$id_or_name")
  if [ -z "$monitor_file" ]; then
    echo -e "${RED}Error: Monitor with ID or name '$id_or_name' not found.${NC}"
    exit 1
  fi

  # Initialize variables to avoid conflicts
  name=""
  resolution=""
  port=""
  password=""
  dpr=""
  pid=""

  # Read monitor parameters from file
  while IFS='=' read -r key value; do
    case "$key" in
      name) name="$value" ;;
      resolution) resolution="$value" ;;
      port) port="$value" ;;
      password) password="$value" ;;
      dpr) dpr="$value" ;;
      pid) pid="$value" ;;
    esac
  done < "$monitor_file"

  if [ -z "$pid" ]; then
    echo -e "${YELLOW}Error: The monitor '$name' is not active.${NC}"
    exit 1
  fi

  # Terminate the process
  kill $pid
  sed -i "s/^pid=.*/pid=/" "$monitor_file"

  echo -e "${GREEN}Virtual monitor '$name' successfully stopped.${NC}"
}

# Function to stop all monitors
kill_all_monitors() {
  echo -e "${CYAN}${BOLD}Terminating all virtual monitors...${NC}"

  for file in $(ls "$MONITOR_DIR" | sort); do
    # Initialize variables
    pid=""

    # Read the PID of the monitor from the file
    while IFS='=' read -r key value; do
      case "$key" in
        pid) pid="$value" ;;
      esac
    done < "$MONITOR_DIR/$file"

    if [ ! -z "$pid" ]; then
      # Terminate the process
      kill $pid
      sed -i "s/^pid=.*/pid=/" "$MONITOR_DIR/$file"
      echo -e "${GREEN}Virtual monitor with PID $pid terminated.${NC}"
    fi
  done

  echo -e "${GREEN}All virtual monitors have been stopped.${NC}"
}

# Function to find a monitor file given an ID or name
find_monitor_file() {
  local search_key=$1
  if [[ "$search_key" =~ ^[0-9]+$ ]]; then
    # Search by ID
    local i=1
    for file in $(ls "$MONITOR_DIR" | sort); do
      if [ "$i" -eq "$search_key" ]; then
        echo "$MONITOR_DIR/$file"
        return
      fi
      ((i++))
    done
  else
    # Search by name
    if [ -f "$MONITOR_DIR/$search_key" ]; then
      echo "$MONITOR_DIR/$search_key"
    fi
  fi
}

# Function to forcibly kill all monitors
kill_all_monitors() {
  force_kill=$1
  if [ "$force_kill" == "-f" ]; then
    echo -e "${RED}${BOLD}Forcefully terminating all 'krfb-virtualmonitor' processes...${NC}"
    pkill -f krfb-virtualmonitor
    echo -e "${GREEN}All 'krfb-virtualmonitor' processes have been terminated.${NC}"
  else
    echo -e "${CYAN}${BOLD}Terminating all virtual monitors...${NC}"

    for file in $(ls "$MONITOR_DIR" | sort); do
      # Initialize variables
      pid=""

      # Read the PID of the monitor from the file
      while IFS='=' read -r key value; do
        case "$key" in
          pid) pid="$value" ;;
        esac
      done < "$MONITOR_DIR/$file"

      if [ ! -z "$pid" ]; then
        # Terminate the process
        kill $pid
        sed -i "s/^pid=.*/pid=/" "$MONITOR_DIR/$file"
        echo -e "${GREEN}Virtual monitor with PID $pid terminated.${NC}"
      fi
    done

    echo -e "${GREEN}All virtual monitors have been stopped.${NC}"
  fi
}

# Function to display the help message
show_help() {
  echo -e "${CYAN}Usage: $0 {command} [options]${NC}"
  echo -e "${BOLD}Available commands:${NC}"
  echo -e "  ${YELLOW}create, c${NC}      - Create a new virtual monitor."
  echo -e "  ${YELLOW}edit, e${NC}        - Modify an existing virtual monitor."
  echo -e "  ${YELLOW}delete, d${NC}      - Delete a virtual monitor specified by ID or name."
  echo -e "  ${YELLOW}list, l${NC}        - List all virtual monitors."
  echo -e "  ${YELLOW}start, s${NC}       - Start a virtual monitor specified by ID or name."
  echo -e "  ${YELLOW}stop, x${NC}        - Stop a virtual monitor specified by ID or name."
  echo -e "  ${YELLOW}killall, k${NC} [-f] - Terminate all virtual monitors."
  echo -e "                     - Option '-f' to directly terminate all 'krfb-virtualmonitor' processes,"
  echo -e "                       including those not created by this script."
  echo -e "  ${YELLOW}alias, a${NC}       - Set or remove the alias 'kwvm' for this script."
  echo -e "  ${YELLOW}help, h${NC}        - Show this help message."
}

# Execute setup procedure if necessary
setup

# Command management block
case "$1" in
  create|c)
    manage_monitor "create"
    ;;
  edit|e)
    manage_monitor "edit" "$2"
    ;;
  delete|d)
    delete_monitor "$2"
    ;;
  list|l)
    list_monitors
    ;;
  start|s)
    start_monitor "$2"
    ;;
  stop|x)
    stop_monitor "$2"
    ;;
  killall|k)
    kill_all_monitors "$2"
    ;;
  alias|a)
    prompt_for_alias
    ;;
  help|h)
    show_help
    ;;
  *)
    echo -e "${RED}Error: Unrecognized command.${NC}"
    echo -e "${YELLOW}Use '$0 help' or '$0 h' to see the list of available commands.${NC}"
    exit 1
    ;;
esac
