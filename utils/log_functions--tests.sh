#!/bin/bash
# script de tests de "log_functions.sh"

echo "Chargement de $(pwd)/$(dirname $0)/log_functions.sh"
. $(pwd)/$(dirname $0)/log_functions.sh

log_trace "Ma log de Trace"
log_info "Ma log d'Info"
log_error "Ma log d'Erreur"

declare -F
