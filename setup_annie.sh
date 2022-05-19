##########################################################################
# functions to setup a version of genie
export RWHNODE=0
setup_setup ()
{
  trycvmfs=1
  if [ "$1" == "--nocvmfs" ]; then trycvmfs=0; fi
  # bootstrap ups
  node=`uname -n | cut -d. -f1`
  if [ "$node" == "mac-124096" ]; then
    # robert's laptop
    export RWHNODE=1
    echo source /Users/${USER}/Work/externals/setup;
         source /Users/${USER}/Work/externals/setup;
    ALTDIR=/Users/${USER}/Work/altups;
    if [ -d $ALTDIR ]; then
      export PRODUCTS=${ALTDIR}:${PRODUCTS};
    fi
  else
    # try CVMFS
    CVMFS_SETUP=/cvmfs/fermilab.opensciencegrid.org/products/genie/externals/setup
    CVMFS_AUX=/cvmfs/fermilab.opensciencegrid.org/products/common/db
    BA_SETUP=/grid/fermiapp/products/genie/externals/setup
    BA_AUX=/grid/fermiapp/products/common/db/

    if [ $trycvmfs -eq 1 ]; then
      /cvmfs/grid.cern.ch/util/cvmfs-uptodate ${CVMFS_SETUP}
      cvmfs_status=$?
    else
      cvmfs_status=127
    fi
    if [ ${cvmfs_status} -eq 0 ]; then
      echo source ${CVMFS_SETUP}
           source ${CVMFS_SETUP}
        export PRODUCTS=${PRODUCTS}:${CVMFS_AUX}
    else
      # try bluearc
      echo "$b0: CVMFS installation not available, try BlueArc"
      if [ -f ${BA_SETUP} ]; then
        echo source ${BA_SETUP}
             source ${BA_SETUP}
        export PRODUCTS=${PRODUCTS}:${BA_AUX}
      else
        echo "$b0: failed to find a genie UPS installation"
        echo "    CVMFS_SETUP ${CVMFS_SETUP}"
        echo "    BA_SETUP    ${BA_SETUP}"
        exit 127
      fi
    fi
  fi
  echo "$b0: using PRODUCTS=${PRODUCTS}"
}
setup_annie ()
{
    setup_setup $1
    setup geant4 v4_10_3_p03e -q e17:prof
    setup cmake v3_2_1
    
    if [ $RWHNODE -ne 0 ]; then
      setup getopt v1_1_6
      setup pandora v01_01_00b -q debug:e7:nu
      setup dk2nu v01_01_03b -q debug:e7
    else
      setup ifdhc   # for copying geometry & flux files
    fi
    setup genie_phyopt v3_00_04 -q dkcharmtau
    setup genie_xsec v3_00_04a -q G1802a00000:e1000:k250

}
