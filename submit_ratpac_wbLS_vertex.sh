# Submit ratpac jobs starting from vertex files (generated from GENIE --> genie2rat)
# Based on code by V. Fischer

source /cvmfs/annie.opensciencegrid.org/setup_annie.sh
setup jobsub_client
export GROUP=annie

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: ./submit_ratpac_wbLS_vertex.sh GENIE_FILES_LOCATION OUTPUT_FOLDER_PREFIX OFFSET(opt)"
    exit 1
fi

export RATPAC_PATH=/annie/app/users/mnieslon/rat-pac

export QUEUE=long
export GENIE_FILES_LOCATION=$1
export FILE_PREFIX=$2
export Nb_evts=50
export Nevts_offset=${3:-0}
export genie_mac=${RATPAC_PATH}/mac/ANNIE_genie.mac
export GRID_TAR_PATH=/pnfs/annie/persistent/users/mnieslon/ratpac/tar-files/

#The following 2 lines should already be executed in advance since the script does not have enough rights to create directories in some cases (just create the directories by hand)
mkdir -p /pnfs/annie/persistent/users/mnieslon/ratpac/REP_${FILE_PREFIX}/scripts_macs
mkdir -p ${RATPAC_PATH}/REP_${FILE_PREFIX}/scripts_macs

i_job=0
for file in $GENIE_FILES_LOCATION/SANDI_1k_10-15-20.*.root; do
#for file in $GENIE_FILES_LOCATION/SANDI_500MeV_1k_04-01-21.*.root; do
   i_job=$((i_job + 1))
   file_name=${file##*/}
   filename=${file_name%.*}
   touch ${RATPAC_PATH}/macro_${FILE_PREFIX}_${i_job}_offset${Nevts_offset}.mac
   TEMP_MACRO=${RATPAC_PATH}/macro_${FILE_PREFIX}_${i_job}_offset${Nevts_offset}.mac
   while read line; do
        if [[ $line == *"/generator/add vertexfile"* ]]; then
            echo "/generator/add vertexfile ${file_name}:default:default:${Nb_evts}:${Nevts_offset}" >> $TEMP_MACRO  
        else
            if [[ $line == *"/run/beamOn"* ]]; then
                echo "/run/beamOn ${Nb_evts}" >> $TEMP_MACRO
            else
                echo $line >> $TEMP_MACRO
            fi
        fi
    done < ${genie_mac}    
  
    macro_name=${genie_mac##*/}
    macroname=${macro_name%.*}
    cp ${TEMP_MACRO} ${RATPAC_PATH}/REP_${FILE_PREFIX}/scripts_macs/${macroname}_${i_job}_offset${Nevts_offset}.mac
    cp ${TEMP_MACRO} /pnfs/annie/persistent/users/mnieslon/ratpac/REP_${FILE_PREFIX}/scripts_macs/${macroname}_${i_job}_offset${Nevts_offset}.mac
    #MACRO_FILE=${RATPAC_PATH}/REP_${FILE_PREFIX}/scripts_macs/${macroname}_${i_job}_offset${Nevts_offset}.mac
    MACRO_FILE=/pnfs/annie/persistent/users/mnieslon/ratpac/REP_${FILE_PREFIX}/scripts_macs/${macroname}_${i_job}_offset${Nevts_offset}.mac
    rm ${TEMP_MACRO}

    jobsub_submit -g -M --memory=4000MB --expected-lifetime=${QUEUE} --group=$GROUP \
                    --resource-provides=usage_model=OPPORTUNISTIC \
                    --jobsub-server=https://fifebatch.fnal.gov:8443 \
                    -f $MACRO_FILE -f ${GRID_TAR_PATH}/ratpac_for_grid_ncapture2.tar.gz -f ${GRID_TAR_PATH}/geant4.10.01.02_for_grid.tar.gz -f ${file} \
                    -d OUTPUT /pnfs/annie/persistent/users/mnieslon/ratpac/REP_${FILE_PREFIX}/ \
                    file:////annie/app/users/mnieslon/send_grid/ratpac_grid.sh ${FILE_PREFIX}_${i_job}_offset${Nevts_offset}.root ${RATPAC_PATH}/REP_${FILE_PREFIX}/scripts_macs/${macroname}_${i_job}_offset${Nevts_offset}.mac ${file_name}

done

