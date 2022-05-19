# setup fife_utils first. Njobs limit = 10k
#all credits for this script belong to M. O'Flaherty

if [ "$#" -lt 2 ]; then
    echo "Usage: ./sub_ambe.sh PORTLIST ZLIST"
    exit 1
fi

export PORTLIST=$1
export ZLIST=$2

while read -r port
do
        #echo "RUN: ${run}, EVENTS: ${ev}"
	echo "PORT: ${port}"
	while read -r height
	do
		echo "Z: ${height}"
		jobsub_submit -N 25 --memory=2048MB --expected-lifetime=long --resource-provides=usage_model=DEDICATED,OPPORTUNIST -G annie file:///annie/app/users/mnieslon/send_grid/grid_ambe_default.sh ${port} ${height}
	done < $ZLIST
done < $PORTLIST
