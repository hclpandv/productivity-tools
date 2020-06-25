#!/bin/bash
VERSION=1.0

# create a temp dir in /tmp
DIR=/tmp/tmp.$$
mkdir ${DIR} &>/dev/null

HOSTNAME=$( hostname -s)
#INPUT_PARAM=$1

#echo ${HOSTNAME}
#echo ${INPUT_PARAM}

TERM=xterm

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

INPUT_PARAM=$1

if [[ ${INPUT_PARAM} -gt 10 ]] && [[ ${INPUT_PARAM} -le 99 ]] ; then
  INTERACTIVE="YES"
  SEL=${INPUT_PARAM}
  EXTRA_PARAM=$2
else
  INTERACTIVE="NO"
  SEL=x
fi

ready() {
  if [[ ${INTERACTIVE} = "NO" ]] ; then
    read -p "${YELLOW}------ Press <${BRIGHT}${YELLOW}ENTER${NORMAL}${YELLOW}> -----${NORMAL} " SEL
    [[ ${SEL} == "" ]] && SEL=x
  else
    SEL=99
  fi
}

LINE() { echo "------------------------------------------------------------------" ; }

TAKES_TIME(){ echo "${GREEN}This will take some time. One moment please...${NORMAL}"; }

STRIP_OUTPUT() {
  COMMAND=$1
  FILE=${DIR}/output.$$
  exec $1 | cut -c40- > ${FILE}
  # locate position of the word parent in the file
  POSITION=$( cat ${FILE} | head -2 | tail -1 | grep -aob 'parent' | awk -F: '{print $1}' )
  POSITION=$(( POSITION - 1 ))
  cat ${FILE} | cut -c-${POSITION}
  rm -f ${FILE}
}

# ======================================================== BEGIN ==================

#SEL=x
while true
do
  TIME=$( date | awk '{print $1,$2,$3,$4,$5}' )

  if [[ ${INTERACTIVE} == "NO" ]] ; then
    tput clear

    echo "---------------------------------------------------------- ${BRIGHT}${GREEN}V ${VERSION}${NORMAL} -"
    echo -e "Hostname: ${BRIGHT}${CYAN}${HOSTNAME} ${BRIGHT}${GREEN}(${ENV})${NORMAL}  Time: ${BRIGHT}${YELLOW}${TIME}${NORMAL}"
    echo "Az cli must be installed to use these menu items"
    echo ""

    echo "-- ${BRIGHT}${CYAN}Azure Subscriptions${NORMAL} -----------------------------------------------------------"
    echo "${BRIGHT}${YELLOW} 11 ${NORMAL} Get account and subscription ${BRIGHT}${GREEN}${DB2}${NORMAL}            ${BRIGHT}${YELLOW}  12 ${NORMAL} List all subscriptions ${BRIGHT}${GREEN}${DB2}${NORMAL}"              
    echo "${BRIGHT}${YELLOW} 13 ${NORMAL} Change default subscription ${BRIGHT}${GREEN}${DB2}${NORMAL}"
    #echo "${BRIGHT}${YELLOW}  14 ${NORMAL} Search for a Process ${BRIGHT}${GREEN}${DB2}${NORMAL}"
    echo ""

    echo "-- ${BRIGHT}${CYAN}Azure Resource Groups${NORMAL} ---------------------------------------------------------"
    echo "${BRIGHT}${YELLOW} 21 ${NORMAL} List RGs in default subscription  ${BRIGHT}${GREEN}${STACK_nr}${NORMAL}        ${BRIGHT}${YELLOW} 22 ${NORMAL} List RGs in given subscription"
    echo "${BRIGHT}${YELLOW} 23 ${NORMAL} List Resources in given RG  ${BRIGHT}${GREEN}${STACK_nr}${NORMAL}              ${BRIGHT}${YELLOW} 24 ${NORMAL} Future Feature"
   
    echo ""

    
    LINE
  fi
  [[ ${SEL} == "x" ]] && read -p "${YELLOW}Select ${BRIGHT}number${NORMAL}${YELLOW} and press <enter>, any other key to exit ${CYAN}" SEL
  echo "${NORMAL}"
  case $SEL in

        11) echo "${GREEN} Running command : az account show ${NORMAL}"
            az account show
            ready ;;

        12) echo "${GREEN} Running command : az account list --output table ${NORMAL}"
            az account list --output table | more
            ready ;;

        13) if [[ ${INTERACTIVE} == "YES" ]] ; then
              SUBSCRIPTION=${EXTRA_PARAM}
            else
              read -p "Subscription Name: " SUBSCRIPTION
            fi
            if [[ ! $SUBSCRIPTION == "" ]] ; then
              TAKES_TIME
              echo "${CYAN}az account set --subscription ${SUBSCRIPTION}${NORMAL}"
              az account set --subscription ${SUBSCRIPTION} ; ready
            fi
            ;;

        14) if [[ ${INTERACTIVE} == "YES" ]] ; then
              SEARCH=${EXTRA_PARAM}
            else
              read -p "PID: " SEARCH
            fi
            if [[ ! $PID == "" ]] ; then
              TAKES_TIME
              echo "${CYAN}ps -ef | grep ${SEARCH}${NORMAL}"
              kill --verbose | grep ${SEARCH} ; ready
            fi
            ;;
         
        21) echo "${GREEN} Running command : az group list --output table ${NORMAL}"
            az group list --output table | more
            ready 
            ;;

        22) if [[ ${INTERACTIVE} == "YES" ]] ; then
              SUBSCRIPTION=${EXTRA_PARAM}
            else
              read -p "Subscription Name: " SUBSCRIPTION
            fi
            if [[ ! $SUBSCRIPTION == "" ]] ; then
              TAKES_TIME
              echo "${CYAN}az group list --subscription ${SUBSCRIPTION} --output table${NORMAL}"
              az group list --subscription ${SUBSCRIPTION} --output table | more ; ready
            fi
            ;;
          
        23) if [[ ${INTERACTIVE} == "YES" ]] ; then
              RG=${EXTRA_PARAM}
            else
              read -p "resourceGroup Name: " RG
            fi
            if [[ ! $RG == "" ]] ; then
              TAKES_TIME
              echo "${CYAN}az resource list --resource-group ${RG} --output table${NORMAL}"
              az resource list --resource-group ${RG} --output table | more ; ready
            fi
            ;;  
 
        r|R) ;;
        * ) rm -fr ${DIR} &>/dev/null ; trap 2; exit 0 ;;
  esac
done

clear
exit

