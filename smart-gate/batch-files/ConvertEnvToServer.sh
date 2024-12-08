ENV_FILE=".env"

SERVER=$1

#COLORS
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

API_URL="https://blockchain-gateway-$SERVER.nursery.reitnorf.com/config"

response=$(curl -s -H "Accept: application/json" "$API_URL")
world_address=$(echo "$response" | grep -o '"world":{[^}]*}' | grep -o '"address":"[^"]*"' | sed 's/"address":"//;s/"//')
RPC_URL=$(echo "$response" | grep -o '"default":{[^}]*}' | grep -o '"http":"[^"]*"' | sed 's/"http":"//;s/"//')

CHAIN_ID="17069"

# If the API call didn't work - use a known world address for Nebula
if [[ -z "$world_address" ]]; then
    world_address="0x972bfea201646a87dc59f042ad91254628974f0d"
fi

# If the API call didn't work - use a known RPC URL for Nebula
if [[ -z "$RPC_URL" ]]; then
    RPC_URL="https://garnet-rpc.dev.evefrontier.tech"
fi

sed -i "s/^WORLD_ADDRESS=.*/WORLD_ADDRESS=$world_address #${SERVER} World Address/" "$ENV_FILE"
sed -i "s/^CHAIN_ID=.*/CHAIN_ID=$CHAIN_ID #Garnet Chain ID/" "$ENV_FILE"
sed -i "s|^RPC_URL=.*|RPC_URL=$RPC_URL #${SERVER} RPC URL|" "$ENV_FILE"

printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}WORLD_ADDRESS${RESET} in ${YELLOW}.env${RESET} to ${YELLOW}${SERVER}${RESET} ${YELLOW}[$world_address]${RESET} \n\n"
printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}RPC_URL${RESET} in ${YELLOW}.env${RESET} to ${YELLOW}${SERVER}${RESET} ${YELLOW}[$RPC_URL]${RESET}\n\n"