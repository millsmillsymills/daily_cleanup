#!/bin/bash
#Each entry will have a dedicated folder within the backup folder
directories=( binaries audio video archives text three_dee images utilities directories) 

#Folders and the file extensions that go into them
binaries=( dmg app pkg exe deb)
audio=( mp3 aac)
video=( mkv mp4 mpeg avi m4v mov webp)
archives=( zip tar gz 7zip tgz iso)
text=( json txt doc docx xls xlsx ppt pptx keynote pages numbers pdf epub mobi rtf)
three_dee=( blend stl 3mf collada 3ds step vrml x3d)
images=( jpeg jpg JPG png psd gif aep nef NEF svg)
utilities=( csv log cer crt gpg mobileconfig asc ovpn rdp unf)

#Where you want the backup folder located
backup_location= 
#MacOS user home folder location
user_location= 
#Your MacOS username
username= 
#Date used to create daily folders
date=$(date +"%F")

#Kill Chrome to unlock database and extract browsing history
killall Google\ Chrome
/usr/bin/sqlite3 -csv -header /Users/"$username"/Library/Application\ Support/Google/Chrome/Default/History "SELECT urls.id, urls.url, urls.title, urls.visit_count, urls.typed_count, datetime((urls.last_visit_time/1000000)-11644473600, 'unixepoch', 'localtime') AS last_visit_time, urls.hidden, datetime((visits.visit_time/1000000)-11644473600, 'unixepoch', 'localtime') AS visit_time, visits.from_visit, visits.visit_duration, visits.transition, visit_source.source FROM urls JOIN visits ON urls.id = visits.url LEFT JOIN visit_source ON visits.id = visit_source.id order by last_visit_time asc;" > "$backup_location"/"$date"/chrome_history.csv          

#Create backup location, daily directory and subdirectories
for i in "${directories[@]}"; do 
    mkdir -p "$backup_location"/"$date"/"${i}"
done

#Find and move directories
mv "$user_location/Downloads/"*/ "$backup_location"/"$date"/directories/
mv "$user_location/Desktop/"*/ "$backup_location"/"$date"/directories/

#Find and move binary files as defined in the binaries variable
for i in "${binaries[@]}"; do
    mv "$user_location/Downloads/"*.${i} "$backup_location"/"$date"/binaries/
    mv "$user_location/Desktop/"*.${i} "$backup_location"/"$date"/binaries/
done

#Find and move audio files as defined in the audio variable
for i in "${audio[@]}"; do
    mv "$user_location/Downloads/"*.${i} "$backup_location"/"$date"/audio/
    mv "$user_location/Desktop/"*.${i} "$backup_location"/"$date"/audio/
done

#Find and move video files as defined in the videos variable
for i in "${video[@]}"; do
    mv "$user_location/Downloads/"*.${i} "$backup_location"/"$date"/video/
    mv "$user_location/Desktop/"*.${i} "$backup_location"/"$date"/video/
done

#Find and move archive files as defined in the archives variable
for i in "${archives[@]}"; do
    mv "$user_location/Downloads/"*.${i} "$backup_location"/"$date"/archives/
    mv "$user_location/Desktop/"*.${i} "$backup_location"/"$date"/archives/
done

#Find and move text files as defined in the text variable
for i in "${text[@]}"; do
    mv "$user_location/Downloads/"*.${i} "$backup_location"/"$date"/text/
    mv "$user_location/Desktop/"*.${i} "$backup_location"/"$date"/text/
done

#Find and move 3d files as defined in the three_dee variable
for i in "${three_dee[@]}"; do
    mv "$user_location/Downloads/"*.${i} "$backup_location"/"$date"/three_dee/
    mv "$user_location/Desktop/"*.${i} "$backup_location"/"$date"/three_dee/
done

#Find and move image files as defined in the images variable
for i in "${images[@]}"; do
    mv "$user_location/Downloads/"*.${i} "$backup_location"/"$date"/images/
    mv "$user_location/Desktop/"*.${i} "$backup_location"/"$date"/images/
done

#Find and move utility files as defined in the utilities variable
for i in "${utilities[@]}"; do
    mv "$user_location/Downloads/"*.${i} "$backup_location"/"$date"/utilities/
    mv "$user_location/Desktop/"*.${i} "$backup_location"/"$date"/utilities/
done
