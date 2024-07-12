#!/bin/bash

# Log file path
log_file="/var/log/cleaner/Processes/process_cleanup.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a "$log_file"
}

# Function to log messages with colors using tput
log_colored_message() {
    local color="$1"
    local message="$2"
    local color_start=""
    local color_end=""

    # Define colors using tput
    if [ "$color" = "red" ]; then
        color_start="$(tput setaf 1)"  # Red
        color_end="$(tput sgr0)"       # Reset color
    elif [ "$color" = "green" ]; then
        color_start="$(tput setaf 2)"  # Green
        color_end="$(tput sgr0)"       # Reset color
        message="\e[32m\xE2\x9C\x93  ${message}\e[0m "  # Add ✔️ before the message
    fi

    echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${color_start}${message}${color_end}" | tee -a "$log_file"
}

# Function to check if a process is running
is_process_running() {
    local process_name="$1"
    pgrep -x "$process_name" >/dev/null
}

# Function to check if a process has been idle for more than 3 minutes
is_process_idle() {
    local process_name="$1"
    local max_idle_time_secs=180  # 3 minutes
    local last_activity=$(ps -o etimes= -p $(pgrep -d, -f "$process_name") | tr ',' '\n' | sort -rn | head -n1)
    
    # Check if last activity time is greater than max_idle_time_secs
    if [ "$last_activity" -gt "$max_idle_time_secs" ]; then
        return 0  # Process is idle
    else
        return 1  # Process is active
    fi
}


# Kill Java process if idle for more than 3 minutes
if is_process_running "java"; then
    if is_process_idle "java"; then
        pkill -9 java
        log_colored_message "green" "Successfully killed Java process"
    fi
else
    log_colored_message "red" "No Java process found"
fi

# Kill Dockerd process if idle for more than 3 minutes
if is_process_running "dockerd"; then
    if is_process_idle "dockerd"; then
        pkill -9 jenkins
        log_colored_message "green" "Successfully killed Dockerd process"
    fi
else
    log_colored_message "red" "No Dockerd process found"
fi

# Kill Containerd process if idle for more than 3 minutes
if is_process_running "containerd"; then
    if is_process_idle "containerd"; then
        pkill -9 containerd
        log_colored_message "green" "Successfully killed Containerd process"
    fi
else
    log_colored_message "red" "No Containerd process found"
fi


# Kill Spice-Vdagentd process if idle for more than 3 minutes
if is_process_running "spice-vdagentd"; then
    if is_process_idle "spice-vdagentd"; then
        pkill -9 spice-vdagentd
        log_colored_message "green" "Successfully killed Spice-Vdagentd process"
    fi
else
    log_colored_message "red" "No Spice-Vdagentd process found"
fi

