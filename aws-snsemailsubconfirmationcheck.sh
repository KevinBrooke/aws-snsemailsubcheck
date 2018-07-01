# Get the SNS email subscription status of all topics and emails.
for region in `aws ec2 describe-regions --output text | cut -f3`
do
    echo -e "\e[93mChecking SNS topics in $region"
    topics=`aws sns list-topics --output text --query 'Topics[].{output:TopicArn}' --region $region`
    if [[ ${#topics} > 0 ]]; then
        for topic in $topics
        do
            echo -e "\e[92m    SNS topic found: $topic" 
            subs=`aws sns list-subscriptions-by-topic --topic-arn $topic --output text --region $region`
            if [[ ${#subs} > 0 ]]; then
                aws sns list-subscriptions-by-topic --topic-arn $topic --output text --region $region | 
                while read sub 
                do 
                    subname=`echo $sub | cut -d ' ' -f2`
                    substatus=`echo $sub | cut -d ' ' -f5`
                    if [[ "$substatus" = *"PendingConfirmation"* ]]; then
                        echo -e "\e[31m        $subname has not accepted the invite"
                    else 
                        echo -e "\e[32m        $subname has accepted the invite" 
                    fi
                done
            else 
                echo -e "\e[31m        No subscriptions found"
            fi
        done
    else 
        echo -e "\e[32m    No SNS topics found"
    fi
done
