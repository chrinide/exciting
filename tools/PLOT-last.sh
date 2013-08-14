#!/bin/bash
#
################################################################################
# @Pasquale Pavone  (2013, Fedruary, 1)
#_______________________________________________________________________________

CURRENT=$PWD

if [ -f 'g-dum'    ]; then rm g-dum     ; fi
if [ -f 'g-file'   ]; then rm g-file    ; fi
if [ -f 'awk-file' ]; then rm awk-file  ; fi

if [ "${1}" == "" ]; then 
   echo ""
   echo " Incorrect number of arguments. **Usage**:"
   echo " PLOT-last.sh TEXT [ROWNUMBER]"
   echo ""
   exit
fi

CERCA=${1}
NUMERO=${2}

if [ "${1}" ==  1 ]; then CERCA="Fermi energy                               :" ; NUMERO=4; fi
if [ "${1}" ==  2 ]; then CERCA="Total energy                               :" ; NUMERO=4; fi

if [ "${1}" ==  3 ]; then CERCA="Kinetic energy                             :" ; NUMERO=4; fi
if [ "${1}" ==  4 ]; then CERCA="Coulomb energy                             :" ; NUMERO=4; fi
if [ "${1}" ==  5 ]; then CERCA="Exchange energy                            :" ; NUMERO=4; fi
if [ "${1}" ==  6 ]; then CERCA="Correlation energy                         :" ; NUMERO=4; fi

if [ "${1}" ==  7 ]; then CERCA="DOS at Fermi energy"                          ; NUMERO=7; fi

#if [ "${1}" ==  8 ]; then CERCA="" ; NUMERO=3; fi
#if [ "${1}" ==  9 ]; then CERCA="" ; NUMERO=3; fi
#if [ "${1}" == 10 ]; then CERCA="" ; NUMERO=3; fi
#if [ "${1}" == 11 ]; then CERCA="" ; NUMERO=4; fi
#if [ "${1}" == 12 ]; then CERCA="" ; NUMERO=3; fi
#if [ "${1}" == 13 ]; then CERCA="" ; NUMERO=3; fi
#if [ "${1}" == 14 ]; then CERCA="" ; NUMERO=4; fi
#if [ "${1}" == 15 ]; then CERCA="" ; NUMERO=4; fi

echo ""
echo $CERCA $NUMERO
echo ""

if [ -f 'volume-01' ]; then LABEL=volume ; fi
if [ -f 'strain-01' ]; then LABEL=strain ; fi
if [ -f 'alat-01'   ]; then LABEL=alat   ; fi
if [ -f 'displ-01'  ]; then LABEL=displ  ; fi

dollar="$"
q=2

cat>awk-file<<***
BEGIN {n=0; y=-1}
/${CERCA}/ {n++; x=${dollar}1; y++}
n>0 {n++}
n==$q {z=${dollar}${NUMERO}}
n==$q {print z; n=0}
***

#EXCITING-----------------------------------------------------------------------
if [ -f 'exciting' ]; then

output_list=`ls -d rundir-*`

for output in $output_list ; do
    suffix=$(echo $output | cut -c8-9)
    strain=$(cat $CURRENT/$LABEL-$suffix)
    ifile=$CURRENT/rundir-$suffix/INFO.OUT
    cat $ifile | awk -f awk-file | tail -n1 > g-dum
    awk -v eta="$strain" '// {printf "%11.8f %22.16f\n",eta,$1}' g-dum >> g-file   
done

fi
#-------------------------------------------------------------------------------

echo "Plotting function..."
PLOT-one.py g-file
sleep 3
echo ""
echo "Plotting derivative..."
PLOT-deriv.py g-file
rm -f g-input g-file g-dum awk-file
echo ""

#-------------------------------------------------------------------------------
