#!/bin/bash
#all credits for this script belong to M. O'Flaherty
########################################################
## SET THESE VARIABLES
########################################################
#PROCESSOFFSET=4000	# XXX use this to offset PROCESS (job) number, OR SET TO ZERO OTHERWISE - IT MUST BE SET
PROCESSOFFSET=0
#let EVENTS_PER_DIRTFILE=10000
let EVENTS_PER_WCSIM=1000
#let SPLITFACTOR=$((${EVENTS_PER_DIRTFILE}/${EVENTS_PER_WCSIM}))

SOURCEFILEDIR=/pnfs/annie/persistent/users/mnieslon/wcsim/wcsim_sourcefiles
#SOURCEFILEZIP=wcsim_anniep2v7.tar.gz
#SOURCEFILEZIP=wcsim_michel_rgcff.tar.gz
#SOURCEFILEZIP=wcsim_michel_glassref.tar.gz
#SOURCEFILEZIP=wcsim_michel_qeratiowb.tar.gz
#SOURCEFILEZIP=wcsim_wbratio_new.tar.gz
#SOURCEFILEZIP=wcsim_throughgoing_new.tar.gz
#SOURCEFILEZIP=wcsim_pmtwiseqe.tar.gz
SOURCEFILEZIP=wcsim_pmtwiseqe_opposite.tar.gz

DIRTDIR=/pnfs/annie/persistent/users/moflaher/g4dirt_vincentsgenie/BNB_Water_10k_22-05-17
GENIEDIR=/pnfs/annie/persistent/users/vfischer/genie_files/BNB_Water_10k_22-05-17
OUTDIR=/pnfs/annie/persistent/users/mnieslon/wcsim/output/tankonly/wcsim_ANNIEp2v7_throughgoing


if [ "$#" -lt 4 ]; then
    echo "Usage: ./grid_throughgoing_opposite.sh RUN EV RATIO REF"
    exit 1
fi

export RUN=$1
export EV=$2
export RATIO=$3
export REF=$4

########################################################
## SET THESE VARIABLES
########################################################

echo "setting up software base"
#export CODE_BASEX=/grid/fermiapp/products
export CODE_BASEXX=/cvmfs/larsoft.opensciencegrid.org/products
export CODE_BASE=/cvmfs/fermilab.opensciencegrid.org/products
source ${CODE_BASE}/common/etc/setup
#export PRODUCTS=${PRODUCTS}:${CODE_BASE}/larsoft
#export PRODUCTS=${PRODUCTS}:/grid/fermiapp/products/larsoft:/grid/fermiapp/products
export PRODUCTS=${PRODUCTS}:${CODE_BASE}:${CODE_BASEXX}

echo "setting up products"
setup ifdhc   # for copying geometry & flux files
export IFDH_CP_MAXRETRIES=2  # default 8 tries is silly
setup fife_utils

setup geant4         v4_10_1_p03a -q debug:e10:qt

setup genie        v2_12_2 -q e10:prof:r6
setup genie_phyopt v2_12_0 -q dkcharmtau
setup genie_xsec   v2_12_0 -q DefaultPlusMECWithNC

setup -q debug:e10 xerces_c v3_1_3      ## do we need xerces? for which genie?

setup -q debug:e10:nu root v6_06_08
#source ${CODE_BASEX}/larsoft/root/v6_06_08/Linux64bit+2.6-2.12-e10-nu-debug/bin/thisroot.sh
source ${CODE_BASEXX}/root/v6_06_08/Linux64bit+2.6-2.12-e10-nu-debug/bin/thisroot.sh

setup clhep        v2_3_2_2 -q debug:e10
setup cmake        v3_0_1
# cmake is dumb and will use the ancient /usr/bin/c++ by default unless we explicitly tell it not to
export CXX=$(which g++)
export CC=$(which gcc)

