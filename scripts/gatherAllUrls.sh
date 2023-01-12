#!/bin/bash

script_dir=$(dirname "$0")

source $script_dir/../utils/progressBar.sh

if [ -z "$1" ]
then
    echo "Usage: ./gatherAllUrls.sh <SUBS_LIST> [-vulns]"
    exit 1
else
    aliveSubs=$1
    vulns=false
    if [ "$2" == "-vulns" ]; then
        vulns=true
    fi
    total=$(wc -l $1)
    current=0
    touch finalFilteredUrls.txt
    echo -e "\n========= Gather All URLs =========\n"
    for sub in $(cat $aliveSubs);do
        show_progress $current $total
        parsedSub=$(echo $sub | cut -d "/" -f3)
        katana -u $sub -kf all -fs fqdn -silent -o katana-tmp.txt > /dev/null
        waybackurls $sub | grep $sub > wayback-tmp.txt
        if [ "$vulns" = true ]; then
            cat katana-tmp.txt | gf vulns | anew finalUrls.txt > /dev/null
            cat wayback-tmp.txt | gf vulns | anew finalUrls.txt > /dev/null
        else
            cat katana-tmp.txt | anew finalUrls.txt > /dev/null
            cat wayback-tmp.txt | anew finalUrls.txt > /dev/null
        fi
        cat finalUrls.txt | grep -Ev "jpg|jpeg|png|svg|ico|mp4|gif|css|js" | anew finalFilteredUrls.txt > /dev/null
        current=$(( $current + 1))
    done
    show_progress $current $total
fi
