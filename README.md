# Big Brother - File and Folder Tracker

## Overview

Big Brother is a Bash script designed to track changes in specified files and folders. It monitors the creation and deletion of files and directories within a specified path. This script can be particularly useful for keeping an eye on important directories and ensuring that no unauthorized changes occur.

## Features

- Tracks specified files and folders, or all files and folders within a given directory if no specific files are mentioned.
- Logs the addition and deletion of files and folders.
- Maintains a record of existing files and folders.
- Provides a welcome message on the first run.
- Handles the creation of a new file with the same name after a folder is deleted, and vice versa.

## Usage

```bash
./bigBrother.sh /path/to/directory [file_or_folder_to_track1] [file_or_folder_to_track2] ...
```

### Parameters

- `/path/to/directory`: The directory you want to monitor. This parameter is required.
- `[file_or_folder_to_track]`: Optional. List of specific files or folders to track. If not provided, the script will track all files and folders in the specified directory.

## Example

```bash
./bigBrother.sh /home/user/Documents file1.txt folder1
```

In the above example, the script will monitor the `/home/user/Documents` directory and track changes to `file1.txt` and `folder1`.

## How It Works

### First Run

1. The script checks if it's the first time running by looking for the `.data` directory.
2. It validates the provided path.
3. If the path is valid, it stores the absolute path in the `.path` file.
4. A welcome message is displayed.
5. It creates the `.data` directory and initializes tracking files.
6. If specific files/folders are provided as arguments, it tracks those; otherwise, it tracks all files and folders in the specified directory.
7. Logs the initial state of the specified files and folders.

### Subsequent Runs

1. The script retrieves the stored path from the `.path` file.
2. It lists existing files and folders in the monitored directory.
3. It compares the current state with the previously logged state.
4. It logs and reports any additions or deletions of files and folders.

### Error Handling

- If the specified path is invalid, the script exits with an error message.
- If files or folders are deleted and then a new file or folder with the same name is created, the script accurately logs these changes.

## Files

- `bigBrother.sh`: The main script file.
- `.path`: Stores the absolute path of the monitored directory.
- `.data`: Directory containing tracking data.
  - `list`: List of files and folders to track.
  - `Folder_Exist`: Log file for existing folders.
  - `File_Exist`: Log file for existing files.

## Dependencies

- Bash shell

## Notes

- Ensure that the script has execute permissions. You can set this using `chmod +x bigBrother.sh`.
- Run the script from the directory where `bigBrother.sh` is located to ensure proper path handling.

## License

This script is open source and available under the MIT License.

## Authors

- Yarin Shohat
