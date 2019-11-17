# GoogleCertScanner
Tool for scanning Google's transparency report to fetch domains

Google provides us a very good resource for scanning SSL certificates on: https://transparencyreport.google.com/https/certificate

I was looking for a tool to scan it then decided to write my own in purely bash.

Requirements:

JQ: https://stedolan.github.io/jq/
cURL


Usage:

Syntax: ./gtr.sh <target> <subdomains> <expired-certs>
<target>: target domain e.g: google.com
<subdomains>: 1 true / 0 false
<expired-certs>: 1 true / 0 false
Example: ./gtr.sh google.com 1 0

It will save output to current working directory as well.