#export XERCESROOT=${CODE_BASEX}/larsoft/xerces_c/v3_1_3/Linux64bit+2.6-2.12-e10-debug
export XERCESROOT=${CODE_BASEXX}/xerces_c/v3_1_3/Linux64bit+2.6-2.12-e10-debug
export G4SYSTEM=Linux-g++
#export ROOT_PATH=${CODE_BASEX}/larsoft/root/v6_06_08/Linux64bit+2.6-2.12-e10-nu-debug/cmake
export ROOT_PATH=${CODE_BASEXX}/root/v6_06_08/Linux64bit+2.6-2.12-e10-nu-debug/cmake
export GEANT4_PATH=${GEANT4_FQ_DIR}/lib64/Geant4-10.1.3
#export GEANT4_MAKEFULL_PATH=${GEANT4_DIR}/${GEANT4_VERSION}/source/geant4.10.01.p02
export ROOT_INCLUDE_PATH=${ROOT_INCLUDE_PATH}:${GENIE}/../include/GENIE
export ROOT_LIBRARY_PATH=${ROOT_LIBRARY_PATH}:${GENIE}/../lib
#export LD_LIBRARY_PATH=/annie/app/users/moflaher/wcsim/wcsim:$LD_LIBRARY_PATH
#export ROOT_INCLUDE_PATH=/annie/app/users/moflaher/wcsim/wcsim/include:$ROOT_INCLUDE_PATH

#Prevent compilation failure on SL7
RELEASE=$(cat /etc/redhat-release)
echo "cat /etc/redhat-release gives: ${RELEASE}"
echo ${RELEASE} | grep "6"
if [ $? -eq 0 ]; then
        echo "Sounds like SL6";
        SL6=1;
else
        echo "sounds like SL7";
        SL6=0;
fi
echo "SL6=${SL6}";
if [ ${SL6} -eq 0 ]; then
        # ROOT externals from ROOT website
        ls /cvmfs/sft.cern.ch/lcg/views/ROOT-latest/x86_64-slc6-gcc49-opt/setup.sh
        echo "ls /cvmfs/sft.cern.ch/lcg/views/ROOT-latest/x86_64-slc6-gcc49-opt/setup.sh gives: $?"
        #source /cvmfs/sft.cern.ch/lcg/views/ROOT-latest/x86_64-slc6-gcc49-opt/setup.sh
        #echo "sourcing ROOT externals gave: $?"
        echo "sourcing steven's ROOT stuff"
        ls /cvmfs/annie.opensciencegrid.org/products/toolanalysis/v0_0_0/extras_for_oasis_build
        echo "ls /cvmfs/annie.opensciencegrid.org/products/toolanalysis/v0_0_0/extras_for_oasis_build gave: $?"
        echo "exporting to LD_LIBRARY_PATH and LD_LIBRARY_PATH"
        export LIBRARY_PATH=${LIBRARY_PATH}:/cvmfs/annie.opensciencegrid.org/products/toolanalysis/v0_0_0/extras_for_oasis_build
        export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/cvmfs/annie.opensciencegrid.org/products/toolanalysis/v0_0_0/extras_for_oasis_build
fi


# get the input file to use
# =========================
# first get the number of the file. This isn't $PROCESS directly, because we need to
# process the same intput file over multiple jobs (otherwise they take too long).
let PROCESSNUM=${PROCESS}  # conversion to number for arithmetic
let THECOUNTER=${PROCESSNUM}+${PROCESSOFFSET}
#let THENUM=$((${THECOUNTER}/${SPLITFACTOR}))   # because this division is integer, this rounds DOWN (29->2)
#let INFILE_OFFSETFACTOR=$((${THECOUNTER}-(${SPLITFACTOR}*${THENUM}))) # this extracts the difference
#let INFILE_OFFSET=$((${INFILE_OFFSETFACTOR}*${EVENTS_PER_WCSIM}))
# e.g. PROCESSNUM=122 -> THENUM=12; INFILE_OFFSETFACTOR=(122-(10*12))=2; -> INFILE_OFFSET=2000 :: process 122 uses file 12, offset 2000
echo "PROCESSNUM=${PROCESSNUM}, PROCESSOFFSET=${PROCESSOFFSET}"
#,  THECOUNTER=PROCESSNUM+PROCESSOFFSET=${THECOUNTER}
#echo "SPLITFACTOR=${SPLITFACTOR}"
#echo "THENUM=THECOUNTER/SPLITFACTOR=${THENUM}"
#echo "INFILE_OFFSETFACTOR=THECOUNTER-(SPLITFACTOR*THENUM)=${INFILE_OFFSETFACTOR}"
#echo "INFILE_OFFSET=INFILE_OFFSETFACTOR*1000=${INFILE_OFFSET}"

