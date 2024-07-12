#!/bin/bash

# Log file path
log_file="/var/log/cleaner/Processes/process_memory_usage.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a "$log_file"
}

# Get the list of processes with their memory usage in megabytes
ps -e -o pid,comm,rss | awk 'NR==1 {print $1, $2, "Memory (MB)"} NR>1 {printf "%-8s %-20s %-10.2f\n", $1, $2, $3/1024}' | tee -a "$log_file"

# Log success message with check mark symbol
echo -e "$(date +"%Y-%m-%d %H:%M:%S") \e[32mProcess memory usage logged successfully \xE2\x9C\x93\e[0m" | tee -a "$log_file"

