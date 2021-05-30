#!/bin/bash

# Description: Get a simple unique list of caronavirus exposure site suburbs with the number of cases for each suburb from the official website https://www.coronavirus.vic.gov.au/exposure-sites
# Author: Ray Marken
# Date: 303030/05/2021

curl 'https://www.coronavirus.vic.gov.au/sdp-ckan?resource_id=afb52611-6061-4a2b-9110-74c920bede77&limit=10000' --compressed -s | grep -oE '"Suburb":"[^"]+"' | awk -F':' '{print $2}' | sort | uniq -c | awk -F'"' '{print $2 ":" $1}' | column --table -s ":"