echo "this is job PROCESS=${PROCESS}"
#, will process file THENUM=${THENUM}, with offset INFILE_OFFSET=${INFILE_OFFSET}"

# now get the corresponding file. Although files are named `annie_tank_flux.###.root`,
# the numbers ### do not necessarily start from 0, and may not be consecutive.
# instead pull out the n'th file in the list of files that exist, with n = THENUM.
#let SEDNUM=${THENUM}+1  # sed counts lines from 1
#echo "SEDNUM=${SEDNUM}"


# using 'ls -1 dir/pattern' prints matching files 1 per line locally but **not for ifdh**!
# instead we can use 'ifdh findMatchingFiles dir pattern', however we do need an extra trim
# to extract the first field, as it also returns the matching file size
#echo "ifdh findMatchingFiles ${DIRTDIR} annie_tank_flux.*.root | sed -n ${SEDNUM},${SEDNUM}p | awk '{print \$1}'"
#ifdh findMatchingFiles ${DIRTDIR} annie_tank_flux.*.root | sed -n ${SEDNUM},${SEDNUM}p | awk '{print $1}'
#echo "returnval was $?"
#THEFILE=$(ifdh findMatchingFiles ${DIRTDIR} annie_tank_flux.*.root | sed -n ${SEDNUM},${SEDNUM}p | awk '{print $1}')
#echo "THEFILE=${THEFILE}"

#if [ -z ${THEFILE} ]; then
#    echo "FAILED TO EXTRACT INPUT FILE NAME! $THEFILE IS EMPTY!!!"
#    exit 0
#else
#    echo "$THEFILE seems ok"
#fi

# finally, to get the corresponding genie file, and name our wcsim output file properly,
# we need to extract the ### number from this file.
#DIRTFILE=$(basename ${THEFILE})
#TMPSTRING=${DIRTFILE#annie_tank_flux.} # strip the annie_tank_flux. prefix
#THEFILENUM=${TMPSTRING%.root}             # strip the .root suffix

# build the other filenames
#GENIEFILE=gntp.${THEFILENUM}.ghep.root
#OUTFILE=wcsim_throughgoing_R${RUN}_Ratio${RATIO}_Ref${REF}.${THECOUNTER}.root
#OUTFILE=wcsim_throughgoing_R${RUN}_Ratio${RATIO}_GlassRef${REF}.${THECOUNTER}.root
OUTFILE=wcsim_throughgoing_muon_opposite_R${RUN}_default.${THECOUNTER}.root
#OUTFILE=wcsim_0.${PROCESSNUM}.root
#OUTLOG=wcsim_throughgoing_R${RUN}_Ratio${RATIO}_Ref${REF}.${THECOUNTER}.log
#OUTLOG=wcsim_throughgoing_R${RUN}_Ratio${RATIO}_GlassRef${REF}.${THECOUNTER}.log
OUTLOG=wcsim_throughgoing_muon_opposite_R${RUN}_default.${THECOUNTER}.log

#echo "file number extracted from input filepath ${THEFILE}, extracted file number is ${THEFILENUM}"
#echo "input dirt file is ${DIRTDIR}/${DIRTFILE}"
#echo "input genie file is ${GENIEDIR}/${GENIEFILE}"
echo "wcsim output file will be ${OUTDIR}/${OUTFILE}"

