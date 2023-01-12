#!/bin/bash

shodanSearch () {
  echo -e "\n========================================"
  echo "                 SHODAN                 "
  echo -e "========================================"

  inputIp=$1

  containsSlash=$(echo $inputIp | grep '/')
  if [ -z "$containsSlash" ]; then
    echo -e "\n============ $inputIp ==============\n"
    echo "$inputIp - " >> shodan_results.txt
    shodan host $inputIp | grep / | sed 's/^ *//g'
  else
    result=$(shodan search net:$inputIp --fields ip_str,port --separator ,)

    sorted_result=$(echo "$result" | sort -t, -k1,1)

    current_ip=""

    IFS=$'\n'
    for i in $(echo "$sorted_result")
    do
            IP=$(echo $i | awk -F, '{print $1}')
            PORT=$(echo $i | awk -F, '{print $2}')
            
            if [ "$IP" != "$current_ip" ]; then
                echo -e "\n============ $IP ==============\n"
                echo "$IP - " >> shodan_results.txt
                current_ip=$IP
            fi
            echo $PORT
            echo $PORT >> shodan_results.txt
    done
  fi
  echo ""
}

censysSearch () {
  echo -e "\n========================================"
  echo "                 CENSYS                 "
  echo -e "========================================\n"

  inputIp=$1
  
  response=$(censys search "ip:$inputIp")

  matches=$(echo $response | jq -c '.[]')

  if [ -z "$matches" ]; then 
    return
  fi

  declare -A portsByIP

  readarray -t matches_array <<< "$matches"

  for match in "${matches_array[@]}"; do

    match=$(echo $match | jq '.')
    ip=$(echo $match | jq -r '.ip')
    services=$(echo $match | jq -c '.services[]')

    readarray -t services_array <<< "$services"

    for service in "${services_array[@]}"; do
      service=$(echo $service | jq '.')
      service_name=$(echo $service | jq -r '.service_name')
      transport_protocol=$(echo $service | jq -r '.transport_protocol')
      port=$(echo $service | jq -r '.port')
      portsByIP["$ip"]="${portsByIP[$ip]}$port/$transport_protocol $service_name \n"
    done

  done

  for ip in $(echo "${!portsByIP[@]}" | tr ' ' '\n' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4); do
    echo "============ $ip ============"
    echo -e "$(echo -e "${portsByIP[$ip]}" | sort -n -k 1,1 -t ' ' )\n"

    echo -e "$ip - $(echo -e "${portsByIP[$ip]}" | sort -n -k 1,1 -t ' ' | tr -d '\n' )\n" >> censys_results.txt
  done
}

zoomeyeSearch () {
  echo -e "========================================"
  echo "                ZOOMEYE                 "
  echo -e "========================================\n"

  inputIp=$1

  zoomeyeApiKey=""

  response=$(curl -H "API-KEY: $zoomeyeApiKey" -s "https://api.zoomeye.org/host/search?query=$inputIp")

  matches=$(echo $response | jq -c '.matches[]')

  if [ -z "$matches" ]; then 
    return
  fi

  declare -A portsByIP

  readarray -t matches_array <<< "$matches"

  for match in "${matches_array[@]}"; do
    match=$(echo $match | jq '.')
    ip=$(echo $match | jq -r '.ip')
    ports=$(echo $match | jq -c '.portinfo')
    readarray -t ports_array <<< "$ports"
    for port in "${ports_array[@]}"; do
      service=$(echo $port | jq -r '.service')
      banner=$(echo $port | jq -r '.banner')
      port=$(echo $port | jq -r '.port')
      portsByIP["$ip"]="${portsByIP[$ip]}$port $service \n"
    done
  done

  for ip in $(echo "${!portsByIP[@]}" | tr ' ' '\n' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4); do
    echo "============ $ip ============"
    echo -e "$(echo -e "${portsByIP[$ip]}" | sort -n -k 1,1 -t ' ' )\n"

    echo -e "$ip - $(echo -e "${portsByIP[$ip]}" | sort -n -k 1,1 -t ' ' | tr -d '\n' )\n" >> zoomeye_results.txt
  done
}


show_help() {
    echo -e "\nUsage: $0 [options] <IP or NETWORK>"
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo "  -s, --shodan    Query Shodan for information about a host"
    echo "  -c, --censys    Query Censys for information about a host"
    echo "  -z, --zoomeye   Query ZoomEye for information about a host"
    echo -e "  no option        Run all the above services\n"
}

run_all() {
    shodanSearch "$1"
    censysSearch "$1"
    zoomeyeSearch "$1"
}

if [ -z "$1" ];then
  show_help
fi

while [[ $# -gt 0 ]]
do
    echo -e "\n============ Gather IPs ===========\n"
    key="$1"

    case $key in
        -h|--help)
        show_help
        exit
        ;;
        -s|--shodan)
        shodanSearch "$2"
        shift # past argument
        ;;
        -c|--censys)
        censysSearch "$2"
        shift # past argument
        ;;
        -z|--zoomeye)
        query_zoomeye "$2"
        shift # past argument
        ;;
        *)
        if [[ $# -eq 1 ]]; then
            run_all "$1"
            exit
        else
            echo "Unknown option: $1"
            show_help
            exit 1
        fi
        ;;
    esac
    shift # past argument or value
done
