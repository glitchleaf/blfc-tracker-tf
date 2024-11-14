# GoBLFC/Tracker Terraform

## Bootstrap

### AWS

This creates the role in AWS that HCP will assume to manage our resources, note
that this role has admin access by default. Probably don't give just anyone the
ability to write to this repo as it can easily be abused.

This setup only needs to happen once. Ensure you have jq and awscli (with creds
configured) then run the following, replacing the placeholders as appropriate:

```shell
ORG_NAME=hcp-org-name PROJECT_NAME=hcp-project-name bash bootstrap.sh
```

### HCP

Set the following variables in the Workspace:

```shell
TFC_AWS_PROVIDER_AUTH=true
# from the output of the last section
TFC_AWS_RUN_ROLE_ARN=arn:aws:iam::000000000000:role/hcp
# can be any region
AWS_REGION=us-west-2
```

### DNS

We'll do a partial apply to get the DNS bits in place first:

```shell
terraform apply -target 'aws_route53_record.tracker_cert_validation'
```

After this completes, grab the new zones NS records from the Route53 UI, login to your DNS provider and add an NS record there with those values to delegate to AWS.

For example, in the AWS Route53 UI this looks like:
![step one is looking up the new zones NS record](./docs/img/dns-step-1.md)
![step two is copying this values to the root names zone to delegate the name to the new zone](./docs/img/dns-step-2.md)

### Terraform

Run the full apply now to get everything deployed:

```shell
terraform apply
```

A new install of Tracker should be running but unresponsive at this point.

### Migrations

Run the migrations to get the final bits wrapped up:

```shell
# get a shell in a running ECS task
bin/exec.sh
php artisan migrate
```
