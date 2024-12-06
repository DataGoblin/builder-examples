ENV_FILE="./.env"

API_URL="https://blockchain-gateway-nebula22.nursery.reitnorf.com/config"

response=$(curl -s -H "Accept: application/json" "$API_URL")
world_address=$(echo "$response" | grep -o '"world":{[^}]*}' | grep -o '"address":"[^"]*"' | sed 's/"address":"//;s/"//')

CHAIN_ID="17069"

# If the API call didn't work - use a known world address for Nebula
if [[ -z "$world_address" ]]; then
    world_address="0x972bfea201646a87dc59f042ad91254628974f0d"
fi

sed -i "s/^WORLD_ADDRESS=.*/WORLD_ADDRESS=$world_address #Nebula World Address/" "$ENV_FILE"
sed -i "s/^CHAIN_ID=.*/CHAIN_ID=$CHAIN_ID #Garnet Chain ID/" "$ENV_FILE"