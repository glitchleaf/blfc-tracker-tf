#!/usr/bin/env bash

set -euo pipefail

IP_ADDRESS="$(curl -s 'https://api.ipify.org')"
# hacks to appease shellcheck, terraform will have swapped in the vars for long before bash sees them
domain_name=""
hosted_zone_id=""

cat <<EOF >record-batch.json
{
  "Comment": "Upserting task IP",
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "${domain_name}",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [{ "Value": "$IP_ADDRESS" }]
    }
  }]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id "${hosted_zone_id}" --change-batch file://record-batch.json
