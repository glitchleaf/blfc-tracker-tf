#!/usr/bin/env bash

set -euo pipefail

E() {
    echo "$@" > /dev/stderr
    exit 1
}

## Setup

hash aws &>/dev/null || E 'awscli not found, please install it'
hash jq &>/dev/null || E 'jq not found, please install it'

[ -n "${ORG_NAME:-}" ] || E 'ORG_NAME must be set to the HCP org name'
[ -n "${PROJECT_NAME:-}" ] || E 'PROJECT_NAME must be set to the HCP org projects name'
ROLE_NAME="${ROLE_NAME:-hcp}"

## OIDC Provider
# shellcheck disable=SC2016 # false positive
OIDC_PROVIDERS="$(aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[?contains(Arn, `app.terraform.io`)].Arn')"
if [ "$(jq length <<<"$OIDC_PROVIDERS")" == "0" ]; then
    OIDC_PROVIDER_ARN="$(aws iam create-open-id-connect-provider --url 'https://app.terraform.io' --client-id-list 'aws.workload.identity' --query 'OpenIDConnectProviderArn') --output text"
else
    OIDC_PROVIDER_ARN="$(jq -r first <<<"$OIDC_PROVIDERS")"
fi
echo "oidc_arn: $OIDC_PROVIDER_ARN"

## IAM Role

ASSUME_ROLE_DOC="$(mktemp)"
jq -c . >"$ASSUME_ROLE_DOC" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "$OIDC_PROVIDER_ARN" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": { "app.terraform.io:aud": "aws.workload.identity" },
      "StringLike": { "app.terraform.io:sub": "organization:$ORG_NAME:project:$PROJECT_NAME:workspace:*:run_phase:*" }
    }
  }]
}
EOF

ROLE="$(aws iam get-role --role-name "$ROLE_NAME" || echo '')"
if [ "$ROLE" == "" ]; then
    ROLE="$(aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document "file://$ASSUME_ROLE_DOC")"
fi
echo "role_arn: $(jq -r .Role.Arn <<<"$ROLE")"

## IAM Policy

aws iam attach-role-policy --role-name hcp --policy-arn 'arn:aws:iam::aws:policy/AdministratorAccess'

echo 'success'
