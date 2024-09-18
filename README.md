# MountWizard

Welcome to MountWizard! An intuitive tool for managing the mounting and unmounting of remote file systems using SSHFS, all through a user-friendly dialog interface.

## Description

MountWizard is a Bash script designed to simplify the process of mounting and unmounting remote file systems. With an interactive interface, you can add, remove, mount, and unmount remote machines effortlessly, eliminating the need to remember complex commands.

## Features

- **Interactive Interface**: Utilizes dialog to provide a user-friendly and navigable interface.
- **Machine Management**: Easily add and remove remote machines.
- **Mounting and Unmounting**: Mount and unmount remote file systems with just a few clicks.
- **Enhanced Security**: Securely prompts for passwords, displaying asterisks as you type.
- **Data Validation**: Checks the validity of entered IP addresses and ports.
- **Real-Time Feedback**: Displays success or error messages during operations.

## Installation

Follow these steps to install and set up MountWizard on your system:

### Download the Script:

Clone the repository or download the script directly:

```bash
git clone https://github.com/manwolframio/MountWizard.git
cd MountWizard
```

### Make the Script Executable:

```bash
chmod +x mountwizard.sh
```

### Install Required Dependencies:

- `sshfs`: To mount remote file systems.
- `dialog`: For the user interface.

On Debian/Ubuntu-based systems:

```bash
sudo apt-get update
sudo apt-get install sshfs dialog
```

On RedHat/Fedora-based systems:

```bash
sudo dnf install sshfs dialog
```

### Configure FUSE Permissions (if necessary):

Ensure your user is part of the fuse group:

```bash
sudo usermod -a -G fuse $USER
```

Log out and log back in for the changes to take effect.

## Usage

Run the script from the terminal:

```bash
./mountwizard.sh
```

You will be presented with a menu featuring the following options:

- Mount Machines
- Add New Machine
- Delete Machine
- Unmount Machines
- Exit

### Adding a New Machine

To add a new machine:

1. Select "Add New Machine" from the main menu.
2. Enter the name you wish to assign to the machine.
3. Provide the machine's IP address.
4. Enter the SSH port (default is 22).
5. Specify the username for the connection.

The machine will be added to your list and will be available for mounting.

### Mounting Machines

To mount machines:

1. Select "Mount Machines".
2. Check the machines you wish to mount from the presented list.
3. Enter the password when prompted (asterisks will be displayed as you type).
4. The script will mount the selected machines and inform you of the results.

Remote file systems will be mounted in your \`$HOME\` directory under the assigned machine names.

### Unmounting Machines

To unmount machines:

1. Select "Unmount Machines".
2. Check the mounted machines you wish to unmount.
3. The script will proceed to unmount them and confirm the action.

### Deleting Machines

To remove machines from your list:

1. Select "Delete Machine".
2. Check the machines you wish to delete.
3. Confirm the action, and the machines will be removed from your list.

## Functionalities

1. **Mounting Remote File Systems**
    - Description: Mount remote file systems using SSHFS with ease.
    - Details:
        - Securely prompts for the password, displaying asterisks as you type.
        - Displays success or error messages using dialog.
        - Creates mount points in your \`$HOME\` directory using the machine name.

2. **Unmounting File Systems**
    - Description: Unmount previously mounted file systems.
    - Details:
        - Detects file systems mounted with SSHFS in your \`$HOME\` directory.
        - Allows you to select multiple mounts to unmount simultaneously.

3. **Machine Management**
    - Add Machine:
        - Validates that the IP address and port are correct.
        - Stores information in a \`machines.txt\` file.
    - Delete Machine:
        - Displays a list of registered machines.
        - Enables you to delete multiple machines simultaneously.

4. **User-Friendly Interface**
    - Description: All interactions are handled through intuitive dialog boxes.
    - Details:
        - Utilizes dialog to offer a simple and visually pleasing user interface.
        - Clearly displays messages and errors for an improved user experience.

## Additional Notes

- **Security**: It's recommended to use SSH key-based authentication for enhanced security. If you use SSH keys, you can modify the script to skip the password prompt.
- **Configuration Files**: Machine information is stored in the \`machines.txt\` file. Ensure to keep this file in a secure location.

## Contributions

Contributions are welcome! If you have suggestions, encounter issues, or wish to add new features, please open an issue or submit a pull request on the project's repository.



