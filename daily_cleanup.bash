#!/bin/bash
##CONFIGURABLES#############################################################################################################

#MacOS username
username=changeme
#Each entry will have a dedicated folder within the backup folder
directories=( binaries audio video archives text three_dee images utilities web directories) 
#Folders and the file extensions that go into them
binaries=( dmg app pkg exe deb safariextz)
audio=( mp3 aac)
video=( mkv mp4 mpeg avi m4v mov webp)
archives=( zip tar gz 7zip tgz iso xz html)
text=( json txt doc docx xls xlsx ppt pptx keynote pages numbers pdf epub mobi rtf srt)
three_dee=( blend stl 3mf collada 3ds step vrml x3d)
images=( jpeg jpg JPG png psd gif aep nef NEF svg)
utilities=( csv log cer crt gpg mobileconfig asc ovpn rdp unf ttf ovpn)

#Where you want the backup folder located
archive_location=/Users/"$username"/Archives
#Today's backup
backup_location="$backup_location"/"$date"
#MacOS user home folder location
user_location=/Users/"$username"
#Date format used to create daily folders
date=$(date '+%Y.%m.%d')


##VARIABLES#################################################################################################################


#Web data Locations
#Chrome SQL location
chrome_sql="$user_location"/Library/Application\ Support/Google/Chrome/Default/History
#Firefox SQL location and profile name. Variable finds Firefox profile folder that used in the last 24 hours
firefox_profile=$(find "$user_location"/Library/Application\ Support/Firefox/Profiles -maxdepth 1 -mtime -1)

#Functions####################################################################################################################

#Transform filenames in ~/Downloads and ~/Desktop to lowercase
init_transform() {
    /usr/local/bin/mmv -r "$user_location/Desktop/*" '#l1'
    /usr/local/bin/mmv -r "$user_location/Downloads/*" '#l1'
}

#Create backup location, daily directory and subdirectories
stage_backup() {
    for i in "${directories[@]}"; do 
        mkdir -p "$archive_location"/"$date"/"${i}"
    done
}

#Kill browser processes and archive browsing history
init_web_backup() {
#Kill Chrome to unlock database and extract browsing history
    killall Google\ Chrome && sleep 5 && sqlite3 -csv -header "$chrome_sql" "SELECT urls.id, urls.url, urls.title, urls.visit_count, urls.typed_count, datetime((urls.last_visit_time/1000000)-11644473600, 'unixepoch', 'localtime') AS last_visit_time, urls.hidden, datetime((visits.visit_time/1000000)-11644473600, 'unixepoch', 'localtime') AS visit_time, visits.from_visit, visits.visit_duration, visits.transition, visit_source.source FROM urls JOIN visits ON urls.id = visits.url LEFT JOIN visit_source ON visits.id = visit_source.id order by last_visit_time asc;" | grep "$(date '+%Y-%m-%d')" > "$archive_location"/"$date"/web/chrome_history.csv          

#Kill Firefox to unlock database and extract browsing history
    killall firefox && sleep 5 && sqlite3 "$firefox_profile"/places.sqlite "SELECT strftime('$(date '+%d.%m.%Y') %H:%M:%S', visit_date/1000000, 'unixepoch', 'localtime'),url FROM moz_places, moz_historyvisits WHERE moz_places.id = moz_historyvisits.place_id ORDER BY visit_date;" > "$archive_location"/"$date"/web/firefox_history.csv
}

#Find and move directories
init_directory_backup() {
    mv "$user_location/Downloads/*/" "$backup_location"/directories/ 2> /dev/null
    mv "$user_location/Desktop/*/" "$backup_location"/directories/ 2> /dev/null
}

#Begin file moves 
init_backup() {
#Find and move binary files as defined in the binaries variable
    for i in "${binaries[@]}"; do
        mv "$user_location/Downloads/"*."${i}" "$archive_location"/"$date"/binaries/ 2> /dev/null
        mv "$user_location/Desktop/"*."${i}" "$archive_location"/"$date"/binaries/ 2> /dev/null
    done

#Find and move audio files as defined in the audio variable
    for i in "${audio[@]}"; do
        mv "$user_location/Downloads/"*."${i}" "$archive_location"/"$date"/audio/ 2> /dev/null
        mv "$user_location/Desktop/"*."${i}" "$archive_location"/"$date"/audio/ 2> /dev/null
    done

#Find and move video files as defined in the videos variable
    for i in "${video[@]}"; do
        mv "$user_location/Downloads/"*."${i}" "$archive_location"/"$date"/video/ 2> /dev/null
        mv "$user_location/Desktop/"*."${i}" "$archive_location"/"$date"/video/ 2> /dev/null
    done

#Find and move archive files as defined in the archives variable
    for i in "${archives[@]}"; do
        mv "$user_location/Downloads/"*."${i}" "$archive_location"/"$date"/archives/ 2> /dev/null
        mv "$user_location/Desktop/"*."${i}" "$archive_location"/"$date"/archives/ 2> /dev/null
    done

#Find and move text files as defined in the text variable
    for i in "${text[@]}"; do
        mv "$user_location/Downloads/"*."${i}" "$archive_location"/"$date"/text/ 2> /dev/null
        mv "$user_location/Desktop/"*."${i}" "$archive_location"/"$date"/text/ 2> /dev/null
    done

#Find and move 3d files as defined in the three_dee variable
    for i in "${three_dee[@]}"; do
        mv "$user_location/Downloads/"*."${i}" "$archive_location"/"$date"/three_dee/ 2> /dev/null
        mv "$user_location/Desktop/"*."${i}" "$archive_location"/"$date"/three_dee/ 2> /dev/null
    done

#Find and move image files as defined in the images variable
    for i in "${images[@]}"; do
        mv "$user_location/Downloads/"*."${i}" "$archive_location"/"$date"/images/ 2> /dev/null
        mv "$user_location/Desktop/"*."${i}" "$archive_location"/"$date"/images/ 2> /dev/null
    done

#Find and move utility files as defined in the utilities variable
    for i in "${utilities[@]}"; do
        mv "$user_location/Downloads/"*."${i}" "$archive_location"/"$date"/utilities/ 2> /dev/null
        mv "$user_location/Desktop/"*."${i}" "$archive_location"/"$date"/utilities/ 2> /dev/null
    done
}

init_transform
stage_backup
init_web_backup
init_directory_backup
init_backup