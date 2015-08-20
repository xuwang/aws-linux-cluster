#!/usr/bin/env bash

# Replace AWS-ACCOUNT with aws account number in *.tf and *.json files. Can be used 
# to form policy documents, resource names etc, with the aws account number as part of a string.

# AWS account number - getting it from an existing user resource
# 
AWS_PROFILE=${AWS_PROFILE:-mycluster}
S3_BUCKET_PREFIX=${S3_BUCKET_PREFIX:-''}

# S3_BUCKET_PREFIX is used as a prefix when creating various s3 bucket. If no default is giveng, use aws account number
if [ -z "$S3_BUCKET_PREFIX" ];
then
  echo "Getting AWS account number..."
  S3_BUCKET_PREFIX=$(aws --profile ${AWS_PROFILE} iam get-user | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')
fi

files=$(grep -s -l AWS-ACCOUNT -r $@)
if [ "X$files" != "X" ];
then
  for f in $files
  do
    perl -p -i -e "s/AWS-ACCOUNT/$S3_BUCKET_PREFIX/g" $f
  done
fi

