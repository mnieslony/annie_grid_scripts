# Submit all data decoder TA jobs for one particular run on the grid
# M. Nieslony, using V. Fischers TA submission script (code based on other people's code as usual)

if [ "$#" -ne 3 ]; then
      #echo "Usage: ./submit_DataDecoder_Run.sh FILEDIR RUN_NR FILES_SUB TRIGOVERLAPZIP BEAMSTATUS"
      #echo "Options are: file directory containing raw data files, run number, files being transferred at submission (1/0), zip-file with trigger overlap files, Beam status file"
      echo "Usage: ./submit_DataDecoder_Run.sh RUN_NR FILES_SUB PART_NR"
      echo "Options are: run number, files being transferred at submission (1/0), part nr of raw data file"
      exit 1
fi

#FILEDIR=$1
#RUN_NR=$2
#FILES_SUB=$3
#TRIGOVERLAP=$4
#BEAMSTATUS=$5

RUN_NR=$1
FILES_SUB=$2
PART_NR=$3

#FILEDIR=/pnfs/annie/raw/raw/${RUN_NR}
FILEDIR=/pnfs/annie/persistent/raw/raw/${RUN_NR}
TRIGOVERLAP=/pnfs/annie/persistent/users/mnieslon/data/trigoverlap/TrigOverlap_R${RUN_NR}.tar.gz
BEAMSTATUS=/pnfs/annie/persistent/users/mnieslon/data/beamdb/${RUN_NR}_beamdb

#Go through all raw data files in the listed directory
entry=${FILEDIR}/RAWDataR${RUN_NR}S0p${PART_NR}
if [ -f "${entry}" ]; then
	echo $entry
	echo "./submit_ToolAnalysis_job_8GB.sh ${entry} DataDecoder ${FILES_SUB} ${TRIGOVERLAP} ${BEAMSTATUS}"
	./submit_ToolAnalysis_job_8GB.sh ${entry} DataDecoder ${FILES_SUB} ${TRIGOVERLAP} ${BEAMSTATUS}
else
        echo "${entry} does not exist"
fi
