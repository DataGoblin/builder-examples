API_URL="https://blockchain-gateway-nova.nursery.reitnorf.com/config"

response=$(curl -s -H "Accept: application/json" "$API_URL")
world_address=$(echo "$response" | grep -o '"world":{[^}]*}' | grep -o '"address":"[^"]*"' | sed 's/"address":"//;s/"//')

# Print the extracted address
echo "World Address: $world_address"
