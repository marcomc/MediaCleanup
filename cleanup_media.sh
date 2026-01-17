#!/usr/bin/env bash
USERNAME=$(whoami)
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  cat <<EOF
Usage: $(basename "$0")

Seeds config at: /Users/${USERNAME}/.mediacleanup.conf

Description:
  Organizes TV show media files based on ~/.mediacleanup.conf.

Notes:
  If ~/.mediacleanup.conf is missing, the script copies
  mediacleanup.conf.sample and exits so you can personalize it.
EOF
  exit 0
fi
MEDIA_DIRS=()
ALLOWED_FILE_EXT=()
SERIES_MARKER=".tvshow"
CONFIG_FILENAME=".mediacleanup.conf"
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAMPLE_CONFIG_PATH="${SCRIPT_DIR}/mediacleanup.conf.sample"
CONFIG_PATH="/Users/${USERNAME}/${CONFIG_FILENAME}"

log_action() {
  echo "$1"
}

lowercase() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

is_allowed_extension() {
  local filename="$1"
  local ext="${filename##*.}"
  local ext_lc
  ext_lc="$(lowercase "$ext")"
  for allowed in "${ALLOWED_FILE_EXT[@]}"; do
    if [[ "$ext_lc" == "$(lowercase "$allowed")" ]]; then
      return 0
    fi
  done
  return 1
}

seed_config_if_missing() {
  if [[ -f "${CONFIG_PATH}" ]]; then
    return 0
  fi

  if [[ ! -f "${SAMPLE_CONFIG_PATH}" ]]; then
    log_action "Missing sample config: ${SAMPLE_CONFIG_PATH}"
    return 1
  fi

  log_action "Seeding config: ${CONFIG_PATH}"
  cp "${SAMPLE_CONFIG_PATH}" "${CONFIG_PATH}"
}

load_first_config() {
  if [[ -f "${CONFIG_PATH}" ]]; then
    # shellcheck disable=SC1090
    source "${CONFIG_PATH}"
    return 0
  fi
  return 1
}

ensure_configs() {
  local failures=0
  if ! seed_config_if_missing; then
    failures=$((failures + 1))
  fi
  if [[ "${failures}" -gt 0 ]]; then
    return 1
  fi
  return 0
}

remove_unwanted_files() {
  local dir="$1"
  local base_name
  log_action "Removing unwanted files in: $(basename "${dir}")"

  while IFS= read -r -d '' file; do
    base_name=$(basename "${file}")
    if [[ "${base_name}" == "${SERIES_MARKER}" ]]; then
      continue
    fi

    if ! is_allowed_extension "${base_name}"; then
      log_action "Removing file: ${file}"
      rm "${file}"
    fi
  done < <(find "${dir}" -type f -print0)
}

is_series_root_dir() {
  local dir="$1"
  if [[ -f "${dir}/${SERIES_MARKER}" ]]; then
    return 0
  fi
  find "${dir}" -maxdepth 1 -type d -name 'S[0-9][0-9]' -print -quit | grep -q .
}

build_series_roots() {
  local dir="$1"
  SERIES_ROOTS=()
  while IFS= read -r -d '' candidate; do
    if is_series_root_dir "$candidate"; then
      SERIES_ROOTS+=("$candidate")
    fi
  done < <(find "${dir}" -mindepth 1 -maxdepth 1 -type d -print0)
}

