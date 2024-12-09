#Files
ENV_FILE="./.env"
MUD_CONFIG_FILE="./mud.config.ts"
CONSTANTS_FILE="./src/systems/constants.sol"

#Colours
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

#Welcome
printf "${YELLOW}EVE Frontier Builder Smart Gate Example Quickstart:${RESET}\n\n"

function validate_input(){
    local INPUT=""
    read -p "Please insert your $1: " INPUT
    local MIN_LENGTH="$2"
    while true 
    do
        if [[ -z "$INPUT" ]]; then
            printf "${YELLOW}[WARNING]${RESET}"
            read -p "You did not input anything. Please insert your $1: " INPUT
        else
            if [[ ${#INPUT} -ge $MIN_LENGTH ]]; then
                break;
            else
                echo "${YELLOW}[WARNING]${RESET}"
                read -p "Inputted key was not long enough. Please insert your $1: " INPUT
            fi
        fi
    done

    echo $INPUT
}

printf "Which ${YELLOW}server${RESET} do you want to deploy to?\n"
select sr in "Nebula [Main]" "Nova [Sandbox]" "Local [Your Computer]"; do
    case $sr in 
        "Nebula [Main]" ) pnpm env-nebula; CHOSEN_SERVER="NEBULA"; break;;
        "Nova [Sandbox]" ) pnpm env-nova; CHOSEN_SERVER="NOVA"; break;;
        "Local [Your Computer]" ) pnpm env-local; CHOSEN_SERVER="LOCAL"; break;;
    esac
done

# If it's local then we can skip some steps and set them to default
if [ "$CHOSEN_SERVER" = "LOCAL" ]; then
    #Define the defaults
    PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    NAMESPACE="test"

    #Make the changes
    sed -i "s/^PRIVATE_KEY=.*/PRIVATE_KEY=$PRIVATE_KEY/" "$ENV_FILE"

    printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}PRIVATE_KEY${RESET} in ${YELLOW}.env${RESET} to ${YELLOW}DEFAULT${RESET} [$PRIVATE_KEY]\n\n"
    sed -i "s/^bytes14 constant SMART_GATE_DEPLOYMENT_NAMESPACE.*/bytes14 constant SMART_GATE_DEPLOYMENT_NAMESPACE = \"$NAMESPACE\";/" "$CONSTANTS_FILE"
    sed -i "s/^  namespace.*/  namespace: \"$NAMESPACE\",/" "$MUD_CONFIG_FILE"

    printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}DEPLOYMENT_NAMESPACE${RESET} in ${YELLOW}$CONSTANTS_FILE${RESET} and ${YELLOW}namespace${RESET} in ${YELLOW}$MUD_CONFIG_FILE${RESET} to ${YELLOW}DEFAULT${RESET} [$NAMESPACE]\n\n"

else
    PRIVATE_KEY=$(validate_input "Private Key" "20")

    sed -i "s/^PRIVATE_KEY=.*/PRIVATE_KEY=$PRIVATE_KEY/" "$ENV_FILE"

    printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}PRIVATE_KEY${RESET} in ${YELLOW}.env${RESET} \n\n"

    NAMESPACE=$(validate_input "Namespace" "2")

    sed -i "s/^bytes14 constant SMART_GATE_DEPLOYMENT_NAMESPACE.*/bytes14 constant SMART_GATE_DEPLOYMENT_NAMESPACE = \"$NAMESPACE\";/" "$CONSTANTS_FILE"
    sed -i "s/^  namespace.*/  namespace: \"$NAMESPACE\",/" "$MUD_CONFIG_FILE"

    printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}DEPLOYMENT_NAMESPACE${RESET} in ${YELLOW}$CONSTANTS_FILE${RESET} and ${YELLOW}namespace${RESET} in ${YELLOW}$MUD_CONFIG_FILE${RESET} \n\n"
fi

pnpm deploy:local

printf "\n${GREEN}[COMPLETED]${RESET} ${YELLOW}DEPLOYED CONTRACTS${RESET}\n\n"

printf "Do you want to ${YELLOW}Configure the example${RESET}?\n"
select sr in "Yes" "No"; do
    case $sr in 
        Yes ) break;;
        No ) exit;;
    esac
done

SOURCE_GATE=$(validate_input "Source Smart Gate ID" "20")

sed -i "s/^SOURCE_GATE_ID.*/SOURCE_GATE_ID=$SOURCE_GATE/" "$ENV_FILE"

printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}SOURCE_GATE_ID${RESET} in ${YELLOW}.env${RESET} \n\n"

DESTINATION_GATE=$(validate_input "Destination Smart Gate ID" "20")

sed -i "s/^DESTINATION.*/DESTINATION_GATE_ID=$DESTINATION_GATE/" "$ENV_FILE"

printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}DESTINATION_GATE_ID${RESET} in ${YELLOW}.env${RESET} \n\n"

CORP_ID=$(validate_input "Corporation ID" "4")

sed -i "s/^ALLOWED_CORP_ID.*/ALLOWED_CORP_ID=$CORP_ID/" "$ENV_FILE"

printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}ALLOWED_CORP_ID${RESET} in ${YELLOW}.env${RESET} \n\n"

pnpm configure-smart-gates

printf "\n${GREEN}[COMPLETED] Run ${YELLOW}configure-smart-gates${RESET} script \n\n"