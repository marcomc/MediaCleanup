#!/bin/bash

# Define the file containing the renaming log
clipboard="$1"

# Read the renaming log line by line
while IFS= read -r line
do
    # Extract the original name and renamed version from the log
    original_name=$(echo "${line}" | sed -n 's/^Renaming \(.*\) to .*$/\1/p')
    renamed_name=$(echo "${line}" | sed -n 's/^Renaming .* to \(.*\)$/\1/p')

    # If both original and renamed names are not empty, revert the renaming
    if [[ -n "${original_name}" && -n "${renamed_name}" ]]; then
        echo "Reverting ${renamed_name} to ${original_name}"
        mv "${renamed_name}" "${original_name}"|| \
        echo "Error: Cannot rename ${renamed_name} to ${original_name}"
    fi
done < "${clipboard}"

echo "Renaming process completed."