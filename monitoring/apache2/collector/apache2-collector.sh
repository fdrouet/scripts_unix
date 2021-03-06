#!/bin/bash
#
# Ce script recupere un certain nombre de metriques Apache 2 en utilisant le server-status
# Ces metriques sont ecrites dans un fichier temporaire ecrase a chaque appel
#
# le format des donnees du fichier genere sont :
# <1=CPU Load>:<2=Requests per second>:<3=Bytes per second>:<4=Bytes per request>:<5=Max Workers>:<6=Total Workers>:<7=Total Busy Workers>:<8=Total Idle Workers>:<9=Waiting for Connection Slots>:<10=Starting up Slots>:<11=Reading Request Slots>:<12=Sending Reply Slots>:<13=Keepalive (read) Slots>:<14=DNS Lookup Slots>:<15=Closing connection Slots>:<16=Logging Slots>:<17=Gracefully finishing Slots>:<18=Idle cleanup of worker Slots>:<19=Open slots with no current process>
#
# pour recuperer ensuite ces donnes depuis un autre script il suffit d'utiliser une commande du type :
# # recuperer le CPU Load :
#   cat /tmp/apache-data.txt | cut -f1 -d:
# # recuperer le nombre total de Workers demares :
#   cat /tmp/apache-data.txt | cut -f6 -d:
# il suffit donc de jouer sur le nombre passe au parametre -f de la commande cut pour choisir la donnee a recuperer

# Tuning of the script
URL_APACHE_STATUS="http://localhost/server-status?auto"
OUTPUT_DATA_FILE=/tmp/apache-data.txt

################################################
### DO NOT TOUCH BELOW THIS LINE
################################################
# utilities fonctions
trim() { echo -n $1; }
count_char() { echo "$1" | awk -F$2 '{ t += (NF - 1) } END {print t}'; }

# fetching apache server-status data
DATA=$(curl ${URL_APACHE_STATUS} 2> /dev/null)
#echo "${DATA}"

# fetching each data
CPU_LOAD=$(trim $(echo "${DATA}" | egrep -e "^CPULoad: +([0-9]*\.[0-9]+)$" | cut -f2 -d:))
REQ_PER_SEC=$(trim $(echo "${DATA}" | egrep -e "^ReqPerSec: +([0-9]*\.[0-9]+)$" | cut -f2 -d:))
BYTES_PER_SEC=$(trim $(echo "${DATA}" | egrep -e "^BytesPerSec: +([0-9]*\.[0-9]+)$" | cut -f2 -d:))
BYTES_PER_REQ=$(trim $(echo "${DATA}" | egrep -e "^BytesPerReq: +([0-9]*\.[0-9]+)$" | cut -f2 -d:))
WORKERS_BUSY=$(trim $(echo "${DATA}" | egrep -e "^BusyWorkers: +([0-9]*)$" | cut -f2 -d:))
WORKERS_IDLE=$(trim $(echo "${DATA}" | egrep -e "^IdleWorkers: +([0-9]*)$" | cut -f2 -d:))
let WORKERS_TOTAL="${WORKERS_BUSY}+${WORKERS_IDLE}"
SCOREBOARD=$(trim $(echo "${DATA}" | egrep -e "^Scoreboard: +([_SRWKDCLGI\.]*)$" | cut -f2 -d:))
WORKERS_MAX=$(echo -n "${SCOREBOARD}" | wc -m)
SLOT_WAITING=$(count_char "${SCOREBOARD}" "_")
SLOT_STARTING=$(count_char "${SCOREBOARD}" "S")
SLOT_READING=$(count_char "${SCOREBOARD}" "R")
SLOT_SENDING=$(count_char "${SCOREBOARD}" "W")
SLOT_KEEPALIVE=$(count_char "${SCOREBOARD}" "K")
SLOT_DNSLOOK=$(count_char "${SCOREBOARD}" "D")
SLOT_CLOSING=$(count_char "${SCOREBOARD}" "C")
SLOT_LOGGING=$(count_char "${SCOREBOARD}" "L")
SLOT_FINISHING=$(count_char "${SCOREBOARD}" "G")
SLOT_CLEANUP=$(count_char "${SCOREBOARD}" "I")
SLOT_OPEN=$(count_char "${SCOREBOARD}" ".")

#echo "##############"
#echo "${CPU_LOAD}"; echo "${REQ_PER_SEC}"; echo "${BYTES_PER_SEC}"; echo "${BYTES_PER_REQ}"; echo "${WORKERS_BUSY}"; echo "${WORKERS_IDLE}"; echo "${WORKERS_TOTAL}"; echo "${SCOREBOARD}"; echo ${WORKERS_MAX}; echo ${SLOT_WAITING}; echo ${SLOT_STARTING}; echo ${SLOT_READING}; echo ${SLOT_SENDING}; echo ${SLOT_KEEPALIVE}; echo ${SLOT_DNSLOOK}; echo ${SLOT_CLOSING}; echo ${SLOT_LOGGING}; echo ${SLOT_FINISHING}; echo ${SLOT_CLEANUP}; echo ${SLOT_OPEN}
#echo "##############"

# agregating data into 1 line & writing the output data file
DATA_LINE="0"${CPU_LOAD}":0"${REQ_PER_SEC}":0"${BYTES_PER_SEC}":0"${BYTES_PER_REQ}":"${WORKERS_MAX}":"${WORKERS_TOTAL}":"${WORKERS_BUSY}":"${WORKERS_IDLE}":"${SLOT_WAITING}":"${SLOT_STARTING}":"${SLOT_READING}":"${SLOT_SENDING}":"${SLOT_KEEPALIVE}":"${SLOT_DNSLOOK}":"${SLOT_CLOSING}":"${SLOT_LOGGING}":"${SLOT_FINISHING}":"${SLOT_CLEANUP}":"${SLOT_OPEN}
#echo ${DATA_LINE}
echo ${DATA_LINE} > ${OUTPUT_DATA_FILE}
