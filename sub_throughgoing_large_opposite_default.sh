# setup fife_utils first. Njobs limit = 10k
#all credits for this script belong to M. O'Flaherty

if [ "$#" -lt 5 ]; then
    echo "Usage: ./sub_throughgoing_large_opposite.sh RUNLIST PARTLIST EVLIST RATIOLIST REFLIST"
    exit 1
fi

export RUNLIST=$1
export PARTLIST=$2
export EVLIST=$3
export RATIOLIST=$4
export REFLIST=$5

while read -r run && read -r part <&3 && read -r ev <&6
do
        echo "RUN: ${run}, PART: ${part}, EVENTS: ${ev}"
	while read -r ratio 
	do
		echo "QE Ratio: ${ratio}"
		while read -r ref
		do
			echo "REFLECTIVITY: ${ref}"
			jobsub_submit -N 1 --memory=2048MB --expected-lifetime=long --resource-provides=usage_model=DEDICATED,OPPORTUNIST -G annie file:///annie/app/users/mnieslon/send_grid/grid_throughgoing_large_opposite_default.sh ${run} ${part} ${ev} ${ratio} ${ref}
		done < $REFLIST
	done < $RATIOLIST
done < $RUNLIST 3<$PARTLIST 6<$EVLIST
