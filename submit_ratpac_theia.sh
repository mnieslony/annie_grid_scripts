# Submit ratpac jobs starting for IBD events in THEIA
# Based on code by V. Fischer

source /cvmfs/annie.opensciencegrid.org/setup_annie.sh
setup jobsub_client
export GROUP=annie

if [ "$#" -lt 0 ] || [ "$#" -gt 0 ]; then
    echo "Usage: ./submit_ratpac_theia.sh"
    exit 1
fi

export RATPAC_PATH=/annie/app/users/mnieslon/ratpac-theia
export PNFS_PATH=/pnfs/annie/persistent/users/mnieslon/ratpac/mac-files/

export QUEUE=long
export OUTDIR=IBD_3pct_2021-06-10
export MACRO=${RATPAC_PATH}/theia-ibd.mac
export GRID_TAR_PATH=/pnfs/annie/persistent/users/mnieslon/ratpac/tar-files/

#The following 2 lines should already be executed in advance since the script does not have enough rights to create directories in some cases (just create the directories by hand)
mkdir -p /pnfs/annie/persistent/users/mnieslon/ratpac-theia/${OUTDIR}
mkdir -p /pnfs/annie/persistent/users/mnieslon/ratpac-theia/${OUTDIR}/scripts_macs
#ifdh cp -r ${MACRO} /pnfs/annie/persistent/users/mnieslon/ratpac/${OUTDIR}/scripts_macs/
export MACRO_FILE=${PNFS_PATH}/theia-ibd.mac

jobsub_submit -g -N 1000 --memory=4000MB --expected-lifetime=${QUEUE} --group=$GROUP \
                    --resource-provides=usage_model=OPPORTUNISTIC \
                    --jobsub-server=https://fifebatch.fnal.gov:8443 \
                    -f $MACRO_FILE -f ${GRID_TAR_PATH}/ratpac-theia-grid-3pct-25pct.tar.gz -f ${GRID_TAR_PATH}/geant4.10.01.02_for_grid.tar.gz\
                    -d OUTPUT /pnfs/annie/persistent/users/mnieslon/ratpac-theia/${OUTDIR}/ \
                    file:////annie/app/users/mnieslon/send_grid/ratpac-theia_grid.sh theia_ibd ${MACRO_FILE} \


