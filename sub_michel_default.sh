# setup fife_utils first. Njobs limit = 10k
#all credits for this script belong to M. O'Flaherty

if [ "$#" -lt 2 ]; then
    echo "Usage: ./sub_michel.sh RATIOLIST WBRATIOLIST"
    exit 1
fi

export RATIOLIST=$1
export WBRATIOLIST=$2
#export EVLIST=$2

#while read -r run && read -r ev <&3
#while read -r ratio && read -r wbratio <&3
while read -r ratio
do
        #echo "RUN: ${run}, EVENTS: ${ev}"
	echo "RATIO: ${ratio}"
	while read -r wbratio
	do
		echo "WBRATIO: ${wbratio}"
		jobsub_submit -N 100 --memory=2048MB --expected-lifetime=long --resource-provides=usage_model=DEDICATED,OPPORTUNIST -G annie file:///annie/app/users/mnieslon/send_grid/grid_michel_default.sh ${ratio} ${wbratio}
	done < $WBRATIOLIST
done < $RATIOLIST
#done < $RUNLIST 3<$EVLIST
#done < $RATIOLIST 3<$WBRATIOLIST
