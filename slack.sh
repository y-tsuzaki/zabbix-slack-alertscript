#!/bin/bash

# Slack incoming web-hook URL and user name
url=''          # example: https://hooks.slack.com/services/QW3R7Y/D34DC0D3/BCADFGabcDEF123
username='Zabbix'

## Values received by this script:
# To = $1 (Slack channel or user to send the message to, specified in the Zabbix web interface; "@username" or "#channel")
# Subject = $2 (usually either PROBLEM or RECOVERY/OK)
# Message = $3 (whatever message the Zabbix action sends, preferably something like "Zabbix server is unreachable for 5 minutes - Zabbix server (127.0.0.1)")
# url = $4 (optional url to replace the hardcoded one. useful when multiple groups have seperate slack environments)
# proxy = $5 (optional proxy, including port)

# Get the Slack channel or user ($1) and Zabbix subject ($2 - hopefully either PROBLEM or RECOVERY/OK)
to="$1"
subject="$2"
severity="$6"


# Change message emoji depending on the subject - smile (RECOVERY/OK), frowning (PROBLEM), or ghost (for everything else)
recoversub='^RECOVER(Y|ED)?'
if [[ "$subject" =~ ${recoversub} ]]; then
       emoji=':smile:'
elif [[ "$subject" =~ '^OK' ]]; then
       emoji=':smile:'
elif [[ "$subject" =~ '^PROBLEM' ]]; then
       emoji=':frowning:'
else
       emoji=':ghost:'
fi

# Change color depending on the severity
if [[ "$subject" =~ ${recoversub}  || "$subject" == 'OK'  ]]; then
        color='good'
else
        if [ "$severity" == 'Disaster' ]; then
                color='danger'
        elif [ "$severity" == 'High' ]; then
                color='danger'
        elif [ "$severity" == 'Average' ]; then
                color='danger'
        elif [ "$severity" == 'Warning' ]; then
                color='warning'
        elif [ "$severity" == 'Information' ]; then
                color='#AAAAAA'
        else
                color='#AAAAAA'
        fi
fi

# The message that we want to send to Slack is the message that Zabbix actually sent us ($3)
message="$3"

# in case a 4th parameter is set, we will use it for the url
if [[ $4 != "" ]] ; then
  url=$4
fi

# in case a 5th parameter is set, we will us it for the proxy settings
proxy=${5-""}
if [[ "$proxy" != "" ]] ; then
  proxy=" -x $proxy "
fi

# Build our JSON payload and send it as a POST request to the Slack incoming web-hook URL
payload="payload={\"channel\": \"${to//\"/\\\"}\", \"username\": \"${username//\"/\\\"}\", \"attachments\" : [{ \"title\" : \"${subject} \", \"text\" : \"${message}\", \"color\": \"${color}\"}], \"icon_emoji\": \"${emoji}\"}"
curl $proxy -m 5 --data-urlencode "${payload}" $url -A 'zabbix-slack-alertscript / https://github.com/ericoc/zabbix-slack-alertscript'
