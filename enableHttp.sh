#!/bin/bash

export EXT_DNS=dev.$(gcloud compute forwarding-rules list | grep IP_ADDRESS -m 1 | awk '{print $2}' | sed 's/\./-/g').nip.io
echo $EXT_DNS

export AUTH_TOKEN=$(gcloud auth print-access-token)

gcloud compute target-http-proxies create apigee-proxy-map-target-proxy \
    --url-map=projects/$GOOGLE_CLOUD_PROJECT/global/urlMaps/apigee-proxy-map

gcloud compute forwarding-rules create apigee-proxy-http-lb-rule \
    --load-balancing-scheme=EXTERNAL \
    --address=apigee-proxy-external-ip \
    --global \
    --target-http-proxy=apigee-proxy-map-target-proxy \
    --ports=80

curl --request PATCH \
  'https://apigee.googleapis.com/v1/organizations/qwiklabs-gcp-01-fabc02f5ada6/envgroups/eval-group?updateMask=hostnames' \
  --header "Authorization: Bearer "${AUTH_TOKEN}"" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{"name":"eval-groups","hostnames":['\""${EXT_DNS}"\"']}' \
  --compressed


