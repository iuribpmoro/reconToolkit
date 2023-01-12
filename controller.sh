#!/bin/bash

shopt -s extglob
_complete_path() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -f -- "$cur") )
}
complete -F _complete_path read

clear

script_dir=$(dirname "$0")

while :
do
    echo "###################################"
    echo "#             Menu                #"
    echo "###################################"
    echo "# 1) gatherAllUrls.sh             #"
    echo "# 2) gatherCnames.sh              #"
    echo "# 3) gatherSubs.sh                #"
    echo "# 4) uniqueUrls.py                #"
    echo "# 5) gatherIPs_passive.sh         #"
    echo "# 6) Exit                         #"
    echo "###################################"
    read -p "Enter your choice: " choice

    case $choice in
        1) read -p "All URLs or just the vulns? (all/vulns): " urls_choice; 
        case $urls_choice in
            all) read -e -p "Enter path to file: " -i "" path; "$script_dir"/scripts/gatherAllUrls.sh $path;;
            vulns) read -e -p "Enter path to file: " -i "" path; "$script_dir"/scripts/gatherAllUrls.sh $path -vulns;;
            *) echo "Invalid choice."; sleep 2;;
        esac;;
        2) read -e -p "Enter path to file: " -i "" path; $script_dir/scripts/gatherCnames.sh $path;;
        3) read -e -p "Enter path to file: " -i "" path; $script_dir/scripts/gatherSubs.sh $path;;
        4) read -e -p "Enter path to file: " -i "" path; read -p "Enter exception paths (separated by spaces): " exceptions;
            if [ -n "$exceptions" ]; then
                python3 $script_dir/scripts/uniqueUrls.py $path -v $exceptions;
            else
                python3 $script_dir/scripts/uniqueUrls.py $path;
            fi;;
        5) read -e -p "Enter string: " -i "" string; $script_dir/scripts/gatherIPs_passive.sh $string;;
        6) exit 0;;
        *) echo "Invalid choice."; sleep 2;;
    esac

    echo -e "\n\n\n"
done

