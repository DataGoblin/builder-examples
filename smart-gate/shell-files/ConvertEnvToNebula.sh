ENV_FILE=".env"

#Colours
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

API_URL="https://blockchain-gateway-nebula.nursery.reitnorf.com/config"

response=$(curl -s -H "Accept: application/json" "$API_URL")
world_address=$(echo "$response" | grep -o '"world":{[^}]*}' | grep -o '"address":"[^"]*"' | sed 's/"address":"//;s/"//')

CHAIN_ID="17069"

# If the API call didn't work - use a known world address for Nova
if [[ -z "$world_address" ]]; then
    world_address="0x972bfea201646a87dc59f042ad91254628974f0d"
fi

sed -i "s/^WORLD_ADDRESS=.*/WORLD_ADDRESS=$world_address #Nova World Address/" "$ENV_FILE"
sed -i "s/^CHAIN_ID=.*/CHAIN_ID=$CHAIN_ID #Garnet Chain ID/" "$ENV_FILE"

printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}WORLD_ADDRESS${RESET} in ${YELLOW}.env${RESET} to ${YELLOW}Nebula${RESET} world address ${YELLOW}[$world_address]${RESET} \n\n"