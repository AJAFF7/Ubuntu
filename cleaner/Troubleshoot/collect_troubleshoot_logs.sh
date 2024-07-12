#!/bin/bash

# Log file to collect logs into
troubleshoot_log="/var/log/cleaner/Troubleshoot/troubleshoot.log"

# Function to append command output to troubleshoot log
append_command_output_to_log() {
    local command="$1"
    local description="$2"

    echo "### Start of $description ###" >> "$troubleshoot_log"
    sudo $command >> "$troubleshoot_log"
    echo "### End of $description ###" >> "$troubleshoot_log"
    echo "" >> "$troubleshoot_log"  # Add a blank line for separation
}

# Append syslog
append_command_output_to_log "less /var/log/syslog" "syslog"

# Append kernel log
append_command_output_to_log "less /var/log/kern.log" "kernel log"

# Append dmesg output
append_command_output_to_log "dmesg | less" "dmesg"

# Append systemd journal
append_command_output_to_log "journalctl -xe" "systemd journal (full)"

# Append tail of syslog
append_command_output_to_log "tail -n 20 /var/log/syslog" "tail -n 20 syslog"

# Append journalctl live view
append_command_output_to_log "journalctl --since '1 minute ago' --no-pager" "journalctl last minute"

echo "### Troubleshoot logs collected at $(date) ###" >> "$troubleshoot_log"

