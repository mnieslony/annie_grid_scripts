# Submit all data decoder TA jobs for one particular run on the grid
# M. Nieslony, using V. Fischers TA submission script (code based on other people's code as usual)

if [ "$#" -ne 3 ]; then
      #echo "Usage: ./submit_DataDecoder_Run.sh FILEDIR RUN_NR FILES_SUB TRIGOVERLAPZIP BEAMSTATUS"
      #echo "Options are: file directory containing raw data files, run number, files being transferred at submission (1/0), zip-file with trigger overlap files, Beam status file"
      echo "Usage: ./submit_Classification.sh PMTFILES LAPPDFILES FILES_SUB"
      echo "Options are: directory of simulation files, files being transferred at submission (1/0)"
      exit 1
fi

PMTFILES=$1
LAPPDFILES=$2
FILES_SUB=$3

i=0

#Go through all raw data files in the listed directory
while read -r PMTFILE && read -r LAPPDFILE <&3
do
	echo $PMTFILE
	echo $LAPPDFILE
	echo "./submit_ToolAnalysis_Classification_job.sh PrepareClassificationTraining ${FILES_SUB} ${PMTFILE} ${LAPPDFILE} ${i}"
	./submit_ToolAnalysis_Classification_job.sh PrepareClassificationTraining ${FILES_SUB} ${PMTFILE} ${LAPPDFILE} ${i}
	i=$((i+1))
done < $PMTFILES 3<$LAPPDFILES

