# Get the SNS email subscription status of all topics and emails.
# OSX handles colours differently so we sort that here.
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]] || [[ "$unamestr" == 'FreeBSD' ]]; then
    cNone='\e[00m'
    cRed='\e[31m'
    cGreen='\e[32m'
    cDGreen='\e[92m'
    cDYellow='\e[93m'
elif [[ "$unamestr" == 'Darwin' ]]; then
    cNone='\033[00m'
    cRed='\033[31m'
    cGreen='\033[32m'
    cDGreen='\033[92m'
    cDYellow='\033[93m'
fi

for region in `aws ec2 describe-regions --output text | cut -f3`
do
    echo -e "${cDYellow}Checking SNS topics in $region"
    topics=`aws sns list-topics --output text --query 'Topics[].{output:TopicArn}' --region $region`
    if [[ ${#topics} > 0 ]]; then
        for topic in $topics
        do
            echo -e "${cDGreen}    SNS topic found: $topic" 
            subs=`aws sns list-subscriptions-by-topic --topic-arn $topic --output text --region $region`
            if [[ ${#subs} > 0 ]]; then
                aws sns list-subscriptions-by-topic --topic-arn $topic --output text --region $region | 
                while read sub 
                do 
                    subname=`echo $sub | cut -d ' ' -f2`
                    substatus=`echo $sub | cut -d ' ' -f5`
                    if [[ "$substatus" = *"PendingConfirmation"* ]]; then
                        echo -e "${cRed}        $subname has not accepted the invite"
                    else 
                        echo -e "${cGreen}        $subname has accepted the invite" 
                    fi
                done
            else 
                echo -e "${cRed}        No subscriptions found"
            fi
        done
    else 
        echo -e "${cGreen}    No SNS topics found"
    fi
done
echo -e "${cNone}"