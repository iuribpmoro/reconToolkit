#!/bin/bash

script_dir=$(dirname "$0")

source $script_dir/../utils/progressBar.sh

if [ -z "$1" ]
then
    echo "Usage: ./gatherSubs.sh <DOMAINS_LIST>"
    exit 1
fi

aliveDomains=$1
total=$(wc -l $aliveDomains)
current=0

echo -e "\n=========== Gather Subs ===========\n"

for domain in $(cat $aliveDomains);do
    show_progress $current $total

    echo -e "\n\n--------- FINDING SUBS FOR $domain ---------"

    echo "Running subfinder..."
    subfinder -d $domain -o subfinder.txt -all -config ~/.config/subfinder/provider-config.yaml >/dev/null 2> /dev/null
    [ -f "./subfinder.txt" ] && qtd=$(wc -l subfinder.txt | cut -d ' ' -f1) && cat subfinder.txt | anew $domain-subs.txt > /dev/null && rm subfinder.txt && echo -e "Found $qtd subs\n"
   
    echo "Running sublist3r..."
    sublist3r -d $domain -o sublister.txt >/dev/null 2> /dev/null
    [ -f "./sublister.txt" ] && newQtd=$(comm -13 $domain-subs.txt sublister.txt | wc -l) && cat sublister.txt | anew $domain-subs.txt > /dev/null && rm sublister.txt && echo -e "Found $newQtd new subs\n"

    echo "Running amass..."
    amass enum -active -brute -d $domain -config ~/.config/amass/config.ini -oA amass -silent
    [ -f "./amass.txt" ] && newQtd=$(comm -13 $domain-subs.txt amass.txt | wc -l) && sort -u amass.txt | anew $domain-subs.txt > /dev/null && rm ./amass.* && echo -e "Found $newQtd new subs\n"

    echo "Running assetfinder..."
    assetfinder -subs-only $domain > assetfinder.txt
    [ -f "./assetfinder.txt" ] && newQtd=$(comm -13 $domain-subs.txt assetfinder.txt | wc -l) && cat assetfinder.txt | grep $domain | anew $domain-subs.txt > /dev/null && rm assetfinder.txt && echo -e "Found $newQtd new subs\n"


    # Resolving and permuting

    qtd=$(wc -l $domain-subs.txt | cut -d ' ' -f1)
    echo "Resolving $qtd subdomains..."
    puredns resolve $domain-subs.txt -r $script_dir/../utils/resolvers.txt --write $domain-resolved_subs.txt

    echo "Writing permutations..."
    gotator -sub $domain-resolved_subs.txt -perm $script_dir/../utils/alt_words.txt -depth 1 -numbers 10 -adv -md -silent > $domain-permuted_subs.txt

    qtd=$(wc -l $domain-permuted_subs.txt | cut -d ' ' -f1)
    echo "Resolving $qtd subdomains..."
    puredns resolve $domain-permuted_subs.txt -r $script_dir/../utils/resolvers.txt --write $domain-finalSubs.txt
    
    totalSubs=$(wc -l $domain-finalSubs.txt | cut -d ' ' -f1)

    echo -e "\n\nFOUND $totalSubs SUBS:"
    echo -e "\nResults saved in $domain-finalSubs.txt\n"
    cat $domain-finalSubs.txt
    cat $domain-finalSubs.txt | anew finalSubs.txt

    mkdir -p $domain
    mv $domain-* $domain

    current=$(( $current + 1))
done

show_progress $current $total