# Skip job if output file already exists
echo "checking if output file already exists"
if [ -f ${OUTFILE} ]; then
    echo "input file already exists, skipping this job"
    exit 0
else
    echo "it doesn't"
fi
# TODO: add something to create a new temp outdir based on job num and run the job anyway?

# copy the source files
echo "searching for source files in ${SOURCEFILEDIR}/${SOURCEFILEZIP}"
echo "ifdh ls ${SOURCEFILEDIR}"
ifdh ls ${SOURCEFILEDIR}
ifdh ls ${SOURCEFILEDIR}/${SOURCEFILEZIP} 1>/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "copying source files"
  ifdh cp -D ${SOURCEFILEDIR}/${SOURCEFILEZIP} .
else
  echo "source file zip not found in ${SOURCEFILEDIR}!"
fi

# copy the input files
mkdir build
cd build
#echo "copying the input files ${DIRTDIR}/${DIRTFILE} and ${GENIEDIR}/${GENIEFILE}"
#ifdh cp -D ${DIRTDIR}/${DIRTFILE} .
#ifdh cp -D ${GENIEDIR}/${GENIEFILE} .
#if [ ! -f ${DIRTFILE} ]; then echo "dirt file not found!!!"; exit 14; fi
#if [ ! -f ${GENIEFILE} ]; then echo "genie file not found!!!"; exit 15; fi

# extract and compile the application
cd .. ## added to move out of build
echo "unzipping source files"
tar zxvf ${SOURCEFILEZIP}
echo "sourcing neutron related hadronic environmental variables"
#source WCSim/envHadronic.sh

#copy the histogram input files
cd build
ifdh cp -D ../WCSim/throughgoing.mac .
ifdh cp -D ../WCSim/nuance-files/R*nuance.txt .
cd ..

export mac_through=build/throughgoing.mac
export TEMP_MACRO=build/throughgoing_temp.mac
export MACRO_LOCAL=throughgoing_temp.mac

#Adapt throughgoing.mac file
while read line; do
  if [[ $line == *"/WCSimIO/RootFile"* ]]; then
    echo "/WCSimIO/RootFile wcsim_throughgoing_muon_opposite_R${RUN}_default" >> $TEMP_MACRO
  elif [[ $line == *"/mygen/vecfile"* ]]; then
    echo "/mygen/vecfile R${RUN}_throughgoing_opposite_nuance.txt" >> $TEMP_MACRO
  else
    if [[ $line == *"/run/beamOn"* ]]; then
      echo "/run/beamOn ${EV}" >> $TEMP_MACRO
    else
      echo $line >> $TEMP_MACRO
    fi
  fi
done < ${mac_through}


echo "compiling application"
cd WCSim
make clean
make rootcint
make
cp src/WCSimRootDict_rdict.pcm ./
cd ../build
cmake ../WCSim
make
rm libWCSimRootDict.rootmap
cp ../WCSim/WCSimRootDict_rdict.pcm ./
if [ ! -x ./WCSim ]; then
    if [ -a ./WCSim ]; then
        chmod +x ./WCSim
        hash -r
    fi
fi
if [ ! -x ./WCSim ]; then
    echo "something failed in compilation?! WCSim not found! Files in current directory:"
    ifdh ls ${PWD}
    exit 12
fi

echo "writing primaries_directory.mac"
#echo "/mygen/neutrinosdirectory ${PWD}/gntp.*.ghep.root" >  macros/primaries_directory.mac
#echo "/mygen/primariesdirectory ${PWD}/annie_tank_flux.*.root" >>  macros/primaries_directory.mac
#echo "/mygen/primariesoffset ${INFILE_OFFSET}" >> macros/primaries_directory.mac
# backwards compatibilty with old branches, which don't use the macros folder
#echo "/mygen/neutrinosdirectory ${PWD}/gntp.*.ghep.root" >  primaries_directory.mac
#echo "/mygen/primariesdirectory ${PWD}/annie_tank_flux.*.root" >>  primaries_directory.mac
#echo "/mygen/primariesoffset ${INFILE_OFFSET}" >> primaries_directory.mac
echo "/run/beamOn ${EVENTS_PER_WCSIM}" >> WCSim.mac   # will end the run as rqd if there are fewer events in the input file

