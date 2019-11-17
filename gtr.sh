#!/bin/bash
##Variables
declare domain=$1
declare include_subdomains="true"
declare include_expired="true"
declare next_page="none"
declare -a results
declare url=""
declare page=1
declare total_page=0
declare count=0
declare cur_page=1
function fetchData() {
	if [[ $next_page != "none" ]]; then
    		url="https://transparencyreport.google.com/transparencyreport/api/v3/httpsreport/ct/certsearch/page?domain=$domain&include_expired=$include_expired&include_subdomains=$include_subdomains&p=$next_page"
	fi
	request=$(curl -s $url --connect-timeout 25 | tail -n +2)
	for i in {1..10}
	do
		result=$(echo $request | jq '.[][1]['$i'][1]' | sed 's/\"//g')
		if [[ $result != "null" ]]; then
			results+="$result\r\n" ## Add to array as new line
		fi
	done
	if [[ $next_page == "none" ]]; then
		total_page=$(echo $request | jq '.[][3][4]')
	fi
	cur_page=$(echo $request | jq '.[][3][3]')
	if [[ $cur_page == $page ]]; then
		next_page=$(echo $request | jq '.[][3][1]' | sed 's/\"//g')
		echo -ne "Fetched page $page/$total_page..."\\r
		(( ++page ))
	fi
}

function searchGoogle() {
	echo "-----------------------------------------------------"
	echo "Searching $domain on Google transparency report"
	echo "Subdomain searching: $include_subdomains"
	echo "Expired certificate searching: $include_expired"
	echo "-----------------------------------------------------"
	echo ""
	echo "Search started..."
	echo ""
	url="https://transparencyreport.google.com/transparencyreport/api/v3/httpsreport/ct/certsearch?domain=$domain&include_expired=$include_expired&include_subdomains=$include_subdomains"
	##Initial fetching
	fetchData
	while [[ $next_page != "null" ]]
	do
		fetchData
	done
	filename="GC-$domain-$(date "+%Y.%m.%d-%H.%M").txt"
	echo "-----------------------------------------------------"
	echo ""
	echo "Results:"
	echo -e $results | sort -u | tee -a $filename
	echo ""
	count=$(echo -e $results | sort -u | wc -l)
	echo "-----------------------------------------------------"
	echo "Saved output on: $filename"
	echo "Total domains found: $count"
}

echo "-----------------------------------------------------"
echo "Google certificate scanner by nukedx"
if [[ $1 == "--help" ]]; then
	echo "Syntax: $0 <target> <subdomains> <expired-certs>"
	echo "<target>: target domain e.g: google.com"
	echo "<subdomains>: 1 true / 0 false"
	echo "<expired-certs>: 1 true / 0 false"
	echo "Example: $0 google.com 1 0"
	echo "-----------------------------------------------------"
	exit
fi
if [[ "$#" -ne 1 ]];  then
	if [[ $2 -eq 0 ]]; then
		include_subdomains="false"
	fi
        if [[ "$#" -ne 2 ]]; then
                if [[ $3 -eq 0 ]]; then
               	        include_expired="false"
       	        fi
        fi
fi
searchGoogle
