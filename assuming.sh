#!/bin/bash
  
role_id=$1
role_name=$2
external_id=$3

if [ $1 = "clean" ];
then
        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_SESSION_TOKEN
        echo "Role cleaned, you are now `aws sts get-caller-identity | jq -r \".Arn\"`"
        exit 0
fi


if [ $# -lt 2 ];
then
        echo "Usage: $0 <role_id> <role_name> [<external_id>]"
        exit 1
fi

if [ $# -eq 2 ];
then
        echo "Assuming $role_name with id $role_id"
        res=`aws sts assume-role --role-arn arn:aws:iam::$role_id:role/$role_name --role-session-name test1`
else
        echo "Assuming $role_name with id $role_id and external id of $external_id"
        res=`aws sts assume-role --role-arn arn:aws:iam::$role_id:role/$role_name --external-id $external_id --role-session-name test1`
fi


if [[ $res == "" ]];
then
        echo "[-] Error, exiting"
        exit 1
fi


export AWS_ACCESS_KEY_ID=`echo $res | jq -r ".Credentials.AccessKeyId"`
export AWS_SECRET_ACCESS_KEY=`echo $res | jq -r ".Credentials.SecretAccessKey"`
export AWS_SESSION_TOKEN=`echo $res | jq -r ".Credentials.SessionToken"`

echo "[+] You are now `aws sts get-caller-identity | jq -r \".Arn\"`"