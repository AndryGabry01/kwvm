
# kwvm

**kwvm** is a Bash script designed to manage virtual monitors on Linux systems, specifically tailored for KDE environments using tools like [krfb-virtualmonitor](https://invent.kde.org/network/krfb). This script allows users to create, modify, delete, and manage virtual monitors efficiently.

**Note**: This script is compatible **only with KDE running on Wayland**.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Setup](#setup)
- [Usage](#usage)
- [Commands](#commands)
- [Examples](#examples)
- [License](#license)
- [Contributing](#contributing)

## Features

- **Create Virtual Monitors**: Easily create new virtual monitors with customizable settings.
- **Modify Existing Monitors**: Update settings for existing virtual monitors.
- **Delete Monitors**: Remove virtual monitors that are no longer needed.
- **Start and Stop Monitors**: Control the state of virtual monitors.
- **List All Monitors**: Display a list of all created monitors along with their details.
- **Compatibility Check**: Verifies the operating environment and the presence of necessary tools.

## Installation

To install **kwvm**, follow these steps:

1. **Clone the Repository**:  
   git clone https://github.com/yourusername/kwvm.git  
   cd kwvm

2. **Make the Script Executable**:  
   chmod +x kwvm.sh

You can place the script in any directory you prefer. For example, if you place the script in a folder named `kwvm` in your home directory (`$HOME/kwvm`), on the first run, the script will create the necessary directories for configuration and monitor files inside this folder, such as `$HOME/kwvm/config` and `$HOME/kwvm/vmonitors`.

## Setup

The first time you run the script, it will automatically perform a setup process:

./kwvm.sh

This setup will:
- Create the necessary directories (`vmonitors` and `config`).
- Generate a default configuration file.
- Check the system environment (e.g., Wayland, KDE, `krfb-virtualmonitor`).

## Usage

To use **kwvm**, run the script with one of the available commands:

./kwvm.sh <command> [options]

## Commands

- **create, c**: Create a new virtual monitor.
- **edit, e**: Modify an existing virtual monitor by ID or name.
- **delete, d**: Delete a virtual monitor by ID or name.
- **list, l**: List all virtual monitors.
- **start, s**: Start a virtual monitor by ID or name.
- **stop, x**: Stop a virtual monitor by ID or name.
- **killall, k**: Terminate all virtual monitors. Use `-f` to forcefully kill all `krfb-virtualmonitor` processes.
- **alias, a**: Set or remove the alias for this script.
- **help, h**: Show help information.

## Examples

- **Create a New Virtual Monitor**:  
  ./kwvm.sh create

- **Modify a Monitor by Name**:  
  ./kwvm.sh edit monitor1

- **Delete a Monitor by ID**:  
  ./kwvm.sh delete 2

- **List All Monitors**:  
  ./kwvm.sh list

- **Start a Monitor by Name**:  
  ./kwvm.sh start monitor1

- **Stop a Monitor by ID**:  
  ./kwvm.sh stop 2

- **Terminate All Monitors**:  
  ./kwvm.sh killall

- **Forcefully Terminate All `krfb-virtualmonitor` Processes**:  
  ./kwvm.sh killall -f

## License

This project is licensed under the GNU General Public License v3 (GPLv3) with additional terms. See the [LICENSE](LICENSE) file for details.

## Contributing

We welcome contributions! Please fork the repository and submit a pull request with your changes. Be sure to follow the existing coding style and include any necessary tests with your contribution.

For more information on `krfb-virtualmonitor`, visit [KDE's GitLab repository](https://invent.kde.org/network/krfb).

---

For the Italian version of this README, please refer to the [Italian README](README_IT.md).
