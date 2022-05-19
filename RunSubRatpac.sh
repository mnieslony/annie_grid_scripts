#!/bin/sh

#if [ "$#" -ne 1 ]; then
#      echo "Usage: ./RunSimpleTree.sh FILELIST"
#      echo "Specified input variable must contain the path to a file specifying all files"
#      exit 1
#fi

#let i=0
#RUNLIST=$1

#while read -r file
for i in {101..249}
do
	offset=$(( 20*i ))
	echo "$offset"
        ./submit_ratpac_theia_atmospheric.sh /pnfs/annie/persistent/users/mnieslon/genie/GENIE2RAT/Atmospheric_NC theia_atmonc_06-18-21 ${offset}
done
#done < $RUNLIST

