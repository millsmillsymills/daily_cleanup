# daily_cleanup
A bash script written for Mac OS intended to help automate organizing downloaded files and organize browsing history

Make the required changes to customize your deployment.

#Each entry will have a dedicated folder within the backup folder. If adding or changing these values, make sure the corresponding variables below are also adjusted.
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