RNDM=$(od -vAn -N2 -tu2 < /dev/urandom)
echo "Random number is ${RNDM}"
sed -i -e "1s/.*/\/WCSim\/random\/seed ${RNDM}/" macros/setRandomParameters.mac

sed -i -e "14s#.*#/WCSim/tuning/QEratio 1.00#" macros/tuning_parameters.mac
sed -i -e "10s#.*#/WCSim/tuning/teflonrff 0.55#" macros/tuning_parameters.mac
sed -i -e "15s#.*#/WCSim/tuning/rgcffr7081 0.32#" macros/tuning_parameters.mac
sed -i -e "16s#.*#/WCSim/tuning/QEratioWB 1.00#" macros/tuning_parameters.mac
sed -i -e "22s#.*#/WCSim/tuning/PMTwiseQE 0#" macros/tuning_parameters.mac
#sed -i -e "11s#.*#/WCSim/tuning/holderrff 1.00#" macros/tuning_parameters.mac
#sed -i -e "6s#.*#/WCSim/tuning/bsrff 3.00#" macros/tuning_parameters.mac
sed -i -e "19s#.*#/WCSim/tuning/holder 0#" macros/tuning_parameters.mac

echo "Input of macros/tuning_parameters.mac"
cat macros/tuning_parameters.mac

# run executable here, rename the output file
NOWS=`date "+%s"`
DATES=`date "+%Y-%m-%d %H:%M:%S"`
echo "checkpoint start @ ${DATES} s=${NOWS}"
echo " "

./WCSim ${MACRO_LOCAL} > ${OUTLOG} 2>&1

echo " "
NOWF=`date "+%s"`
DATEF=`date "+%Y-%m-%d %H:%M:%S"`
let DS=${NOWF}-${NOWS}
echo "checkpoint finish @ ${DATEF} s=${NOWF}  ds=${DS}"
echo " "

# compress the output log file
COMPRESSEDLOGNAME=${OUTLOG%.*}.tgz
tar -zcf ${COMPRESSEDLOGNAME} ${OUTLOG}
if [ $? -eq 0 ]; then
  if [ -f ${COMPRESSEDLOGNAME} ]; then
    echo "log file compressed, removing uncompressed file"
    rm ${OUTLOG}
  fi
fi

echo "copying the output files to ${OUTDIR}"
# copy back the output files
DATESTRING=$(date)      # contains a bunch of spaces, dont use in filenames
for file in wcsim_*; do
        tmp=${file%.*}  # get filename without extension
	echo $tmp
	ext=${file##*.} # get extension
	echo $ext
	THEOUTFILE=${tmp}.${THECOUNTER}.${ext}
	echo $THEOUTFILE
        echo "renaming ${file} to ${THEOUTFILE}"
	if [ -f ${THEOUTFILE} ]; then
		echo "bad file rename: this file exists!!"
		THEOUTFILE=${THEOUTFILE}_second
	fi
        mv ${file} ${THEOUTFILE}
        echo "copying ${THEOUTFILE} to ${OUTDIR}"
        ifdh cp -D ${THEOUTFILE} ${OUTDIR}
        if [ $? -ne 0 ]; then echo "something went wrong with the copy?!"; fi
done
for file in *.root; do
	mv ${file} output_file.root
	ifdh cp -D output_file.root ${OUTDIR}
done

# clean things up
cd ..
rm -rf WCSim
rm -rf build
rm -rf ${SOURCEFILEZIP}
