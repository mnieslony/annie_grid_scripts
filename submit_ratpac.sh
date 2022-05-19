# Submit a single ratpac job on the grid
# V. Fischer (code based on other people's code as usual)

if [ "$#" -ne 2 ]; then
      echo "Usage: ./submit_job.sh OUTPUT_FILE_NAME MACRO_LOCATION"
      exit 1
fi

source /cvmfs/annie.opensciencegrid.org/setup_annie.sh
setup jobsub_client

export RATPAC_PATH=/pnfs/annie/persistent/users/vfischer/simulation
export SCRIPT_PATH=/annie/app/users/vfischer
export GRID_TAR_PATH=/annie/app/users/vfischer/FOR_THE_GRID

OUTPUT_FILE=$1
MACRO_FILE=$2
QUEUE=short

MACRO_FILE_NOPATH=${MACRO_FILE##*/}

jobsub_submit -g -M --memory=2000MB --expected-lifetime=${QUEUE} --group=annie --disk=30GB \
           --resource-provides=usage_model=OPPORTUNISTIC,DEDICATED,OFFSITE \
           --jobsub-server=https://fifebatch.fnal.gov:8443 \
           -f $MACRO_FILE -f ${GRID_TAR_PATH}/annie-ratpac_for_grid.tar.gz -f ${GRID_TAR_PATH}/geant4.10.01.02_for_grid.tar.gz \
           -d OUTPUT /pnfs/annie/scratch/users/vfischer/ratpac_files/ \
           file://${SCRIPT_PATH}/ratpac_grid.sh $OUTPUT_FILE $MACRO_FILE_NOPATH

