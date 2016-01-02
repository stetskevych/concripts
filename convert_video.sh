#!/bin/bash
# Convert Canon MOV files to a sane format (mkv/h264/aac). 4-8 times reduction in size.
# Version 20151225. Merry Christmas.

dir=( '/media/victoria/DATA/Photos' '/media/victoria/DATA/Photos from PC' )
log='/media/victoria/DATA/convert_video.log'
touch "$log"
export ext='MOV'
export newext='mkv'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export NC='\033[0m'

# log everything
exec &> >(tee -a $log)

convert_video() {
fullpath="$1"
pathname="${fullpath%/*}"
filename="${fullpath##*/}"
newfilename="${filename%.$ext}.$newext"

if ! cd "$pathname"; then
	echo -e "${RED}ERROR: Cannot enter $pathname directory.${NC}"
	exit 1
fi

if [[ -f "$newfilename" ]]; then
	echo -e "${RED}ERROR: Destination file ${pathname}/${newfilename} exists.${NC}"
	exit 1
fi

echo -e "${GREEN}Converting $fullpath to $newfilename ${NC}"
#gotrap() { echo -e "${GREEN}Removing partially encoded file $pathname/$newfilename ${NC}"; rm "${pathname}/$newfilename" }
#trap gotrap EXIT
export AV_LOG_FORCE_COLOR=1
ffmpeg -i "$filename" -vcodec h264 -crf 23 -pix_fmt yuvj420p -profile:v high -level 4 -acodec aac -b:a 160k -strict -2 "$newfilename" < /dev/null || exit 10

# Check resulting file presence
if  ! [[ -f "$newfilename" ]]; then
	echo -e "${RED}ERROR: Destination file ${pathname}/${newfilename} does not exist after ffmpeg call, aborting!${NC}"
	exit 1
fi

# Check resulting file size
if [[ "$(du -m "$newfilename" | cut -d$'\t' -f1)" -lt 1 ]]; then
	echo -e "${RED}WARNING: Destination file ${pathname}/${newfilename} is less than 1MB, not deleting source!${NC}"
	echo -e "${GREEN}Done${NC}"
	return
fi

echo -e "${GREEN}Removing source file $filename ${NC}"
rm -v "$filename"
echo -e "${GREEN}Done${NC}"
}

find "${dir[@]}" -type f -name "*.$ext" -print | while read -r fullpath; do convert_video "$fullpath"; done
