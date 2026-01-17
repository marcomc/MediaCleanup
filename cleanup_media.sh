#!/usr/bin/env bash
GOOGLE_DRIVE_DIR='/Users/mmassari/Library/CloudStorage/GoogleDrive-massaric@gmail.com/My Drive/Media'
# shellcheck disable=SC2034
BITPORT_SFTP_DIR='/Users/mmassari/.CMVolumes/BitPort BETA'
PCLOUD_DIR='/Users/mmassari/pCloud Drive/My Videos'

MEDIA_DIRS=(
  "${GOOGLE_DRIVE_DIR}/TV Shows"
  # "${GOOGLE_DRIVE_DIR}/Movies"
  # "${BITPORT_SFTP_DIR}/TV Shows"
  # "${BITPORT_SFTP_DIR}/Movies"
  "${PCLOUD_DIR}/TV Shows"
  # "${PCLOUD_DIR}/Movies"
)
VIDEO_EXTENSIONS=("mp4" "mkv" "avi" "mov" "flv" "wmv" "mpg" "mpeg" "webm" "m4v" "srt")

move_files_to_root() {
  local dir="$1"
  echo "Moving files in subdirectories of: $(basename "${dir}") to root"
  find "${dir}" -mindepth 2 -type f -exec sh -c 'dest="$2/$(basename "$1")"; echo "Moving file to: $dest" && mv "$1" "$dest"' _ {} "${dir}" \;
}
remove_unwanted_files() {
  local dir="$1"
  local exclude_args=()
  echo "Removing unwanted files in: $(basename "${dir}")"
  for ext in "${VIDEO_EXTENSIONS[@]}"; do
    exclude_args+=("!" "-iname" "*.${ext}")
  done
  find "${dir}" -type f "${exclude_args[@]}" -exec echo "Removing file: {}" \; -exec rm {} \;
}

remove_empty_subdirs() {
  local dir="$1"
  echo "Removing empty subdirectories in: $(basename "${dir}")"

  while true; do
    empty_dirs=$(find "${dir}" -mindepth 1 -type d -empty)
    if [[ -z "${empty_dirs}" ]]; then
      break
    fi
    echo "${empty_dirs}" | while IFS= read -r subdir; do
      if [[ "${subdir}" != "${dir}" ]]; then
        echo "Removing empty directory: ${subdir}"
        rmdir "${subdir}"
      fi
    done
  done
}

normalize_filenames() {
  local dir="$1"
  echo "Normalizing filenames in: $(basename "${dir}")"
  files=$(find "${dir}" -type f) || true
  echo "${files}" | while IFS= read -r file; do
    dir_name=$(dirname "${file}")
    base_name=$(basename "${file}")
    
    # Skip files with empty base names
    if [[ -z "${base_name}" ]]; then
      continue
    fi
    
    # Replace any character that is not a letter, digit, or one of the characters !? with a dot (.)
    new_name="${base_name//[^a-zA-Z0-9!?]/.}"
    
    # Replace parentheses (), square brackets [], and curly braces {} with dots (.)
    new_name=$(echo "${new_name}" | tr '()[]{}' '......')
    
    # Squeeze multiple consecutive dots into a single dot
    new_name=$(echo "${new_name}" | tr -s '.')

    # If the new name starts with a dot, remove the dot
    new_name="${new_name#.}"

    # Extract the file extension from the variable 'new_name' and store it in 'ext'
    # Remove the file extension from 'new_name' and store the result back in 'new_name'
    ext="${new_name##*.}"
    new_name="${new_name%.*}"
    
    # Capitalize the first letter of each segment separated by dots
    new_name=$(echo "${new_name}" | awk -F. '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS='.')
    new_name="${new_name}.${ext}"
    
    # If the filename ends with a dot followed by a number, and the number is not a 4-digit number, remove the number
    if [[ "${new_name}" =~ ^(.*)\.([0-9]+)$ ]]; then
      number="${BASH_REMATCH[2]}"
      if ! [[ "${number}" =~ ^[0-9]{4}$ ]]; then
        new_name="${BASH_REMATCH[1]}"
      fi
    fi
    
    # If the new filename is different from the original, rename the file
    if [[ "${base_name}" != "${new_name}" ]]; then
      echo "Renaming ${base_name} to ${new_name}"
      mv "${file}" "${dir_name}/${new_name}"
    fi
  done 
}

# Loop through each directory and call the functions
for dir in "${MEDIA_DIRS[@]}"; do
  move_files_to_root "${dir}"
  remove_empty_subdirs "${dir}"
  remove_unwanted_files "${dir}"
  normalize_filenames "${dir}"
done
