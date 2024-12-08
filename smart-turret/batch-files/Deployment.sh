#FILES
ENV_FILE="./.env"
MUD_CONFIG_FILE="./mud.config.ts"
CONSTANTS_FILE="./src/systems/constants.sol"

#COLORS
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

printf "${YELLOW}EVE Frontier Builder Example Quickstart:${RESET}\n\n"

read -p "Please insert your private key: " PRIVATE_KEY

sed -i "s/^PRIVATE_KEY=.*/PRIVATE_KEY=$PRIVATE_KEY/" "$ENV_FILE"

printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}PRIVATE_KEY${RESET} in ${YELLOW}.env${RESET} \n\n"

read -p "Please insert your namespace: " NAMESPACE

sed -i "s/^bytes14 constant SMART_GATE_DEPLOYMENT_NAMESPACE.*/bytes14 constant SMART_GATE_DEPLOYMENT_NAMESPACE = \"$NAMESPACE\";/" "$CONSTANTS_FILE"
sed -i "s/^  namespace.*/  namespace: \"$NAMESPACE\",/" "$MUD_CONFIG_FILE"


printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}DEPLOYMENT_NAMESPACE${RESET} in ${YELLOW}$CONSTANTS_FILE${RESET} and ${YELLOW}namespace${RESET} in ${YELLOW}$MUD_CONFIG_FILE${RESET} \n\n"


printf "Which ${YELLOW}server${RESET} do you want to deploy to?\n"
select sr in "Nebula" "Nova" "Local"; do
    case $sr in 
        Nebula ) pnpm env-nebula; break;;
        Nova ) pnpm env-nova; break;;
        Local ) pnpm env-local; break;;
    esac
done


pnpm deploy:local

printf "\n${GREEN}[COMPLETED]${RESET} ${YELLOW}DEPLOYED CONTRACTS${RESET}\n\n"

printf "Do you want to ${YELLOW}Configure the example${RESET}?\n"
select sr in "Yes" "No"; do
    case $sr in 
        Yes ) break;;
        No ) exit;;
    esac
done

read -p "Please insert your source smart gate ID: " SOURCE_GATE

sed -i "s/^SOURCE_GATE_ID.*/SOURCE_GATE_ID=$SOURCE_GATE/" "$ENV_FILE"

printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}SOURCE_GATE_ID${RESET} in ${YELLOW}.env${RESET} \n\n"

read -p "Please insert your destination smart gate ID: " DESTINATION_GATE

sed -i "s/^DESTINATION.*/DESTINATION_GATE_ID=$DESTINATION_GATE/" "$ENV_FILE"

printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}DESTINATION_GATE_ID${RESET} in ${YELLOW}.env${RESET} \n\n"

read -p "Please insert your allowed corp ID: " CORP_ID

sed -i "s/^ALLOWED_CORP_ID.*/ALLOWED_CORP_ID=$CORP_ID/" "$ENV_FILE"

printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}ALLOWED_CORP_ID${RESET} in ${YELLOW}.env${RESET} \n\n"

pnpm configure-smart-gates

printf "\n${GREEN}[COMPLETED] Run ${YELLOW}configure-smart-gates${RESET} script \n\n"