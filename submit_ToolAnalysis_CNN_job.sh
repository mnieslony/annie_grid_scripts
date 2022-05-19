# Submit a single TA job on the grid
# V. Fischer (code based on other people's code as usual)

if [ "$#" -ne 5 ]; then
      echo "Usage: ./submit_ToolAnalysis_CNNjob.sh TOOLCHAIN TRANSFER_FILES_SUB PMTFILE LAPPDFILE JOBID"
      echo "Options are: name of toolchain, files being transferred at submission (1/0), filepath for wcsim pmt file, filepath for wcsim lappd file, JOBID"
      exit 1
fi

source /cvmfs/annie.opensciencegrid.org/setup_annie.sh
setup jobsub_client

export SCRIPT_PATH=/annie/app/users/mnieslon/send_grid
export GRID_TAR_PATH=/pnfs/annie/persistent/users/mnieslon/grid

TOOLCHAIN=$1
TRANSFER_FILES_SUBMISSION=$2
PMTFILE=$3
LAPPDFILE=$4
var=$5

QUEUE=medium

PMTFILE_NOPATH=${PMTFILE##*/}
LAPPDFILE_NOPATH=${LAPPDFILE##*/}

if [[ "$TOOLCHAIN" == *"CNNImage"* ]]
then
    #OUTPUT_FOLDER=/pnfs/annie/persistent/users/mnieslon/cnnimage/mc/beamlike/
    OUTPUT_FOLDER=/pnfs/annie/persistent/users/mnieslon/cnnimage/mc/beam_gst/
    mkdir -p $OUTPUT_FOLDER
fi
if [[ "$TOOLCHAIN" == *"ClusterFinder"* ]]
then
    OUTPUT_FOLDER=$FILENAME_PATH
fi    

if [ $TRANSFER_FILES_SUBMISSION -eq 0 ]
then
    echo "Submitting job..."
    echo "jobsub_submit -g --memory=4000MB --expected-lifetime=${QUEUE} --group=annie --disk=30GB \
            --resource-provides=usage_model=OPPORTUNISTIC,DEDICATED \
            --jobsub-server=https://fifebatch.fnal.gov:8443 -q \
            -f ${PMTFILE} \
            -f ${LAPPDFILE} \
            -f ${GRID_TAR_PATH}/ToolAnalysis_CNN.tar.gz \
            -d OUTPUT ${OUTPUT_FOLDER} \
            file://${SCRIPT_PATH}/ToolAnalysis_CNN_grid.sh ${PMTFILE_NOPATH} ${LAPPDFILE_NOPATH} configfiles/CNNImage/${TOOLCHAIN} ${var}"

    jobsub_submit -g --memory=4000MB --expected-lifetime=${QUEUE} --group=annie --disk=30GB \
            --resource-provides=usage_model=OPPORTUNISTIC,DEDICATED \
            --jobsub-server=https://fifebatch.fnal.gov:8443 -q \
            -f $PMTFILE \
	    -f $LAPPDFILE \
            -f ${GRID_TAR_PATH}/ToolAnalysis_CNN.tar.gz \
            -d OUTPUT $OUTPUT_FOLDER \
            file://${SCRIPT_PATH}/ToolAnalysis_CNN_grid.sh $PMTFILE_NOPATH $LAPPDFILE_NOPATH configfiles/CNNImage/$TOOLCHAIN $var
fi
            #-f dropbox:///pnfs/annie/persistent/users/vfischer/ToolAnalysis/datafiles/RAWDataR2257S0p10 \
if [ $TRANSFER_FILES_SUBMISSION -eq 1 ]
then
    echo "Submitting job..."
    echo "jobsub_submit -g --memory=4000MB --expected-lifetime=${QUEUE} --group=annie --disk=30GB \
            --resource-provides=usage_model=OPPORTUNISTIC,DEDICATED \
            --jobsub-server=https://fifebatch.fnal.gov:8443 -q \
            -f dropbox://${PMTFILE} \
            -f dropbox://${LAPPDFILE} \
            -f dropbox://${GRID_TAR_PATH}/ToolAnalysis_CNN.tar.gz \
            -d OUTPUT ${OUTPUT_FOLDER} \
            file://${SCRIPT_PATH}/ToolAnalysis_CNN_grid.sh ${PMTFILE_NOPATH} ${LAPPDFILE_NOPATH} configfiles/CNNImage/${TOOLCHAIN} ${var}"

    jobsub_submit -g --memory=4000MB --expected-lifetime=${QUEUE} --group=annie --disk=30GB \
            --resource-provides=usage_model=OPPORTUNISTIC,DEDICATED \
            --jobsub-server=https://fifebatch.fnal.gov:8443 -q \
            -f dropbox://$PMTFILE \
	    -f dropbox://$LAPPDFILE \
            -f dropbox://${GRID_TAR_PATH}/ToolAnalysis_CNN.tar.gz \
            -d OUTPUT $OUTPUT_FOLDER \
            file://${SCRIPT_PATH}/ToolAnalysis_CNN_grid.sh $PMTFILE_NOPATH $LAPPDFILE_NOPATH configfiles/CNNImage/$TOOLCHAIN $var
fi

