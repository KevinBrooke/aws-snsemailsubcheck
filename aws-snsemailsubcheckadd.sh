# Verify SNS Subscriptions on all topics in all regions.
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

while getopts "e:" opt; do
  case ${opt} in
    e ) email=$OPTARG;;
    \? )
        echo -e "${cDYellow}\nInvalid option: $OPTARG\n" 1>&2
        echo -e "${cDYellow}Usage: script -e <emailaddress>"
        exit 0
        ;;
  esac
done

if [[ -z "$email" ]]; then
    echo -e "${cDYellow}\nInvalid option: $OPTARG\n" 1>&2
    echo -e "${cDYellow}Usage: script -e <emailaddress>"
    exit 0
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
            if [[ $subs = *"$email"* ]]; then
                echo -e "${cGreen}        $email is already subscribed"
            else 
                echo -e "${cRed}        $email is not subscribed, adding" 
                aws sns subscribe --topic-arn $topic --protocol email --notification-endpoint $email --region $region > /dev/null
            fi
        done
    else 
        echo -e "${cGreen}    No SNS topics found"
    fi
done
echo -e "${cNone}"