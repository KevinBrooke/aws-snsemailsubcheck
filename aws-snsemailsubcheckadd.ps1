# Verify SNS Subscriptions on all topics in all regions.
param(
    [string]$subemail
)

if (!$subemail)
{
    Write-Host "    " 
    Write-Host "Usage:" 
    Write-Host "    " 
    Write-Host "    .\script.ps1 -subemail <emailaddress>"
    Write-Host "    " 
    Write-Host "    subemail = the email address you want to subscribe to all SNS topics." 
    Write-Host "    " 
    break
}

foreach ($region in aws ec2 describe-regions --output text --query 'Regions[].{output:RegionName}') {
    Write-Host "Checking SNS topics in $region" -ForegroundColor yellow
    $topics = aws sns list-topics --output text --query 'Topics[].{output:TopicArn}' --region $region
    if ($topics.length -gt 0) {
        foreach ($topic in $topics) {
            Write-Host "    SNS topic found: $topic" -ForegroundColor Green
            $subs = aws sns list-subscriptions-by-topic --topic-arn $topic --output text --query 'Subscriptions[].{output:Endpoint}' --region $region
            
            if ($subs -contains $subemail) {
                Write-Host "        "$subemail" is already subscribed" -ForegroundColor Green
            }
            else {
                Write-Host "        "$subemail" is not subscribed, adding" -ForegroundColor Red
                aws sns subscribe --topic-arn $topic --protocol email --notification-endpoint $subemail --region $region | out-null
            }
        }
    }
    else {
        Write-Host "    No SNS topics found" -ForegroundColor DarkGreen
    }
}

$subemail = "" 