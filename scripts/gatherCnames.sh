echo -e "\n========== Gather CNAMEs ==========\n"

if [ -z "$1" ]
then
    echo "Usage: ./gatherCnames.sh <SUBS_LIST>"
    exit 1
else

    subsList=$1
    for sub in $(cat $subsList);do dig $sub | grep CNAME | grep IN | awk -v s="$sub" 'BEGIN { OFS = "\t->\t" }{print s"\t->\t"$1,$5}'; done

fi
