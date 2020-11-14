#!/bin/bash
#Usage: ./jsextractor.js <folder-name> < <js-file>
folder=$1
GREEN="\e[92m"
WHITE='\033[1;37m'
echo -e "${GREEN}[*] This script will extract all urls from provided JS files!"
printf "\n"
while read js;
do
        echo -e "${WHITE}[+] Running on $js"
        python3 /root/tools/LinkFinder/linkfinder.py -i $js -o cli
        printf "\n"
done | tee $folder/PATHSfromjs.txt
cat $folder/PATHSfromjs.txt | perl -ne 'print unless $seen{$_}++' | egrep -v '(\.svg|\.css|\.png|\.jpg|\.jpeg|\.wolf|\.gif)' >> $folder/pathsfromjs.txt
rm $folder/PATHSfromjs.txt
echo -e "${GREEN}[*] Extraction complete!!"
echo -e "${GREEN}[*] Extracted urls saved to $folder/pathsfromjs.txt!"

echo -e "${WHITE}[+] Creating wordlist from $folder/pathsfromjs.txt"

for i in `seq 1 8`
do
        cat $folder/pathsfromjs.txt | grep "^/" | cut -d "/" -f $i | sort -u >> /tmp/words.txt
done

cat /tmp/words.txt | egrep -v '(\-|\_|^[A-Z]|\;|\:\{)' | sort -u > $folder/${folder}-specific-wordlist.txt
echo -e "${GREEN}[*] Done! Check $folder/${folder}-specific-wordlist.txt"
