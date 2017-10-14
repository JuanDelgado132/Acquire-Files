#!/bin/bash

#Author: Juan Delgado

#When copying and getting the MD5 and SHA1 sums of files I kept getting an error about the System and Volume and volumeindexerguid. So I made the error messages
#go into /dev/null. I was able to ensure that filenames that come up with spaced when searched by find are replaced with a dash(-), so there should not be any problem moving files over.





DIRNAME=usbPoint

#Send the error to null. This will happen if you have made the directory before. It will not affect the script in any way
sudo mkdir /media/$DIRNAME 2>/dev/null
sudo mount /dev/sdb1 /media/$DIRNAME 2>/dev/null

organizeFiles() {
	fileType=$(file $1)
	fileName=$(basename $1)
	name="${fileName%.*}"

	if [[ "$fileType" =~ "JPEG image" || $fileType =~ "PNG image" || $fileType =~ "GIF image" ]]; then
		cp "$1" $caseDir/evidence/images
		md5sum $caseDir/evidence/images/"$fileName" > $caseDir/evidence/images/"$name".md5
		sha1sum $caseDir/evidence/images/"$fileName" > $caseDir/evidence/images/"$name".sha1
	elif [[ "$fileType" =~ "Microsoft Excel 2007+" || "$fileType" =~ "Microsoft PowerPoint 2007+" || $fileType =~ "Composite Document File" || "$fileType" =~ "Microsoft WinWord" || "$fileType" =~ "Microsoft Word 2007+" || "$fileType" =~ "ASCII text" ]]; then
		cp "$1" $caseDir/evidence/documents
		md5sum $caseDir/evidence/documents/"$fileName" > $caseDir/evidence/documents/"$name".md5
	       	sha1sum $caseDir/evidence/documents/"$fileName" > $caseDir/evidence/documents/"$name".sha1
	elif [[ "$fileType" =~ "executable" || "$fileType" =~ "PE32 executable" ]]; then
		cp "$1" $caseDir/evidence/programs 2>/dev/null
	       	md5sum $caseDir/evidence/programs/"$fileName" > $caseDir/evidence/programs/"$name".md5
		sha1sum $caseDir/evidence/programs/"$fileName" > $caseDir/evidence/programs/"$name".sha1
	elif [[ "$fileType" =~ "HTML document" ]]; then
		cp "$1" $caseDir/evidence/web
		md5sum $caseDir/evidence/web/"$fileName" > $caseDir/evidence/web/"$name".md5
		sha1sum $caseDir/evidence/web/"$fileName" > $caseDir/evidence/web/"$name".sha1 
	else
		cp "$1" $caseDir/misc 2>/dev/null
		md5sum $caseDir/misc/"$fileName" > $caseDir/misc/"$name".md5 2>/dev/null
		sha1sum $caseDir/misc/"$fileName" > $caseDir/misc/"$name".sha1 2>/dev/null
	fi
}

#This print summary includes the md5 and sha1 files also. Except for the part that says total number of files copied.
printSummary() {
	echo "Case Number: $caseNum \n"
	echo "Total number of files copied: $totalFiles"
	echo "Total number of images: $(ls $caseDir/evidence/images | wc -l)"
	echo "Total number of documents: $(ls $caseDir/evidence/documents | wc -l)"
	echo "Total number of programs: $(ls $caseDir/evidence/programs | wc -l)"
	echo "Total number of web files: $(ls $caseDir/evidence/web | wc -l)"
	echo "Total number of other files: $(ls $caseDir/misc | wc -l)"
}

read -p "Enter the case number: " caseNum
#Save the directory path. It will always be saved in the home directory.
#Start counter for total num of files.
caseDir=$HOME/$caseNum
totalFile=0
#Ensure that another copy of the case file does not exist. If it does stop script and exit with an error code of 2
if [ -d $caseDir ]; then
	echo "A directory for $caseDir already exists. Script will now exit."
	exit 2
else
	echo "Creating the necessary directory and sub directories"
	mkdir -p $caseDir/{reports,evidence,misc,evidence/images,evidence/documents,evidence/programs/,evidence/web}
fi

echo "Will beging to copy and calculate hash values of the files. Please wait...."

#ensure any file that has a space will be replaced. Any errors that say it can be renamed have will be thrown out. I put it since I kept gettomg cannot rename System and Volume
find /media/$DIRNAME -type f -print0 | xargs -0 rename 's/ /-/g' 2>/dev/null 
#Acquire all files from the attached USB. 
files=$(find /media/$DIRNAME -type f )
for tempFiles in $files 
do
	let totalFile=$totalFile+1
	organizeFiles $tempFiles

done

echo "Operation has completed below are the findings."


printSummary

#Unmount the USB from the mound point created and delete the directory that the USB was mounted on.
sudo umount /media/$DIRNAME
sudo rmdir /media/$DIRNAME
exit 0;
