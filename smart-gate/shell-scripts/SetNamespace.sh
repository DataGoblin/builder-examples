#Files
ENV_FILE=".env"
MUD_CONFIG_FILE="mud.config.ts"
CONSTANTS_FILE="src/systems/constants.sol"

#Colours
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

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

NAMESPACE=$(validate_input "Namespace" "2")

sed -i "s/^bytes14 constant SMART_GATE_DEPLOYMENT_NAMESPACE.*/bytes14 constant SMART_GATE_DEPLOYMENT_NAMESPACE = \"$NAMESPACE\";/" "$CONSTANTS_FILE"
sed -i "s/^  namespace.*/  namespace: \"$NAMESPACE\",/" "$MUD_CONFIG_FILE"

printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}DEPLOYMENT_NAMESPACE${RESET} in ${YELLOW}$CONSTANTS_FILE${RESET} and ${YELLOW}namespace${RESET} in ${YELLOW}$MUD_CONFIG_FILE${RESET} \n\n"