#!/bin/bash

# Log file path
log_file="/var/log/cleaner/Update-Repository/apt_update.log"

# Function to log messages with date and time
log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$log_file"
}

# Function to log completion message with green check mark
log_completion_message() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \e[32mAll Packages Updated Successfully \xE2\x9C\x93\e[0m" | tee -a "$log_file"
}

# Function to log upgrade message in red with a cross
log_upgrade_message() {
    local num_packages=$1
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \e[32mAll Packages Updated Successfully \xE2\x9C\x93\e[0m" | tee -a "$log_file"
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] \e[31mPackages Need to Be Upgraded: $num_packages \xE2\x9C\x97\e[0m" | tee -a "$log_file"
}

# Log the start of apt-get update
log_message "Starting apt-get update..."

# Run apt update and log the output with date and time
update_output=$(sudo apt update 2>&1)
echo "$update_output" | tee -a "$log_file"

# Check if there are packages that need to be upgraded
upgradable_packages=$(apt list --upgradable 2>/dev/null | grep -v "Listing... Done" | wc -l)

# Adjust the count to exclude the header line
if [ "$upgradable_packages" -gt 0 ]; then
    upgradable_packages=$((upgradable_packages - 1))
fi

if [ "$upgradable_packages" -gt 0 ]; then
    log_upgrade_message "$upgradable_packages"
else
    log_completion_message
fi

