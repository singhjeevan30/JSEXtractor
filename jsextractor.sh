#!/bin/bash
#Usage: ./jsextractor.js <folder-name> < <js-file>

folder=$1
GREEN="\e[92m"
WHITE='\033[1;37m'
RED='\033[1;31m'

display_usage(){
	echo -e "\n${GREEN}This script is a wrapper around Linkfinder!\n"
	echo -e "${WHITE}Usage: \n$0 [domain-name] < [jsfiles.txt]"
	echo -e "${WHITE}domain-name  :   folder where output and curated wordlist will be saved!"
	echo -e "${WHITE}jsfiles.txt  :   file containing javascript endpoints/urls!\n"
	}

if [[ ($1 == "--help") || $1 == "-h" ]]
then
	display_usage
	exit 0
fi

if [[ ! $1 ]]
then
	echo -e "$RED[-]Domain name wasn't provided!"
	display_usage
	exit 1
fi

if [[ ! -d $folder ]]
then
        mkdir $1
        echo -e "${GREEN}[+]Directory named $1 created!"
else
	echo -e "${RED}[-]Directory already exists!"
fi
echo -e "$GREEN[+]Results would now be saved in $folder!"

if [[ -t 0 ]]
then
	echo -e "$RED[-]Input wasn't provided!"
	display_usage
	exit 1
fi

echo -e "${GREEN}[*] This script will extract all urls from provided JS files!"
printf "\n"
while read js;
do
        echo -e "${WHITE}[+] Running on $js"
        python3 /root/tools/LinkFinder/linkfinder.py -i $js -o cli
        printf "\n"
done | tee $folder/PATHSfromjs.txt
cat $folder/PATHSfromjs.txt | perl -ne 'print unless $seen{$_}++' | egrep -v '(\.svg|\.css|\.png|\.jpg|\.jpeg|\.woff|\.gif)' >> $folder/pathsfromjs.txt
rm $folder/PATHSfromjs.txt
echo -e "${GREEN}[*] Extraction complete!!"
echo -e "${GREEN}[*] Extracted urls saved to $folder/pathsfromjs.txt!"

echo -e "${WHITE}[+] Creating wordlist from $folder/pathsfromjs.txt"

for i in `seq 1 8`
do
        cat $folder/pathsfromjs.txt | grep "^/" | cut -d "/" -f $i | sort -u >> /tmp/words.txt
done

cat /tmp/words.txt | egrep -v '(\:|\-|\_|^[A-Z]|\;|\:\{|\+|\,|\#|\@)' | sort -u > $folder/${folder}-specific-wordlist.txt
echo -e "${GREEN}[*] Done! Check $folder/${folder}-specific-wordlist.txt"
