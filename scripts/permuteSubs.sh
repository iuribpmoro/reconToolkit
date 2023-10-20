#!/bin/bash

script_dir=$(dirname "$0")

if [ -z "$1" ]
then
    echo "Usage: ./permuteSubs.sh <SUBS_LIST>"
    exit 1
else
    aliveSubs=$1

    # Resolving and permuting

    qtd=$(wc -l $aliveSubs | cut -d ' ' -f1)

    echo "Writing permutations..."
    gotator -sub $aliveSubs -perm $script_dir/../utils/alt_words.txt -depth 1 -numbers 10 -adv -md -silent > permuted_subs.txt

    permutedQtd=$(wc -l permuted_subs.txt | cut -d ' ' -f1)
    echo "Resolving $permutedQtd subdomains..."
    puredns resolve permuted_subs.txt -r $script_dir/../utils/resolvers.txt --write resolved_subs.txt -l 30
    
    resolvedQtd=$(wc -l resolved_subs.txt | cut -d ' ' -f1)

    echo -e "\n\nFOUND $resolvedQtd SUBS:"
    echo -e "\nResults saved in resolved_subs.txt\n"

    echo -e "\nNew subs found:\n"
    cat $aliveSubs > old_aliveSubs.tmp
    cat resolved_subs.txt | anew old_aliveSubs.tmp
    rm old_aliveSubs.tmp

fi
