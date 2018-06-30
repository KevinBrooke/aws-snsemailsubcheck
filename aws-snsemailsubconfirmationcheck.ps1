# Get the SNS email subscription status of all topics and emails.
foreach ($region in aws ec2 describe-regions --output text --query 'Regions[].{output:RegionName}') {
    Write-Host "Checking SNS topics in $region" -ForegroundColor yellow
    $topics = aws sns list-topics --output text --query 'Topics[].{output:TopicArn}' --region $region
    if ($topics.length -gt 0) {
        foreach ($topic in $topics) {
            Write-Host "    SNS topic found: $topic" -ForegroundColor Green
            $subs = aws sns list-subscriptions-by-topic --topic-arn $topic --output text --query 'Subscriptions[].{output:Endpoint, output2:SubscriptionArn}' --region $region
            if ($subs.length -gt 0) {
                foreach ($sub in $subs) {
                    if ($sub.split("`t")[1] -contains "PendingConfirmation") {
                        Write-Host "        "$sub.split("`t")[0]"has not accepted the invite" -ForegroundColor Red
                    }
                    else {
                        Write-Host "        "$sub.split("`t")[0]"has accepted the invite" -ForegroundColor Green
                    }
                }
            }
            else {
                Write-Host "        No subscriptions found" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "    No SNS topics found" -ForegroundColor DarkGreen
    }
}
