#!/bin/bash
# Based on /annie/app/users/dingpf/GridSub_test.sh

cat <<EOF
condor   dir: $CONDOR_DIR_INPUT
process   id: $PROCESS
output   dir: $CONDOR_DIR_OUTPUT
EOF

# Source the annie setup file on cvmfs
source /cvmfs/larsoft.opensciencegrid.org/products/setup
source /cvmfs/annie.opensciencegrid.org/setup_annie.sh
setup fife_utils

HOSTNAME=$(hostname -f)
GRIDUSER="mnieslon"

echo "Job starting on $(uname -a)"

# run the actual job
PMTFILENAME=$1
LAPPDFILENAME=$2
TOOLCHAIN_FILE=$3
var=$4

# Create a dummy file in the output directory. This is a hack to get jobs
# that fail to end themselves quickly rather than hanging on for a long time
# waiting for output to arrive.
DUMMY_OUTPUT_FILE=${CONDOR_DIR_OUTPUT}/${JOBSUBJOBID}_dummy_output
touch ${DUMMY_OUTPUT_FILE}

# Go into the input directory and extract ratpac and geant4
cd $CONDOR_DIR_INPUT
echo "Contents of CONDOR INPUT DIR (before tar):"
ls -ltrh
echo "Contents of ToolAnalysis_CNN:"
ls ToolAnalysis_CNN
mv ToolAnalysis_CNN/MyToolAnalysis_CNN .
echo "Contents of CONDOR INPUT DIR (after mv):"
ls -ltrh

# Creating the tool input files
#echo "Creating my_inputs.txt or my_files.txt"
#if [[ "$TOOLCHAIN_FILE" == *"CNNImage"* ]]
#then
#    rm ${CONDOR_DIR_INPUT}/MyToolAnalysis_CNN/${TOOLCHAIN_FILE}/my_files.txt
#    echo $FILENAME > ${CONDOR_DIR_INPUT}/MyToolAnalysis_CNN/${TOOLCHAIN_FILE}/my_files.txt
#fi
#if [[ "$TOOLCHAIN_FILE" == *"ClusterFinder"* ]]
#then
#    rm ${CONDOR_DIR_INPUT}/MyToolAnalysis_EventBuilding/${TOOLCHAIN_FILE}/my_inputs.txt
#    echo $FILENAME > ${CONDOR_DIR_INPUT}/MyToolAnalysis_EventBuilding/${TOOLCHAIN_FILE}/my_inputs.txt
#fi

# setup software
export TOOLANALYSIS_PATH=${CONDOR_DIR_INPUT}/MyToolAnalysis_CNN
singularity shell -B/pnfs:/pnfs,/annie/data/:/annie/data,/annie/app:/annie/app /cvmfs/singularity.opensciencegrid.org/anniesoft/toolanalysis\:latest/
cd ${TOOLANALYSIS_PATH}

ls /cvmfs/singularity.opensciencegrid.org/anniesoft/toolanalysis\:latest/ToolAnalysis/ToolDAQ
source SetupSingularityGrid.sh
echo "Contents of TA folder:"
ls

cd ToolDAQ
echo "Contents of ToolDAQ folder:"
ls 
cd ..

# Copy macro file in output dir
#ifdh cp $CONDOR_DIR_INPUT/$MACRO_FILE_NOPATH $CONDOR_DIR_OUTPUT/$MACRO_FILE_NOPATH

# Copy datafile in ToolAnalysis
#ifdh cp -r /pnfs/annie/persistent/users/vfischer/ToolAnalysis/datafiles/RAWDataR2257S0p10 $TOOLANALYSIS_PATH

setup ifdhc   # for copying geometry & flux files
export IFDH_CP_MAXRETRIES=2  # default 8 tries is silly

ifdh cp -r $CONDOR_DIR_INPUT/$PMTFILENAME $TOOLANALYSIS_PATH
ifdh cp -r $CONDOR_DIR_INPUT/$LAPPDFILENAME $TOOLANALYSIS_PATH

