# Submit a single TA job on the grid
# V. Fischer (code based on other people's code as usual)

if [ "$#" -ne 5 ]; then
      echo "Usage: ./submit_ToolAnalysis_job.sh FILENAME TOOLCHAIN TRANSFER_FILES_SUB TRIGOVERLAP_DIR BEAMSTATUSFILE"
      echo "Options are: filename (with path), name of toolchain, files being transferred at submission (1/0), filepath for zipped trigger overlap files, filepath for beamstatus file"
      exit 1
fi

source /cvmfs/annie.opensciencegrid.org/setup_annie.sh
setup jobsub_client

export SCRIPT_PATH=/annie/app/users/mnieslon/send_grid
export GRID_TAR_PATH=/pnfs/annie/persistent/users/mnieslon/grid

FILENAME=$1
TOOLCHAIN=$2
TRANSFER_FILES_SUBMISSION=$3
FILETRIGOVERLAP=$4
FILEBEAMSTATUS=$5

QUEUE=medium

FILENAME_NOPATH=${FILENAME##*/}
FILENAME_PATH=${FILENAME%/*}
FILENAME_NOSUFFIX="${FILENAME_NOPATH#RAWData}"
FILENAME_RUNONLY="${FILENAME_NOSUFFIX%S*}"
FILETRIGOVERLAP_NOPATH=${FILETRIGOVERLAP##*/}
FILEBEAMSTATUS_NOPATH=${FILEBEAMSTATUS##*/}

if [[ "$TOOLCHAIN" == *"Decoder"* ]]
then
     OUTPUT_FOLDER=/pnfs/annie/persistent/users/mnieslon/data/processed_hits_improved/$FILENAME_RUNONLY
#     OUTPUT_FOLDER=/pnfs/annie/persistent/users/mnieslon/data/processed_hits2/$FILENAME_RUNONLY
#    OUTPUT_FOLDER=/pnfs/annie/persistent/users/mnieslon/data/processed_hits/$FILENAME_RUNONLY
#    OUTPUT_FOLDER=/pnfs/annie/scratch/users/mnieslon/data/processed/$FILENAME_RUNONLY
    mkdir -p $OUTPUT_FOLDER
fi
if [[ "$TOOLCHAIN" == *"ClusterFinder"* ]]
then
    OUTPUT_FOLDER=$FILENAME_PATH
fi    

#echo "Creating my_inputs.txt or my_files.txt"
#if [[ "$TOOLCHAIN" == *"Decoder"* ]]
#then
#    rm ToolAnalysis/${TOOLCHAIN}/my_files.txt
#    echo $FILENAME_NOPATH > ToolAnalysis/${TOOLCHAIN}/my_files.txt
#fi
#if [[ "$TOOLCHAIN" == *"ClusterFinder"* ]]
#then
#    rm ToolAnalysis/${TOOLCHAIN}/my_inputs.txt
#    echo $FILENAME_NOPATH > ToolAnalysis/${TOOLCHAIN}/my_inputs.txt
#fi

#echo "Compressing TA folder..."
#tar -zcf ToolAnalysis_for_grid.tar.gz --exclude='*.root' --exclude='RAWData*' --exclude='ProcessedRawData*' ToolAnalysis/
#mv -f ToolAnalysis_for_grid.tar.gz ${GRID_TAR_PATH}
#chmod a+rw ${GRID_TAR_PATH}/ToolAnalysis_for_grid.tar.gz

if [ $TRANSFER_FILES_SUBMISSION -eq 0 ]
then
    echo "Submitting job..."
    jobsub_submit -g --memory=8000MB --expected-lifetime=${QUEUE} --group=annie --disk=30GB \
            --resource-provides=usage_model=OPPORTUNISTIC,DEDICATED \
            --jobsub-server=https://fifebatch.fnal.gov:8443 -q \
            -f $FILENAME \
            -f ${GRID_TAR_PATH}/ToolAnalysis_DataDecoder_TrigOverlap_BeamStatus_improved4.tar.gz \
            -f $FILETRIGOVERLAP \
            -f $FILEBEAMSTATUS \
            -d OUTPUT $OUTPUT_FOLDER \
            file://${SCRIPT_PATH}/ToolAnalysis_grid.sh $FILENAME_NOPATH configfiles/$TOOLCHAIN $FILETRIGOVERLAP_NOPATH $FILEBEAMSTATUS_NOPATH
fi
            #-f dropbox:///pnfs/annie/persistent/users/vfischer/ToolAnalysis/datafiles/RAWDataR2257S0p10 \
if [ $TRANSFER_FILES_SUBMISSION -eq 1 ]
then
    echo "Submitting job..."
    jobsub_submit -g --memory=8000MB --expected-lifetime=${QUEUE} --group=annie --disk=30GB \
            --resource-provides=usage_model=OPPORTUNISTIC,DEDICATED \
            --jobsub-server=https://fifebatch.fnal.gov:8443 -q \
            -f dropbox://$FILENAME \
            -f dropbox://${GRID_TAR_PATH}/ToolAnalysis_DataDecoder_TrigOverlap_BeamStatus_improved4.tar.gz \
            -f dropbox://$FILETRIGOVERLAP \
            -f dropbox://$FILEBEAMSTATUS \
            -d OUTPUT $OUTPUT_FOLDER \
            file://${SCRIPT_PATH}/ToolAnalysis_grid.sh $FILENAME_NOPATH configfiles/$TOOLCHAIN $FILETRIGOVERLAP_NOPATH $FILEBEAMSTATUS_NOPATH
fi

