#!/bin/bash
file_to_monitor="ipaddress.txt"
script_to_execute="custom-cluster-v4.sh"
execute_script_on_modify() {
    echo "File has been modified. Executing the script..."
    bash "$script_to_execute"
}
while true; do
    inotifywait -e modify "$file_to_monitor"
    execute_script_on_modify
    exit
done
