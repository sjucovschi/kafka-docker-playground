#!/bin/ksh

set -e

if [ ! -f $aws_cli ]
then
    print "<?xml version=\"1.0\"?>"
    print "<items>"
        print "<item arg=\"\" valid=\"no\">"
        print "<title>⚠️ aws cli $aws_cli is not installed !</title>"
        print "<subtitle>Make sure to install it</subtitle>"
        print "</item>"
    print "</items>"
    return
fi

print "<?xml version=\"1.0\"?>"
print "<items>"
for row in $($aws_cli cloudformation list-stacks --stack-status-filter CREATE_COMPLETE | /usr/local/bin/jq '[.StackSummaries | .[] | {StackName: .StackName, CreationTime: .CreationTime, TemplateDescription: .TemplateDescription, StackId: .StackId }]' | /usr/local/bin/jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | /usr/local/bin/jq -r ${1}
    }

    StackName=$(echo $(_jq '.StackName'))
    CreationTime=$(echo $(_jq '.CreationTime'))
    StackId=$(echo $(_jq '.StackId'))

    print "<item uid=\"${StackName}\" arg=\"$StackName\" valid=\"yes\">"
    print "<title>$StackName</title>"
    print "<subtitle>🕐 $CreationTime</subtitle>"
    print "<icon>aws.png</icon>"
    print "</item>"
done
print "</items>"

exit 0