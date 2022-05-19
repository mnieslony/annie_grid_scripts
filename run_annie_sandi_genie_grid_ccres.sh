ANNIEPATH=/annie/app/users/mnieslon/send_grid/
source /grid/fermiapp/products/common/etc/setup
source /cvmfs/larsoft.opensciencegrid.org/products/setup
setup genie v3_00_06c -q e17:prof:py3
setup genie_xsec v3_00_04a -q G1802a00000:e1000:k250
setup genie_phyopt v3_00_04 -q dkcharmtau
setup geant4 v4_10_3_p03e -q e17:prof
source $ANNIEPATH/setup_annie.sh
setup jobsub_client
export GROUP=annie
# --OS=SL6 --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC

export FOLDER_NAME=SANDI_1k_03-31-21_CCRES
mkdir -p /pnfs/annie/persistent/users/mnieslon/genie/${FOLDER_NAME}

# export VOLCUT="-E 900,500,500" 
# 20K GENIE events w/ this cut take 12-25hrs per file
# g4 step takes < ~2.5hr per file

#export VOLCUT="-E 1100,500,500" 
export GEOFILE=annie_v04_sandi.gdml
export TOPVOL=TwbLS_LV
export FIRSTRUN=0
export NEVENTS=1000
export EVLIST=CCRES

export NJOBS=10
export QUEUE=medium

# was 20000 evt, 250 jobs

# jobsub_submit --expected-lifetime=$QUEUE -g --group $GROUP -N ${NJOBS} file://$ANNIEPATH/run_annie_genie.sh \
#      --rock -g ${ANNIEPATH}/${GEOFILE} -r ${FIRSTRUN} -n ${NEVENTS}  \
#          -o /pnfs/annie/persistent/users/mnieslon/genie/${FOLDER_NAME}

jobsub_submit -g --group $GROUP --expected-lifetime=$QUEUE -N ${NJOBS} file://$ANNIEPATH/run_sandi_genie.sh \
                    -g ${GEOFILE} -r ${FIRSTRUN} -n ${NEVENTS} -t ${TOPVOL} \
                    -o /pnfs/annie/persistent/users/mnieslon/genie/${FOLDER_NAME} \
                    --genlist ${EVLIST}

# when those are complete, the run the next stage
# jobsub_submit -g --group $GROUP -N ${NJOBS} file://$ANNIEPATH/run_annie_g4dirt.sh \
#       -r ${FIRSTRUN} -v -i /pnfs/annie/persistent/users/mnieslon/genie \
#          -o /pnfs/annie/persistent/users/mnieslon/g4dirt

# when those are complete, make (and save pdf's) plots
#
# processing a large number of small files can be slow ...
# so make a file to combine the trees in the multiple files

#cd /annie/data/users/mnieslon/   # somewhere not pnfs
#hadd -n 0 annie_tank_flux.2xxx.root /pnfs/annie/persistent/users/mnieslon/g4dirt/annie_tank_flux.2???.root

#root $ANNIEPATH/draw_nsource.C\(\"./annie_tank_flux.2xxx.root\",true\)
