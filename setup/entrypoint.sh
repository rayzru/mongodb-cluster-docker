#!/bin/bash

: ${APIKEYFILE:=/config-files/user-api-key.txt}
: ${GROUPIDFILE:=/config-files/group-id.txt}
: ${USERIDFILE:=/config-files/user-id.txt}
: ${AUTOMATIONFILE:=/setup/config/deploy-replica-set.json}
: ${DEPLOYFILE:=/config-files/deploy-replica-set-patched.json}
: ${AGENTAPIKEYFILE:=/config-files/agent-api-key.txt}
: ${AGENTSFILE:=/config-files/agents.txt}
: ${USERNAME:=$(jq -r .username < /setup/config/post-unauth-users.json)}
: ${IPADDRESS:=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')}

# For some reasons API server not responding properly at the moment it starts
sleep 5

echo Setup process initiated `date '+%Y-%m-%d %H:%M:%S'`
echo User: $USERNAME

if [ ! -f $APIKEYFILE ]
then
  echo First user record not found, creating...
  curl --digest -sS \
    --header "Accept: application/json" \
    --header "Content-Type: application/json" \
    --request POST "${OPSMANAGER_HOST}/api/public/v1.0/unauth/users" \
    --data @/setup/config/post-unauth-users.json | jq -r .apiKey > $APIKEYFILE

  echo "API key aciquired: $( < $APIKEYFILE )"
fi

if [[ ! -f $GROUPIDFILE && -f $APIKEYFILE ]] 
then
echo "Creating project group $USERNAME:$(<$APIKEYFILE)"
  ### Create project group
  echo Creating GID
  curl --user "$USERNAME:$(<$APIKEYFILE)" --digest -sS \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --request POST "${OPSMANAGER_HOST}/api/public/v1.0/groups" \
  --data @/setup/config/post-groups.json > /dev/null

  ### Get group ID
  echo Getting GID
  curl --user "$USERNAME:$(<$APIKEYFILE)" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --request GET "${OPSMANAGER_HOST}/api/public/v1.0/groups" \
  --digest -sS | jq -r .results[0].id > $GROUPIDFILE

fi

# if [[ -f $GROUPIDFILE && -f $APIKEYFILE && ! -f $USERIDFILE ]] 
# then
#   ### Whitelisting is disabled, not necessary to make api calls for whitelisting
  
#   ### Get User ID
#   # echo Getting UID
#   # curl --user "$USERNAME:$(<$APIKEYFILE)" \
#   # --header "Accept: application/json" \
#   # --header "Content-Type: application/json" \
#   # --request GET "${OPSMANAGER_HOST}/api/public/v1.0/groups/$(<$GROUPIDFILE)/users" \
#   # --digest -sS | jq -r .results[0].id > $USERIDFILE

#   # echo Whitelistening $IPADDRESS
#   # ### Whitelisting
#   # curl --user "$USERNAME:$(<$APIKEYFILE)"  \
#   # --header "Accept: application/json" \
#   # --header "Content-Type: application/json" \
#   # --request POST "${OPSMANAGER_HOST}/api/public/v1.0/users/$(<$USERIDFILE)/whitelist" \
#   # --data "[{\"ipAddress\":\"$IPADDRESS\"}]"
#   # --digest -sS #| jq -r .key > $AGENTAPIKEYFILE
#   echo;;
# fi 

if [[ -f $GROUPIDFILE && -f $APIKEYFILE && ! -f $AGENTAPIKEYFILE ]] 
then
  ### Create Agent API Key
  echo Creating Agent API Key
  curl --user "$USERNAME:$(<$APIKEYFILE)"  \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --request POST "${OPSMANAGER_HOST}/api/public/v1.0/groups/$(<$GROUPIDFILE)/agentapikeys" \
  --data '{ "desc": "Agent API Key #1" }' \
  --digest -sS | jq -r .key > $AGENTAPIKEYFILE
fi

### Automation setup
if [[ -f $GROUPIDFILE && -f $APIKEYFILE && -f $AGENTAPIKEYFILE ]] 
then
  echo Provide Automation configuration

  AGENTSCOUNT=0
  
  until [ $AGENTSCOUNT -gt 0 ] 
  do
    curl --user "$USERNAME:$(<$APIKEYFILE)"  \
    --header "Accept: application/json" \
    --header "Content-Type: application/json" \
    --request GET "${OPSMANAGER_HOST}/api/public/v1.0/groups/$(<$GROUPIDFILE)/agents/AUTOMATION" \
    --digest -sS | jq . > $AGENTSFILE

    AGENTSCOUNT=$(cat $AGENTSFILE | jq .totalCount)
    AGENTSCOUNT=${AGENTSCOUNT:-0}
    if [ $AGENTSCOUNT -gt 0 ]; then
      continue
    fi
    echo Waiting for agents...
    sleep 10
  done

  echo Found $AGENTSCOUNT agents
  
  AUTOMATIONCONFING=$(cat $AUTOMATIONFILE)
  AGENTHOST=$(cat $AGENTSFILE | jq -rc .results[0].hostname)
  
  echo Using AGENT at $AGENTHOST

  AUTOMATIONCONFING=$(echo $AUTOMATIONCONFING | \
  jq --arg h "$AGENTHOST" \
  '.processes[0].hostname=$h | .processes[1].hostname=$h | .processes[2].hostname=$h | .backupVersions[0].hostname=$h | .monitoringVersions[0].hostname=$h' \
  )

  echo $AUTOMATIONCONFING | jq . > $DEPLOYFILE

  # 1) Update automation configuration
  curl --user "$USERNAME:$(<$APIKEYFILE)"  \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --request PUT "${OPSMANAGER_HOST}/api/public/v1.0/groups/$(<$GROUPIDFILE)/automationConfig" \
  --data @$DEPLOYFILE \
  --digest -sS 
  
fi

echo Setup finished
