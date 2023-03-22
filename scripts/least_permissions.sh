cd ..
#TF_LOG=trace terraform apply --auto-approve &> terraform.log

echo -n > temp/actions.log
cat terraform.log | grep "DEBUG: Request" > temp/raw_actions.log
while IFS= read -r line; do 
    echo ${line:113:-9} >> temp/actions.log
done < temp/raw_actions.log

sort temp/actions.log | uniq > temp/actions2.log

ACTIONS=""
FIRST=1
while IFS= read -r line; do
    if [ $FIRST -eq 1 ]
    then
        FIRST=0
    else
        ACTIONS+=$',\n'
    fi
    ACTIONS+="                \"$line\""
done < temp/actions2.log

read -r -d '' POLICY << EOM
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
$ACTIONS

            ],
            "Resource": "*"
        }
    ]
}
EOM

echo "${POLICY}" > policy.json
