#!/usr/bin/env bash
USERNAME=$(whoami)
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  cat <<EOF
Usage: $(basename "$0")

Seeds config at: /Users/${USERNAME}/.mediacleanup.conf

Description:
  Organizes TV shows and movies based on ~/.mediacleanup.conf.

Notes:
  If ~/.mediacleanup.conf is missing, the script copies
  mediacleanup.conf.sample and exits so you can personalize it.
EOF
  exit 0
fi
MEDIA_DIRS=()
ALLOWED_FILE_EXT=()
ALLOWED_FILE_EXT_LC=()
SERIES_MARKER=".tvshow"
# Marker for grouped movie series folders.
MOVIE_MARKER=".movieseries"
CONFIG_FILENAME=".mediacleanup.conf"
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAMPLE_CONFIG_PATH="${SCRIPT_DIR}/mediacleanup.conf.sample"
CONFIG_PATH="/Users/${USERNAME}/${CONFIG_FILENAME}"
USE_COLOR=0
if [[ -t 1 ]]; then
  USE_COLOR=1
fi
COLOR_RESET=""
COLOR_DIR=""
COLOR_STEP=""
if [[ "${USE_COLOR}" -eq 1 ]]; then
  COLOR_RESET="$(tput sgr0)"
  COLOR_DIR="$(tput setaf 4)"
  COLOR_STEP="$(tput setaf 2)"
fi
RUN_ID="$(date +%Y%m%d%H%M%S)"
ACTION_LOG_DIR="/tmp/mediacleanup"
ACTION_LIST_FILE="${ACTION_LOG_DIR}/action-list-${RUN_ID}.txt"

log_action() {
  echo "$1"
}

log_dir_header() {
  local dir="$1"
  echo "${COLOR_DIR}== ${dir}${COLOR_RESET}"
}

log_step() {
  log_action "${COLOR_STEP}${1}${COLOR_RESET}"
}

lowercase() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

find_root_files() {
  local dir="$1"
  find "${dir}" -maxdepth 1 -type f -print0
}

find_nested_files() {
  local dir="$1"
  find "${dir}" -mindepth 2 -type f -print0
}

find_all_files() {
  local dir="$1"
  find "${dir}" -type f -print0
}

init_action_logging() {
  mkdir -p "${ACTION_LOG_DIR}"
  : > "${ACTION_LIST_FILE}"
}

prune_action_logs() {
  local keep=5
  local count=0
  local file

  for file in "${ACTION_LOG_DIR}"/action-list-*.txt; do
    [[ -e "${file}" ]] || return 0
    break
  done

  for file in $(ls -1t "${ACTION_LOG_DIR}"/action-list-*.txt 2>/dev/null); do
    count=$((count + 1))
    if [[ "${count}" -gt "${keep}" ]]; then
      rm -f "${file}"
    fi
  done
}
record_action() {
  local action="$1"
  local source="$2"
  local dest="$3"
  printf '%s\t%s\t%s\n' "${action}" "${source}" "${dest}" >> "${ACTION_LIST_FILE}"
}

plan_move() {
  local source="$1"
  local dest="$2"
  log_action "Moving file: ${source} -> ${dest}"
  record_action "MOVE" "${source}" "${dest}"
  mv "${source}" "${dest}"
}

plan_rename() {
  local source="$1"
  local dest="$2"
  log_action "Renaming file: ${source} -> ${dest}"
  record_action "RENAME" "${source}" "${dest}"
  mv "${source}" "${dest}"
}

plan_remove() {
  local target="$1"
  log_action "Removing file: ${target}"
  record_action "DELETE" "${target}" ""
  rm "${target}"
}

plan_remove_dir() {
  local target="$1"
  log_action "Removing empty directory: ${target}"
  record_action "RMDIR" "${target}" ""
  rmdir "${target}"
}

build_allowed_extensions() {
  local ext
  ALLOWED_FILE_EXT_LC=()
  for ext in "${ALLOWED_FILE_EXT[@]}"; do
    ALLOWED_FILE_EXT_LC+=("$(lowercase "${ext}")")
  done
}

is_allowed_extension() {
  local filename="$1"
  local ext="${filename##*.}"
  local ext_lc
  ext_lc="$(lowercase "$ext")"
  for allowed in "${ALLOWED_FILE_EXT_LC[@]}"; do
    if [[ "$ext_lc" == "$allowed" ]]; then
      return 0
    fi
  done
  return 1
}

