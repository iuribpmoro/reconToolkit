#!/bin/bash

function usage {
  echo "Usage: $0 -d DOMAIN -s DNSSERVER -w WORDLIST"
  echo "Example: $0 -d inlanefreight.htb -s 10.129.177.97 -w hosts.txt"
}

function do_zone_transfer {
  local domain=$1
  local dnsserver=$2
  echo "Trying to make Zone Transfer in the domain $domain"
  dig axfr $domain @$dnsserver | grep A | awk '{print $1}' | grep $domain | sed 's/.$//' | sort -u | tee ztSubs.txt
}

function do_zone_transfer_sub {
  local sub=$1
  local domain=$2
  local dnsserver=$3
  echo "Trying to make Zone Transfer in the subdomain $sub"
  dig axfr $sub @$dnsserver | grep A | awk '{print $1}' | grep $domain | sed 's/.$//' | sort -u | tee -a $sub-ztSubs.txt
  [ -s $sub-ztSubs.txt ] || echo $sub >> notTransferable.txt
}

function do_bruteforce_sub {
  local sub=$1
  local dnsserver=$2
  local wordlist=$3
  echo -e "\nBruteforcing $sub"
  while read line; do
    dig $line.$sub @$dnsserver | grep -v ';\|SOA' | sed -r '/^\s*$/d' | grep $line | tee -a subs-btSubs.txt
  done < $wordlist
}

# Parse arguments
while getopts "d:s:w:" opt; do
  case ${opt} in
    d )
      DOMAIN=$OPTARG
      ;;
    s )
      DNSSERVER=$OPTARG
      ;;
    w )
      WORDLIST=$OPTARG
      ;;
    \? )
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Check required arguments
if [ -z "$DOMAIN" ] || [ -z "$DNSSERVER" ] || [ -z "$WORDLIST" ]; then
  usage
  exit 1
fi

echo -e "Starting DNS enumeration for domain $DOMAIN and DNS server $DNSSERVER using wordlist $WORDLIST\n"

# Do zone transfers
do_zone_transfer $DOMAIN $DNSSERVER

for SUB in $(cat ztSubs.txt); do
  do_zone_transfer_sub $SUB $DOMAIN $DNSSERVER
done

cat *-ztSubs.txt ztSubs.txt | sort -u > final-ztSubs.txt

# Do bruteforces
echo -e "\n\nStarting bruteforcing subs that don't allow Zone Transfers..."

for SUB in $(cat notTransferable.txt); do
  do_bruteforce_sub $SUB $DNSSERVER $WORDLIST
done

echo -e "\nFinished! Check the following files:"
echo "final-ztSubs.txt - List of subdomains obtained via Zone Transfer"
echo "subs-btSubs.txt - List of subdomains obtained via bruteforce"
