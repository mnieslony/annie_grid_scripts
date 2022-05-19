# setup fife_utils first. Njobs limit = 10k
#all credits for this script belong to M. O'Flaherty

if [ "$#" -lt 4 ]; then
    echo "Usage: ./sub_throughgoing_opposite.sh RUNLIST EVLIST RATIOLIST REFLIST"
    exit 1
fi

export RUNLIST=$1
export EVLIST=$2
export RATIOLIST=$3
export REFLIST=$4

while read -r run && read -r ev <&3
do
        echo "RUN: ${run}, EVENTS: ${ev}"
	while read -r ratio 
	do
		echo "QE Ratio: ${ratio}"
		while read -r ref
		do
			echo "REFLECTIVITY: ${ref}"
			jobsub_submit -N 1 --memory=2048MB --expected-lifetime=long --resource-provides=usage_model=DEDICATED,OPPORTUNIST -G annie file:///annie/app/users/mnieslon/send_grid/grid_throughgoing_opposite_default.sh ${run} ${ev} ${ratio} ${ref}
		done < $REFLIST
	done < $RATIOLIST
done < $RUNLIST 3<$EVLIST
