#!/bin/bash

function usage() {
  echo "Usage: $0 [-d domain] [-s server] [-w wordlist]"
  echo "  -d domain: The target domain (default: inlanefreight.htb)"
  echo "  -s server: The DNS server to use for enumeration (default: 10.129.177.97)"
  echo "  -w wordlist: The wordlist file for DNS brute-forcing (default: ./hosts.txt)"
}

function zone_transfer() {
  local domain=$1
  local server=$2
  dig axfr $domain @$server | grep A | awk '{print $1}' | grep $domain | sed 's/.$//' | sort -u
}

function bruteforce() {
  local subdomain=$1
  local server=$2
  local wordlist=$3
  for line in $(cat $wordlist); do
    dig $line.$subdomain @$server | grep -v ';\|SOA' | sed -r '/^\s*$/d' | grep $line
  done
}

# Parse command-line arguments
domain="inlanefreight.htb"
server="10.129.177.97"
wordlist="./hosts.txt"
while getopts "hd:s:w:" opt; do
  case ${opt} in
    d )
      domain=$OPTARG
      ;;
    s )
      server=$OPTARG
      ;;
    w )
      wordlist=$OPTARG
      ;;
    h )
      usage
      exit 0
      ;;
    \? )
      usage
      exit 1
      ;;
  esac
done

echo "Trying to make Zone Transfers in the main domain and subdomains..."
main_subs=$(zone_transfer $domain $server)
echo "$main_subs" | tee ztSubs.txt

for sub in $main_subs; do
  echo "Trying to make Zone Transfer for subdomain $sub..."
  sub_subs=$(zone_transfer $sub $server)
  echo "$sub_subs" | tee -a $sub-ztSubs.txt

  if [[ -z $sub_subs ]]; then
    echo "Zone Transfer failed for subdomain $sub. Adding to notTransferable.txt..."
    echo $sub >> notTransferable.txt
  fi
done

echo "Brute-forcing subdomains that don't allow Zone Transfers..."
for sub in $(cat notTransferable.txt); do
  echo "Brute-forcing subdomain $sub..."
  bruteforce $sub $server $wordlist | tee -a $sub-btSubs.txt
done

echo "Done!"
