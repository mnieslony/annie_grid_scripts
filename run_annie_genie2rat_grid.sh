ANNIEPATH=/annie/app/users/vfischer/GENIE
source /grid/fermiapp/products/uboone/setup_uboone.sh
source $ANNIEPATH/setup_annie.sh
setup_annie
setup jobsub_client
export GROUP=annie
# --OS=SL6 --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC

source ~/.profile
RATPAC

setup genie v2_12_0a -q e10:r6:debug

export FIRSTRUN=1000
export NEVENTS=50000

export NJOBS=500

# was 20000 evt, 250 jobs

# jobsub_submit -g --group $GROUP -N ${NJOBS} file://$ANNIEPATH/run_annie_genie.sh \
#      --rock -r ${FIRSTRUN} -n ${NEVENTS} -v ${VOLCUT} \
#          -o /pnfs/annie/persistent/users/${USER}/genie

# enters the folder specified as input
cd $1
ls
mkdir /pnfs/annie/persistent/users/${USER}/genie/GENIE2RAT_files

for file in $1/*.root; do
  ls $file
  ${RATPAC_PATH}/tools/genie2rat/genie2rat -i $file -o /pnfs/annie/persistent/users/${USER}/genie/GENIE2RAT/${file%%.*}_ratready.root
done


