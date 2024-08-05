#!/bin/bash
# Mentor : Lalatendu Swain
# Configuration
CONTAINER_ID=131
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
