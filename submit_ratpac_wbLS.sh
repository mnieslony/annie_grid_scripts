# Submit a single ratpac job on the grid
# V. Fischer (code based on other people's code as usual)

if [ "$#" -ne 2 ]; then
      echo "Usage: ./submit_ratpac_wbLS.sh OUTPUT_FILE_NAME MACRO_LOCATION"
      exit 1
fi

source /cvmfs/annie.opensciencegrid.org/setup_annie.sh
setup jobsub_client

export RATPAC_PATH=/pnfs/annie/persistent/users/mnieslon/ratpac/
export SCRIPT_PATH=/annie/app/users/mnieslon/send_grid/
export GRID_TAR_PATH=/pnfs/annie/persistent/users/mnieslon/ratpac/tar-files/
export GRID_MAC_PATH=/pnfs/annie/persistent/users/mnieslon/ratpac/mac-files/
export NJOBS=5
#export CONDOR_DIR_INPUT=/annie/app/users/mnieslon/test_grid_script/
#export CONDOR_DIR_OUTPUT=/annie/app/users/mnieslon/test_grid_script/

OUTPUT_FILE=$1
MACRO_FILE=$2
QUEUE=short

MACRO_FILE_NOPATH=${MACRO_FILE##*/}

jobsub_submit -N ${NJOBS} -g -M --memory=2000MB --expected-lifetime=${QUEUE} --group=annie --disk=30GB \
           --resource-provides=usage_model=OPPORTUNISTIC,DEDICATED,OFFSITE \
           --jobsub-server=https://fifebatch.fnal.gov:8443 \
           -f ${GRID_MAC_PATH}/$MACRO_FILE -f ${GRID_TAR_PATH}/ratpac-wbls.tar.gz -f ${GRID_TAR_PATH}/geant4.10.01.02_for_grid.tar.gz \
           -d OUTPUT /pnfs/annie/persistent/users/mnieslon/ratpac/simulations/ \
           file://${SCRIPT_PATH}/ratpac_grid.sh $OUTPUT_FILE $MACRO_FILE_NOPATH

#${SCRIPT_PATH}/ratpac_grid.sh $OUTPUT_FILE $MACRO_FILE_NOPATH

