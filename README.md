# LXC Container Backup and Restore Script

This repository contains a bash script, `backup_lxc.sh`, designed to create backups of LXC containers on Proxmox VE and to restore them when needed. The script utilizes zstd compression for efficient storage and includes a logging mechanism for tracking backup activities.

## Features

- **Automated Backup**: Schedules regular backups of specified LXC containers.
- **Compression**: Uses zstd compression for space-efficient storage.
- **Logging**: Generates detailed log files for each backup operation.
- **Cleanup**: Automatically deletes old backups, keeping only the last 7 days of backups.
- **Notes File**: Creates a `.notes` file with details about each backup.

## Prerequisites

- **Proxmox VE 7**: Ensure you are running Proxmox VE 7 or later.
- **Storage Configuration**: You need to have a suitable storage configuration for your backups. This script uses `local` storage by default, but can be modified to use any suitable storage available on your Proxmox VE setup.

## Script Details

### Backup Script

The `backup_lxc.sh` script is used to create a backup of an LXC container with the specified ID.

#### Script Configuration

- **CONTAINER_ID**: The ID of the container to back up.
- **STORAGE**: The storage location for the backup.
- **BACKUP_DIR**: The directory where the backup files will be stored.
- **LOG_FILE**: The file where backup logs will be saved.
- **NOTES_FILE**: The file where backup notes will be saved.

#### Script Content

```bash
#!/bin/bash

# Configuration
CONTAINER_ID=Your-Container-ID-Here
STORAGE="local"
BACKUP_DIR="/var/lib/vz/dump"
LOG_FILE="/var/log/vzdump_${CONTAINER_ID}_$(date +'%Y_%m_%d_%H_%M_%S').log"
NOTES_FILE="${BACKUP_DIR}/vzdump-lxc-${CONTAINER_ID}-$(date +'%Y_%m_%d_%H_%M_%S').tar.zst.notes"

# Create a backup with zstd compression
echo "Starting backup for LXC container ID $CONTAINER_ID at $(date)" >> "$LOG_FILE"
vzdump $CONTAINER_ID --storage $STORAGE --mode snapshot --compress zstd >> "$LOG_FILE" 2>&1

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully at $(date)" >> "$LOG_FILE"
    
    # Create a .notes file with backup details
    echo "Backup ID: $CONTAINER_ID" > "$NOTES_FILE"
    echo "Backup Date: $(date)" >> "$NOTES_FILE"
    echo "Backup Log: $LOG_FILE" >> "$NOTES_FILE"
    echo "Compression: zstd" >> "$NOTES_FILE"
else
    echo "Backup failed at $(date)" >> "$LOG_FILE"
fi

# Optional: Cleanup old backups (keeping last 7 days)
find $BACKUP_DIR -name "vzdump-lxc-${CONTAINER_ID}-*.tar.zst" -type f -mtime +7 -exec rm -f {} \;

# End of script
```

### Restore Process

To restore a container from the backup created by `backup_lxc.sh`, follow these steps:

1. **Locate the Backup File**:
   Ensure that the backup file (e.g., `vzdump-lxc-Your-Container-ID-Here-2024_08_05-15_55_25.tar.zst`) is in the `/var/lib/vz/dump` directory or another appropriate location.

2. **Restore the Container**:
   Use the `pct restore` command to restore the container from the backup file. Specify the storage to use for the container.

   ```bash
   pct restore Your-Container-ID-Here /var/lib/vz/dump/vzdump-lxc-Your-Container-ID-Here-2024_08_05-15_55_25.tar.zst --storage local-lvm
   ```

3. **Start the Restored Container**:
   Once the container is restored, start it using the following command:

   ```bash
   pct start Your-Container-ID-Here
   ```

4. **Verify the Container Status**:
   Check the status of the restored container to ensure it is running correctly.

   ```bash
   pct status Your-Container-ID-Here
   ```

## Usage

### Cloning the Repository

To clone this repository, use the following command:

```bash
git clone https://github.com/Lalatenduswain/LXC-Container-Backup-and-Restore-Script.git
```

### Running the Backup Script

Navigate to the directory where the script is located and run it:

```bash
cd /opt/Script
./backup_lxc.sh
```

## Disclaimer

**Author:** Lalatendu Swain | [GitHub](https://github.com/Lalatenduswain) | [Website](https://blog.lalatendu.info/)

This script is provided as-is and may require modifications or updates based on your specific environment and requirements. Use it at your own risk. The authors of the script are not liable for any damages or issues caused by its usage.

## Donations

If you find this script useful and want to show your appreciation, you can donate via [Buy Me a Coffee](https://www.buymeacoffee.com/lalatendu.swain).
