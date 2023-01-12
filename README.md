# Recon Toolkit

A reconnaissance toolkit for pentesters and bug hunters to gather IPs, subdomains, endpoints and CNAMEs.

## Scripts

### Gather All URLs

This one gathers URLs from Web Applications through both spidering (with Katana) and Wayback Machine (with waybackurls).
Optionally, also allows to filter the outputed URLs so to see just the one's who matches some pattern related to Vulns (with gf patterns).

#### Requirements

- Katana
  - ```go install github.com/projectdiscovery/katana/cmd/katana@latest```
- WaybackURLs
  - ```go install github.com/tomnomnom/waybackurls@latest```
- Gf
  - ```go install -v github.com/tomnomnom/gf@master ```
- Anew
  - ```go install -v github.com/tomnomnom/anew@latest```

#### Usage

```
Usage: ./gatherAllUrls.sh <SUBS_LIST> [-vulns]
```

---


### Gather IPs - Passive

#### Requirements
- API Keys for Shodan, Censys and ZoomEye

- Shodan CLI configuration
  - ```pip3 install shodan```
  - ```shodan init <API_KEY>```
  
- Censys CLI configuration
  - ```pip3 install censys```
  - ```censys config```
  
- Update the zoomeyeSearch function to use your API Key

#### Usage

```
Usage: ./scripts/gatherIPs_passive.sh [options] <IP or NETWORK>

Options:
  -h, --help      Show this help message and exit
  -s, --shodan    Query Shodan for information about a host
  -c, --censys    Query Censys for information about a host
  -z, --zoomeye   Query ZoomEye for information about a host
  no option        Run all the above services
```

---

### Gather Subdomains

#### Requirements

- [Golang](https://go.dev/doc/install)
- Subfinder
  - ```go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest```
  - Configure the API Keys file at ~/.config/subfinder/provider-config.yaml
- [Sublist3r](https://github.com/aboul3la/Sublist3r)
- Amass
  - ```go install -v github.com/OWASP/Amass/v3/...@master```
  - Configure the API Keys file at ~/.config/amass/config.ini
- Assetfinder
  - ```go install -v github.com/tomnomnom/assetfinder@master```
- PureDNS
  - ```go install github.com/d3mondev/puredns/v2@latest```
- Gotator
  - ```go install github.com/Josue87/gotator@latest```
- Anew
  - ```go install -v github.com/tomnomnom/anew@latest```
  
#### Usage

```
Usage: ./scripts/gatherSubs.sh <DOMAINS_FILE>
```