is_under_series_root() {
  local path="$1"
  local root
  for root in "${SERIES_ROOTS[@]}"; do
    case "$path" in
      "${root}"/*) return 0 ;;
    esac
  done
  return 1
}

find_series_root() {
  local dir="$1"
  local series_name="$2"
  local series_lc
  local root

  series_lc="$(lowercase "$series_name")"
  for root in "${SERIES_ROOTS[@]}"; do
    if [[ "$(lowercase "$(basename "$root")")" == "$series_lc" ]]; then
      echo "$root"
      return 0
    fi
  done

  echo "${dir}/${series_name}"
}

ensure_series_marker() {
  local series_root="$1"
  if [[ ! -f "${series_root}/${SERIES_MARKER}" ]]; then
    log_action "Creating marker: ${series_root}/${SERIES_MARKER}"
    touch "${series_root}/${SERIES_MARKER}"
  fi

  if ! is_under_series_root "${series_root}/dummy"; then
    SERIES_ROOTS+=("${series_root}")
  fi
}

move_files_to_root() {
  local dir="$1"
  log_action "Moving files in subdirectories of: $(basename "${dir}") to root"
  while IFS= read -r -d '' file; do
    if is_under_series_root "$file"; then
      continue
    fi
    dest="${dir}/$(basename "$file")"
    if [[ -e "$dest" ]]; then
      log_action "Skipping existing file: ${dest}"
      continue
    fi
    log_action "Moving file to: ${dest}"
    mv "$file" "$dest"
  done < <(find "${dir}" -mindepth 2 -type f -print0)
}

remove_empty_subdirs() {
  local dir="$1"
  log_action "Removing empty subdirectories in: $(basename "${dir}")"

  while IFS= read -r -d '' subdir; do
    if [[ "${subdir}" != "${dir}" ]] && ! is_under_series_root "${subdir}"; then
      log_action "Removing empty directory: ${subdir}"
      rmdir "${subdir}"
    fi
  done < <(find "${dir}" -depth -mindepth 1 -type d -empty -print0)
}

normalize_filenames() {
  local dir="$1"
  log_action "Normalizing filenames in: $(basename "${dir}")"
  while IFS= read -r -d '' file; do
    dir_name=$(dirname "${file}")
    base_name=$(basename "${file}")

    # Skip files with empty base names
    if [[ -z "${base_name}" ]]; then
      continue
    fi

    if [[ "${base_name}" == .* ]]; then
      continue
    fi

    if ! is_allowed_extension "${base_name}"; then
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
      log_action "Renaming ${base_name} to ${new_name}"
      mv "${file}" "${dir_name}/${new_name}"
    fi
  done < <(find "${dir}" -maxdepth 1 -type f -print0)
}

organize_series_files() {
  local dir="$1"
  local base_name
  local name_no_ext
  local series_name
  local season_token
  local season_number
  local season_folder
  local series_root
  local dest

  log_action "Organizing episode files in: $(basename "${dir}")"
  while IFS= read -r -d '' file; do
    base_name=$(basename "${file}")

    if [[ "${base_name}" == .* ]]; then
      continue
    fi

    if ! is_allowed_extension "${base_name}"; then
      continue
    fi

    # Expect a season token like S07E10; series name is the prefix before it.
    name_no_ext="${base_name%.*}"
    if ! [[ "${name_no_ext}" =~ ^(.+)\.([Ss][0-9]{1,2})[Ee][0-9]{1,2} ]]; then
      continue
    fi

    series_name="${BASH_REMATCH[1]}"
    season_token="${BASH_REMATCH[2]}"
    season_number="${season_token:1}"
    season_folder=$(printf "S%02d" "$((10#$season_number))")

    series_root=$(find_series_root "$dir" "$series_name")
    if [[ ! -d "${series_root}" ]]; then
      log_action "Creating series folder: ${series_root}"
      mkdir -p "${series_root}"
    fi

    ensure_series_marker "${series_root}"
    if [[ ! -d "${series_root}/${season_folder}" ]]; then
      log_action "Creating season folder: ${series_root}/${season_folder}"
      mkdir -p "${series_root}/${season_folder}"
    fi

    dest="${series_root}/${season_folder}/${base_name}"
    if [[ -e "${dest}" ]]; then
      log_action "Skipping existing file: ${dest}"
      continue
    fi

    log_action "Moving file to: ${dest}"
    mv "${file}" "${dest}"
  done < <(find "${dir}" -maxdepth 1 -type f -print0)
}

if ! load_first_config; then
  if seed_config_if_missing; then
    log_action "Config seeded at ${CONFIG_PATH}. Update it before rerunning."
  fi
  exit 0
fi

if [[ "${#MEDIA_DIRS[@]}" -eq 0 || "${#ALLOWED_FILE_EXT[@]}" -eq 0 ]]; then
  log_action "Config is missing MEDIA_DIRS or ALLOWED_FILE_EXT: ${CONFIG_PATH}"
  exit 1
fi

# Loop through each directory and call the functions
for dir in "${MEDIA_DIRS[@]}"; do
  build_series_roots "${dir}"
  move_files_to_root "${dir}"
  remove_empty_subdirs "${dir}"
  normalize_filenames "${dir}"
  organize_series_files "${dir}"
  remove_unwanted_files "${dir}"
  remove_empty_subdirs "${dir}"
done
