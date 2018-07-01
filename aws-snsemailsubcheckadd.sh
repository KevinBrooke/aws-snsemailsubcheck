# Verify SNS Subscriptions on all topics in all regions.
while getopts "e:" opt; do
  case ${opt} in
    e ) email=$OPTARG;;
    \? )
        echo -e "\e[93m\nInvalid option: $OPTARG\n" 1>&2
        echo -e "\e[93mUsage: script -e <emailaddress>"
        exit 0
        ;;
  esac
done

if [[ -z "$email" ]]; then
    echo -e "\e[93m\nInvalid option: $OPTARG\n" 1>&2
    echo -e "\e[93mUsage: script -e <emailaddress>"
    exit 0
fi

for region in `aws ec2 describe-regions --output text | cut -f3`
do
    echo -e "\e[93mChecking SNS topics in $region"
    topics=`aws sns list-topics --output text --query 'Topics[].{output:TopicArn}' --region $region`
    if [[ ${#topics} > 0 ]]; then
        for topic in $topics
        do
            echo -e "\e[92m    SNS topic found: $topic" 
            subs=`aws sns list-subscriptions-by-topic --topic-arn $topic --output text --region $region`
            if [[ $subs = *"$email"* ]]; then
                echo -e "\e[32m        $email is already subscribed"
            else 
                echo -e "\e[31m        $email is not subscribed, adding" 
                aws sns subscribe --topic-arn $topic --protocol email --notification-endpoint $email --region $region > /dev/null
            fi
        done
    else 
        echo -e "\e[32m    No SNS topics found"
    fi
done