ANNIEPATH=/annie/app/users/vfischer/GENIE
source /grid/fermiapp/products/uboone/setup_uboone.sh
source $ANNIEPATH/setup_annie.sh
setup_annie
setup jobsub_client
export GROUP=annie
# --OS=SL6 --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC

#if [ "$#" -ne 3 ]; then
#    echo "Usage: ./run_annie_ratpac_grid.sh GENIE_FILES_LOCATION OUTPUT_FOLDER_PREFIX OFFSET(opt)"
#    exit 1
#fi

export RATPAC_PATH=/annie/app/users/vfischer/annie-ratpac

export QUEUE=long
export GENIE_FILES_LOCATION=$1
export FILE_PREFIX=$2
export Nb_evts=1000
export Nevts_offset=${3:-0}
export genie_mac=${RATPAC_PATH}/mac/ANNIE_genie.mac

mkdir -p /pnfs/annie/scratch/users/vfischer/ratpac/REP_${FILE_PREFIX}/scripts_macs
mkdir -p ${RATPAC_PATH}/REP_${FILE_PREFIX}/scripts_macs

i_job=0
for file in $GENIE_FILES_LOCATION/Genie2rat_gntp*; do
   i_job=$((i_job + 1))
   file_name=${file##*/}
   filename=${file_name%.*}
   touch ${RATPAC_PATH}/macro_${FILE_PREFIX}_${i_job}_offset${Nevts_offset}.mac
   TEMP_MACRO=${RATPAC_PATH}/macro_${FILE_PREFIX}_${i_job}_offset${Nevts_offset}.mac
   while read line; do
        if [[ $line == *"/generator/add vertexfile"* ]]; then
            echo "/generator/add vertexfile ${file}:default:default:${Nb_evts}:${Nevts_offset}" >> $TEMP_MACRO  
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
    cp ${TEMP_MACRO} /pnfs/annie/scratch/users/vfischer/ratpac/REP_${FILE_PREFIX}/scripts_macs/${macroname}_${i_job}_offset${Nevts_offset}.mac
    MACRO_FILE=${RATPAC_PATH}/REP_${FILE_PREFIX}/scripts_macs/${macroname}_${i_job}_offset${Nevts_offset}.mac
    rm ${TEMP_MACRO}

    jobsub_submit -g -M --memory=4000MB --expected-lifetime=${QUEUE} --group=$GROUP \
                    --resource-provides=usage_model=OPPORTUNISTIC \
                    --jobsub-server=https://fifebatch.fnal.gov:8443 \
                    -f $MACRO_FILE -f $file\
                    -d OUTPUT /pnfs/annie/scratch/users/vfischer/ratpac/REP_${FILE_PREFIX}/ \
                    file:///${RATPAC_PATH}/ratpac_grid.sh ${FILE_PREFIX}_${i_job}_offset${Nevts_offset}.root ${RATPAC_PATH}/REP_${FILE_PREFIX}/scripts_macs/${macroname}_${i_job}_offset${Nevts_offset}.mac

done

