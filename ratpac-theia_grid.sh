#!/bin/bash
# Based on /annie/app/users/dingpf/GridSub_test.sh

# RATPAC support (Geant4.10.01, root5.34)
setup_ratpac() {
    setup python v2_7_6
    unsetup root
    setup root v5_34_32 -q e9:nu:prof
    source ${CONDOR_DIR_INPUT}/geant4.10.01.p02-build/bin/geant4.sh
    source $RATPAC_PATH/env.sh
    
    # Redefine those variables here since env.sh was configured on /app
    export RATROOT=$RATPAC_PATH
    export PATH=$RATROOT/bin:$PATH
    export LD_LIBRARY_PATH=$RATROOT/lib:$LD_LIBRARY_PATH
    GLG4DATA=$RATROOT/data
    PYTHONPATH=$RATROOT/python:$PYTHONPATH
    echo "RAT-PAC support loaded.."
}

cat <<EOF
condor   dir: $CONDOR_DIR_INPUT
process   id: $PROCESS
output   dir: $CONDOR_DIR_OUTPUT
EOF

# Source the annie setup file on cvmfs
source /cvmfs/larsoft.opensciencegrid.org/products/setup
source /cvmfs/annie.opensciencegrid.org/setup_annie.sh

HOSTNAME=$(hostname -f)
GRIDUSER="mnieslon"

echo "Job starting on $(uname -a)"

# run the actual job
MACRO_FILE=$2
OUTPUT_FILE=$1
MACRO_FILE_NOPATH=${MACRO_FILE##*/}
OUTPUT_FILE_NAME=${OUTPUT_FILE}_${PROCESS}.root
echo "OUTPUT_FILE_NAME: ${OUTPUT_FILE_NAME}"

# Create a dummy file in the output directory. This is a hack to get jobs
# that fail to end themselves quickly rather than hanging on for a long time
# waiting for output to arrive.
DUMMY_OUTPUT_FILE=${CONDOR_DIR_OUTPUT}/${JOBSUBJOBID}_dummy_output
touch ${DUMMY_OUTPUT_FILE}

# Go into the input directory and extract ratpac and geant4
echo "Un-Taring geant4 & ratpac repositories"
cd $CONDOR_DIR_INPUT
#tar xzf ratpac-theia.tar.gz
#tar xzf ratpac-theia-grid-3pct.tar.gz
tar xzf ratpac-theia-grid-3pct-25pct.tar.gz
tar xzf geant4.10.01.02_for_grid.tar.gz

# setup software
echo "Export RATPAC PATH, setting up ratpac and fife_utils"
export RATPAC_PATH=${CONDOR_DIR_INPUT}/ratpac-theia
setup_ratpac
setup fife_utils

# Run rat-pac
echo "Running ratpac... with command:"
echo "${RATPAC_PATH}/bin/rat -o ${CONDOR_DIR_OUTPUT}/${OUTPUT_FILE_NAME} ${CONDOR_DIR_INPUT}/${MACRO_FILE_NOPATH}"
$RATPAC_PATH/bin/rat -o ${CONDOR_DIR_OUTPUT}/$OUTPUT_FILE_NAME $CONDOR_DIR_INPUT/$MACRO_FILE_NOPATH > ${CONDOR_DIR_OUTPUT}/output_$PROCESS
ifdh cp -r ${CONDOR_DIR_INPUT}/rat*log ${CONDOR_DIR_OUTPUT}
echo "Directory contents after running: "
ls

### END ###
