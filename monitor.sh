#!/bin/bash

# Path to the file you want to monitor
file_to_monitor="ipaddress.txt"

# Path to the script you want to execute on file modification
script_to_execute="custom-cluster-create.sh"

# Function to execute the script on file modification
execute_script_on_modify() {
    echo "File has been modified. Executing the script..."
    bash "$script_to_execute"
}

# Main loop to monitor the file
while true; do
    # Use inotifywait to watch for modifications to the file
    inotifywait -e modify "$file_to_monitor"

    # When the file is modified, execute the script
    execute_script_on_modify
done