#Set the input and output file names
sed -i "8s#.*#InputFile ${PMTFILENAME}#" ${TOOLCHAIN_FILE}/LoadWCSimConfig
sed -i "8s#.*#InputFile ${LAPPDFILENAME}#" ${TOOLCHAIN_FILE}/LoadWCSimLAPPDConfig
#sed -i "3s#.*#OutputFile electron_beamlike_${var}#" ${TOOLCHAIN_FILE}/EnergyExtractorConfig
#sed -i "8s#.*#OutputFile electron_beamlike_${var}#" ${TOOLCHAIN_FILE}/CNNImageConfig
#sed -i "3s#.*#OutputFile muon_beamlike_${var}#" ${TOOLCHAIN_FILE}/EnergyExtractorConfig
#sed -i "8s#.*#OutputFile muon_beamlike_${var}#" ${TOOLCHAIN_FILE}/CNNImageConfig
sed -i "3s#.*#OutputFile gst_${var}#" ${TOOLCHAIN_FILE}/EnergyExtractorConfig
sed -i "8s#.*#OutputFile gst_${var}#" ${TOOLCHAIN_FILE}/CNNImageConfig
sed -i "11s#.*#ParticleID 13#" ${TOOLCHAIN_FILE}/MCRecoEventLoaderConfig

# Run toolanalysis
echo ${TOOLANALYSIS_PATH}/Analyse $TOOLCHAIN_FILE/ToolChainConfig
#${TOOLANALYSIS_PATH}/Analyse $TOOLCHAIN_FILE/ToolChainConfig > cnnimage_beamlike_electron_${var}.log
#${TOOLANALYSIS_PATH}/Analyse $TOOLCHAIN_FILE/ToolChainConfig > cnnimage_beamlike_muon_${var}.log
${TOOLANALYSIS_PATH}/Analyse $TOOLCHAIN_FILE/ToolChainConfig > cnnimage_gst_${var}.log
#exit

echo "Moving the output files to CONDOR OUTPUT:"

if [[ "$TOOLCHAIN_FILE" == *"CNNImage"* ]] 
then
    #echo ifdh cp -r ${TOOLANALYSIS_PATH}/electron_beamlike* ${CONDOR_DIR_OUTPUT}
    #ifdh cp -r ${TOOLANALYSIS_PATH}/electron_beamlike* ${CONDOR_DIR_OUTPUT}
    #ifdh cp -r ${TOOLANALYSIS_PATH}/cnnimage_beamlike_electron_${var}.log ${CONDOR_DIR_OUTPUT}
    #echo ifdh cp -r ${TOOLANALYSIS_PATH}/muon_beamlike* ${CONDOR_DIR_OUTPUT}
    #ifdh cp -r ${TOOLANALYSIS_PATH}/muon_beamlike* ${CONDOR_DIR_OUTPUT}
    #ifdh cp -r ${TOOLANALYSIS_PATH}/cnnimage_beamlike_muon_${var}.log ${CONDOR_DIR_OUTPUT}
    echo ifdh cp -r ${TOOLANALYSIS_PATH}/gst* ${CONDOR_DIR_OUTPUT}
    ifdh cp -r ${TOOLANALYSIS_PATH}/gst* ${CONDOR_DIR_OUTPUT}
    ifdh cp -r ${TOOLANALYSIS_PATH}/cnnimage_gst_${var}.log ${CONDOR_DIR_OUTPUT}
fi
if [[ "$TOOLCHAIN_FILE" == *"ClusterFinder"* ]]
then
    echo ifdh cp -r ${TOOLANALYSIS_PATH}/*.root ${CONDOR_DIR_OUTPUT}
    ifdh cp -r ${TOOLANALYSIS_PATH}/*.root ${CONDOR_DIR_OUTPUT}
fi
### END ###
