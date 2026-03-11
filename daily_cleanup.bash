#!/bin/bash
set -euo pipefail
shopt -s nullglob nocaseglob

##CONFIGURABLES###############
username=changeme

# File extensions per category
# shellcheck disable=SC2034
binaries=(dmg app pkg exe deb safariextz)
# shellcheck disable=SC2034
audio=(mp3 aac)
# shellcheck disable=SC2034
video=(mkv mp4 mpeg avi m4v mov)
# shellcheck disable=SC2034
archives=(zip tar gz 7zip tgz iso xz 7z)
# shellcheck disable=SC2034
text=(json txt doc docx xls xlsx ppt pptx keynote pages numbers pdf epub mobi rtf srt html)
# shellcheck disable=SC2034
three_dee=(blend stl 3mf collada 3ds step vrml x3d fdg)
# shellcheck disable=SC2034
images=(jpeg jpg png psd gif aep nef svg webp)
# shellcheck disable=SC2034
utilities=(csv log cer crt gpg mobileconfig asc ovpn rdp unf ttf)
# shellcheck disable=SC2034
virtual_machines=(vmwarevm vmx vmfs vmdk nvram vmem vmsn vmsd ova ovf)

# Each entry gets a subdirectory; web and directories are handled separately from extension-based categories
categories=(binaries audio video archives text three_dee images utilities virtual_machines web directories)

backup_date=$(date '+%Y.%m.%d')

user_location=/Users/"$username"
archive_location="$user_location"/Archives
daily_dir="$archive_location"/"$backup_date"

source_dirs=("$user_location/Desktop" "$user_location/Downloads")

##VARIABLES###################

chrome_sql="$user_location/Library/Application Support/Google/Chrome/Default/History"
firefox_profile_dir="$user_location/Library/Application Support/Firefox/Profiles"

##FUNCTIONS###################

validate() {
	if [[ "$username" == "changeme" ]] || [[ ! -d "/Users/$username" ]]; then
		echo "ERROR: Set 'username' to your macOS username in daily_cleanup.bash" >&2
		exit 1
	fi

	if ! command -v mmv &>/dev/null; then
		echo "ERROR: mmv is not installed. Install with: brew install mmv" >&2
		exit 1
	fi

	if ! command -v sqlite3 &>/dev/null; then
		echo "ERROR: sqlite3 is not installed" >&2
		exit 1
	fi
}

# Lowercase all filenames (best-effort on case-insensitive macOS where globs already match any case)
init_transform() {
	for dir in "${source_dirs[@]}"; do
		local -a dir_files=("$dir"/*)
		if [[ ${#dir_files[@]} -gt 0 ]]; then
			mmv -r "$dir/*" '#l1' 2>/dev/null ||
				echo "WARNING: Could not lowercase filenames in $dir (may be case-insensitive FS)" >&2
		fi
	done
}

stage_backup() {
	for i in "${categories[@]}"; do
		if ! mkdir -p "$daily_dir/${i}"; then
			echo "ERROR: Failed to create directory: $daily_dir/${i}" >&2
			exit 1
		fi
	done
}

# Send SIGTERM and wait for the process to exit (up to 10s)
kill_browser() {
	local process_name=$1
	if pgrep -x "$process_name" >/dev/null 2>&1; then
		if killall "$process_name" 2>/dev/null; then
			for _ in $(seq 1 10); do
				pgrep -x "$process_name" >/dev/null 2>&1 || break
				sleep 1
			done
		fi
	fi
}

# Kill browser processes and export today's browsing history to CSV
init_web_backup() {
	kill_browser "Google Chrome"

	if [[ -f "$chrome_sql" ]]; then
		if sqlite3 -csv -header "$chrome_sql" \
			"SELECT urls.id, urls.url, urls.title, urls.visit_count, urls.typed_count, \
			datetime((urls.last_visit_time/1000000)-11644473600, 'unixepoch', 'localtime') AS last_visit_time, \
			urls.hidden, \
			datetime((visits.visit_time/1000000)-11644473600, 'unixepoch', 'localtime') AS visit_time, \
			visits.from_visit, visits.visit_duration, visits.transition, visit_source.source \
			FROM urls JOIN visits ON urls.id = visits.url \
			LEFT JOIN visit_source ON visits.id = visit_source.id \
			WHERE datetime((urls.last_visit_time/1000000)-11644473600, 'unixepoch', 'localtime') >= date('now', 'localtime') \
			ORDER BY last_visit_time ASC;" \
			>"$daily_dir/web/chrome_history.csv"; then
			if [[ ! -s "$daily_dir/web/chrome_history.csv" ]]; then
				echo "WARNING: No Chrome history found for today" >&2
			fi
		else
			echo "WARNING: Failed to read Chrome history database — is Chrome fully closed?" >&2
		fi
	else
		echo "WARNING: Chrome history database not found" >&2
	fi

	kill_browser "firefox"

	if [[ -d "$firefox_profile_dir" ]]; then
		firefox_profile=$(find "$firefox_profile_dir" -mindepth 1 -maxdepth 1 -type d -print -quit)
		if [[ -n "$firefox_profile" ]] && [[ -f "$firefox_profile/places.sqlite" ]]; then
			sqlite3 "$firefox_profile/places.sqlite" \
				"SELECT strftime('%d.%m.%Y %H:%M:%S', visit_date/1000000, 'unixepoch', 'localtime'), url \
				FROM moz_places, moz_historyvisits \
				WHERE moz_places.id = moz_historyvisits.place_id \
				AND visit_date > strftime('%s','now','start of day','localtime') * 1000000 \
				ORDER BY visit_date;" \
				>"$daily_dir/web/firefox_history.csv" ||
				echo "WARNING: Failed to extract Firefox history from $firefox_profile/places.sqlite — is Firefox fully closed?" >&2
		else
			echo "WARNING: No Firefox profile found" >&2
		fi
	else
		echo "WARNING: Firefox profiles directory not found" >&2
	fi
}

init_directory_backup() {
	for src in "${source_dirs[@]}"; do
		for dir in "$src"/*/; do
			mv "$dir" "$daily_dir/directories/" ||
				echo "WARNING: Failed to move directory: $dir" >&2
		done
	done
}

# Move files matching extensions in a given array to a target category directory
move_files() {
	local -n extensions=$1
	local category=$2

	for ext in "${extensions[@]}"; do
		for src in "${source_dirs[@]}"; do
			local -a files=("$src/"*."$ext")
			if [[ ${#files[@]} -gt 0 ]]; then
				mv "${files[@]}" "$daily_dir/$category/" ||
					echo "WARNING: Failed to move .$ext files from $src" >&2
			fi
		done
	done
}

init_backup() {
	for cat in "${categories[@]}"; do
		[[ "$cat" == "web" || "$cat" == "directories" ]] && continue
		move_files "$cat" "$cat"
	done
}

validate
init_transform
stage_backup
init_web_backup
init_directory_backup
init_backup
