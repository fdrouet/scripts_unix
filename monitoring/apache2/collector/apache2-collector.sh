#!/bin/bash
#
# Ce script recupere un certain nombre de metriques Apache 2 en utilisant le server-status
# Ces metriques sont ecrites dans un fichier temporaire ecrase a chaque appel
#
# le format des donnees du fichier genere sont :
# <CPU Load>:<Requests per second>:<Bytes per second>:<Bytes per request>:<Max Workers>:<Total Workers>:<Total Busy Workers>:<Total Idle Workers>
#
# pour recuperer ensuite ces donnes depuis un autre script il suffit d'utiliser une commande du type :
# # recuperer le CPU Load :
#   cat /tmp/apache-data.txt | cut -f1 -d:
# # recuperer le nombre total de Workers demares :
#   cat /tmp/apache-data.txt | cut -f6 -d:
# il suffit donc de jouer sur le nombre passe au parametre -f de la commande cut pour choisir la donnee a recuperer

# Reglages du Script
URL_APACHE_STATUS="http://localhost/server-status?auto"
DATA_FILE=/tmp/apache-data.txt

################################################
### Ne rien modifier apres cette ligne
################################################
# fonctions utilitaires
trim() { echo -n $1; }
count_char() { echo "$1" | awk -F$2 '{ t += (NF - 1) } END {print t}'; }

# recuperation des donnees brutes
DATA=$(curl ${URL_APACHE_STATUS} 2> /dev/null)
#echo "${DATA}"

# recuperation des donnees unitaires
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
#echo "${CPU_LOAD}"
#echo "${REQ_PER_SEC}"
#echo "${BYTES_PER_SEC}"
#echo "${BYTES_PER_REQ}"
#echo "${WORKERS_BUSY}"
#echo "${WORKERS_IDLE}"
#echo "${WORKERS_TOTAL}"
#echo "${SCOREBOARD}"
#echo ${WORKERS_MAX}
#echo ${SLOT_WAITING}
#echo ${SLOT_STARTING}
#echo ${SLOT_READING}
#echo ${SLOT_SENDING}
#echo ${SLOT_KEEPALIVE}
#echo ${SLOT_DNSLOOK}
#echo ${SLOT_CLOSING}
#echo ${SLOT_LOGGING}
#echo ${SLOT_FINISHING}
#echo ${SLOT_CLEANUP}
#echo ${SLOT_OPEN}
#echo "##############"

# fabrication de la chaine de sortie et ecriture du fichier
DATA_LINE="0"${CPU_LOAD}":0"${REQ_PER_SEC}":0"${BYTES_PER_SEC}":0"${BYTES_PER_REQ}":"${WORKERS_MAX}":"${WORKERS_TOTAL}":"${WORKERS_BUSY}":"${WORKERS_IDLE}":"${SLOT_WAITING}":"${SLOT_STARTING}":"${SLOT_READING}":"${SLOT_SENDING}":"${SLOT_KEEPALIVE}":"${SLOT_DNSLOOK}":"${SLOT_CLOSING}":"${SLOT_LOGGING}":"${SLOT_FINISHING}":"${SLOT_CLEANUP}":"${SLOT_OPEN}
#echo ${DATA_LINE}
echo ${DATA_LINE} > ${DATA_FILE}
