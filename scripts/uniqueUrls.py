import argparse
import urllib.parse

def get_unique_urls(file_path, valid_paths):
    seen = set()
    with open(file_path, 'r') as f:
        for line in f:
            url = line.strip()
            parsed_url = urllib.parse.urlparse(url)
            path = parsed_url.path
            hostname = parsed_url.hostname
            query = urllib.parse.parse_qs(parsed_url.query)
            query_params = set(query.keys())

            if valid_paths:
                for valid_path in valid_paths:
                    if path.startswith(valid_path):
                        path = valid_path
                        break

            unique_url = hostname + path + str(query_params)
            if unique_url not in seen:
                seen.add(unique_url)
                print(url)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="This script will read a file containing one URL per line and outputs the unique URLs by comparing the hostname, path, and parameter names. An optional list of paths can be passed using -v flag and only applies the exclusion rule so when the path is passed, it disconsiders not only the last directory but all directories after what you specified.")
    parser.add_argument('file_path', help="Path to the file containing one URL per line")
    parser.add_argument('-v','--valid_paths', nargs='*', help='Paths to apply the exclusion rule')

    args = parser.parse_args()
    file_path = args.file_path
    valid_paths = args.valid_paths
    get_unique_urls(file_path, valid_paths)