should_process_allowed_file() {
  local base_name="$1"
  if [[ "${base_name}" == .* ]]; then
    return 1
  fi
  is_allowed_extension "${base_name}"
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

validate_media_dirs() {
  local dir
  for dir in "${MEDIA_DIRS[@]}"; do
    if [[ -z "${dir}" || "${dir}" == "/" || "${dir}" == "." || "${dir}" == ".." ]]; then
      log_action "Invalid media directory path: ${dir}"
      return 1
    fi
    if [[ "${dir}" != /* ]]; then
      log_action "Media directory must be an absolute path: ${dir}"
      return 1
    fi
  done
  return 0
}

remove_unwanted_files() {
  local dir="$1"
  local base_name
  log_step "Removing unwanted files"

  while IFS= read -r -d '' file; do
    base_name=$(basename "${file}")
    if [[ "${base_name}" == "${SERIES_MARKER}" || "${base_name}" == "${MOVIE_MARKER}" ]]; then
      continue
    fi

    if ! is_allowed_extension "${base_name}"; then
      plan_remove "${file}"
    fi
  done < <(find_all_files "${dir}")
}

is_series_root_dir() {
  local dir="$1"
  if [[ -f "${dir}/${SERIES_MARKER}" ]]; then
    return 0
  fi
  find "${dir}" -maxdepth 1 -type d -name 'S[0-9][0-9]' -print -quit | grep -q .
}

is_movie_root_dir() {
  local dir="$1"
  if [[ -f "${dir}/${MOVIE_MARKER}" ]]; then
    return 0
  fi
  return 1
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

build_movie_roots() {
  local dir="$1"
  MOVIE_ROOTS=()
  while IFS= read -r -d '' candidate; do
    if is_movie_root_dir "$candidate"; then
      MOVIE_ROOTS+=("$candidate")
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

is_under_movie_root() {
  local path="$1"
  local root
  for root in "${MOVIE_ROOTS[@]}"; do
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

find_movie_root() {
  local dir="$1"
  local movie_name="$2"
  local movie_lc
  local root

  movie_lc="$(lowercase "$movie_name")"
  for root in "${MOVIE_ROOTS[@]}"; do
    if [[ "$(lowercase "$(basename "$root")")" == "$movie_lc" ]]; then
      echo "$root"
      return 0
    fi
  done

  echo "${dir}/${movie_name}"
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

ensure_movie_marker() {
  local movie_root="$1"
  if [[ ! -f "${movie_root}/${MOVIE_MARKER}" ]]; then
    log_action "Creating marker: ${movie_root}/${MOVIE_MARKER}"
    touch "${movie_root}/${MOVIE_MARKER}"
  fi

  if ! is_under_movie_root "${movie_root}/dummy"; then
    MOVIE_ROOTS+=("${movie_root}")
  fi
}
move_files_to_root() {
  local dir="$1"
  log_step "Moving files from nested dirs to root"
  while IFS= read -r -d '' file; do
    if is_under_series_root "$file" || is_under_movie_root "$file"; then
      continue
    fi
    if [[ "$(basename "$file")" == ".DS_Store" ]]; then
      plan_remove "${file}"
      continue
    fi
    dest="${dir}/$(basename "$file")"
    if [[ -e "$dest" ]]; then
      log_action "Skipping existing file: ${dest}"
      continue
    fi
    plan_move "${file}" "${dest}"
  done < <(find_nested_files "${dir}")
}

remove_empty_subdirs() {
  local dir="$1"
  log_step "Removing empty subdirectories"

  while IFS= read -r -d '' subdir; do
    if [[ "${subdir}" == "${dir}" ]]; then
      continue
    fi
    if [[ -f "${subdir}/${SERIES_MARKER}" || -f "${subdir}/${MOVIE_MARKER}" ]]; then
      continue
    fi
    if ! find "${subdir}" -maxdepth 1 -type f ! -name ".DS_Store" -print -quit | grep -q .; then
      if [[ -f "${subdir}/.DS_Store" ]]; then
        plan_remove "${subdir}/.DS_Store"
      fi
      plan_remove_dir "${subdir}"
      continue
    fi
    plan_remove_dir "${subdir}"
  done < <(find "${dir}" -depth -mindepth 1 -type d -empty -print0)
}

normalize_filenames() {
  local dir="$1"
  log_step "Normalizing filenames"
  while IFS= read -r -d '' file; do
    dir_name=$(dirname "${file}")
    base_name=$(basename "${file}")

    # Skip files with empty base names
    if [[ -z "${base_name}" ]]; then
      continue
    fi

    if ! should_process_allowed_file "${base_name}"; then
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
      plan_rename "${file}" "${dir_name}/${new_name}"
    fi
  done < <(find_root_files "${dir}")
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

  log_step "Organizing episode files"
  while IFS= read -r -d '' file; do
    base_name=$(basename "${file}")

    if ! should_process_allowed_file "${base_name}"; then
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

    plan_move "${file}" "${dest}"
  done < <(find_root_files "${dir}")
}

is_tv_episode_name() {
  local name="$1"
  if [[ "$name" =~ [Ss][0-9]{1,2}[Ee][0-9]{1,2} ]]; then
    return 0
  fi
  return 1
}

is_roman_numeral() {
  local token
  token="$(echo "$1" | tr '[:lower:]' '[:upper:]')"
  case "$token" in
    I|II|III|IV|V|VI|VII|VIII|IX|X|XI|XII) return 0 ;;
  esac
  return 1
}

get_movie_prefix() {
  local name="$1"
  local token
  local prefix_parts=()
  local IFS='.'

  if is_tv_episode_name "$name"; then
    return 1
  fi

  read -r -a parts <<< "$name"
  for token in "${parts[@]}"; do
    if [[ -z "$token" ]]; then
      continue
    fi
    if [[ "$token" =~ ^[0-9]+$ ]] || is_roman_numeral "$token"; then
      break
    fi
    prefix_parts+=("$token")
  done

  if [[ "${#prefix_parts[@]}" -eq 0 ]]; then
    return 1
  fi

  (IFS='.'; echo "${prefix_parts[*]}")
}

movie_root_exists() {
  local prefix="$1"
  local root
  for root in "${MOVIE_ROOTS[@]}"; do
    if [[ "$(lowercase "$(basename "$root")")" == "$(lowercase "$prefix")" ]]; then
      return 0
    fi
  done
  return 1
}

organize_movie_series() {
  local dir="$1"
  local base_name
  local name_no_ext
  local prefix
  local movie_root
  local dest
  local temp_pairs
  local temp_prefixes

  log_step "Organizing movie series"
  temp_pairs="$(mktemp -t mediacleanup.pairs.XXXXXX)"
  temp_prefixes="$(mktemp -t mediacleanup.prefixes.XXXXXX)"

  while IFS= read -r -d '' file; do
    base_name=$(basename "${file}")
    if ! should_process_allowed_file "${base_name}"; then
      continue
    fi
    name_no_ext="${base_name%.*}"
    prefix="$(get_movie_prefix "${name_no_ext}")" || continue
    printf '%s\t%s\n' "${prefix}" "${file}" >> "${temp_pairs}"
  done < <(find_root_files "${dir}")

  if [[ -s "${temp_pairs}" ]]; then
    awk -F '\t' '{count[$1]++} END {for (p in count) if (count[p] >= 2) print p}' \
      "${temp_pairs}" > "${temp_prefixes}"
  fi

  while IFS=$'\t' read -r prefix file; do
    if [[ -z "${prefix}" ]]; then
      continue
    fi

    if movie_root_exists "${prefix}" || grep -Fxq "${prefix}" "${temp_prefixes}"; then
      movie_root=$(find_movie_root "${dir}" "${prefix}")
      if [[ ! -d "${movie_root}" ]]; then
        log_action "Creating movie series folder: ${movie_root}"
        mkdir -p "${movie_root}"
      fi
      ensure_movie_marker "${movie_root}"
      dest="${movie_root}/$(basename "${file}")"
      if [[ -e "${dest}" ]]; then
        log_action "Skipping existing file: ${dest}"
        continue
      fi
      plan_move "${file}" "${dest}"
    fi
  done < "${temp_pairs}"

  rm -f "${temp_pairs}" "${temp_prefixes}"
}

run_cleanup_steps() {
  local dir="$1"
  local steps=(
    move_files_to_root
    normalize_filenames
    organize_series_files
    organize_movie_series
    remove_unwanted_files
    remove_empty_subdirs
  )

  local step
  for step in "${steps[@]}"; do
    "${step}" "${dir}"
  done
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
if ! validate_media_dirs; then
  exit 1
fi
build_allowed_extensions
init_action_logging

# Track total runtime for the cleanup run.
SECONDS=0
# Loop through each directory and call the functions
for dir in "${MEDIA_DIRS[@]}"; do
  log_dir_header "${dir}"
  build_series_roots "${dir}"
  build_movie_roots "${dir}"
  run_cleanup_steps "${dir}"
done
log_step "Cleanup complete in ${SECONDS}s"
log_step "Action list recorded at ${ACTION_LIST_FILE}"
prune_action_logs
