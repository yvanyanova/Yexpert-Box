#!/bin/bash
source /home/yrelay/config/env
export SHELL=/bin/bash
#Cela existent pour des raisons de compatibilité
alias gtm="$gtm_dist/mumps -dir"
alias GTM="$gtm_dist/mumps -dir"
alias gde="$gtm_dist/mumps -run GDE"
alias lke="$gtm_dist/mumps -run LKE"
alias dse="$gtm_dist/mumps -run DSE"
#/home/yrelay/scripts/admin.sh
#$gtm_dist/mumps -dir
#$gtm_dist/mupip EXTRACT -SELECT=* /home/yrelay/tmp/yxp.zwr
