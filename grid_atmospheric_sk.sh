#!/bin/bash

########################################################
## SET THESE VARIABLES
########################################################

PROCESSOFFSET=0
let EVENTS_PER_DIRTFILE=5000
let EVENTS_PER_WCSIM=1000
let SPLITFACTOR=$((${EVENTS_PER_DIRTFILE}/${EVENTS_PER_WCSIM}))


SOURCEFILEDIR=/pnfs/annie/persistent/users/mnieslon/wcsim/wcsim_sourcefiles
### XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
#SOURCEFILEZIP=wcsim_sk_Gd_p32_2020-11-30.tar.gz
#SOURCEFILEZIP=wcsim_atmospheric_sk_geniegamma_30-12-20_verbose.tar.gz
#SOURCEFILEZIP=wcsim_atmospheric_sk_customgamma_04-01-21.tar.gz
#SOURCEFILEZIP=wcsim_atmospheric_sk_geniegamma_21-12-20.tar.gz
#SOURCEFILEZIP=wcsim_atmospheric_sk_geniegamma_27-02-21.tar.gz
SOURCEFILEZIP=wcsim_atmospheric_sk_customgamma_28-02-21.tar.gz
#SOURCEFILEZIP=wcsim_SK_atmospheric_wp32.tar.gz
### DID YOU UPDATE dirtdirectory.txt, geniedirectory.txt, CommitHash.txt AND gitstatusstring.txt *BEORE* ZIPPING?
### run `git diff HEAD > gitstatusstring.txt && cat .git/$(cat .git/HEAD | awk '{ print $2; }') > CommitHash.txt`
### or run WCSim before performing the zip to populate the later files.
### dirtdirectory.txt and geniedirectory.txt MUST BE SET BY HAND
### XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX

DIRTDIR=/pnfs/annie/persistent/users/moflaher/g4dirt_vincentsgenie/BNB_Water_10k_22-05-17
#GENIEDIR=/pnfs/annie/persistent/users/mnieslon/genie/Atmospheric_2020-04-14
#GENIEDIR=/pnfs/annie/persistent/users/dmaksimo/genie/Atmospheric_2020-05-05
GENIEDIR=/pnfs/annie/persistent/users/mnieslon/genie/Atmospheric_2020-11-28
TALYSDIR=/pnfs/annie/persistent/users/mnieslon/genie/talys_files
#OUTDIR=/pnfs/annie/persistent/users/mnieslon/wcsim/output/tankonly/wcsim_sk_atmospheric_2020-11-28
#OUTDIR=/pnfs/annie/persistent/users/mnieslon/wcsim/output/tankonly/wcsim_07-01-21_Atmospheric_SK_GenieGamma
#OUTDIR=/pnfs/annie/persistent/users/mnieslon/wcsim/output/tankonly/wcsim_27-02-21_Atmospheric_SK_GenieGamma
OUTDIR=/pnfs/annie/persistent/users/mnieslon/wcsim/output/tankonly/wcsim_28-02-21_Atmospheric_SK_CustomGamma

#GENIEFILENAME=gntp.*.ghep.root
#GENIEFILENAME=atmospheric.*.root
GENIEFILENAME=gntp.*.gst.root
TALYSFILE=O15.root

## make the output directory if it doesn't exist
## =============================================
#echo "checking if output directory already exists"
#if [ -f ${OUTDIR} ]; then
#    echo "output directory already exists"
#else
#    echo "making the output directory ${OUTDIR}"
#    mkdir -p ${OUTDIR}
#fi

########################################################
## SET THESE VARIABLES
########################################################


echo "setting up software base"
#export CODE_BASE=/grid/fermiapp/products
export CODE_BASE=/cvmfs/fermilab.opensciencegrid.org/products
source ${CODE_BASE}/common/etc/setup
export PRODUCTS=${PRODUCTS}:${CODE_BASE}/larsoft

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
source ${ROOTSYS}/bin/thisroot.sh

setup clhep        v2_3_2_2 -q debug:e10
setup cmake        v3_0_1
# cmake is dumb and will use the ancient /usr/bin/c++ by default unless we explicitly tell it not to
export CXX=$(which g++)
export CC=$(which gcc)

export XERCESROOT=${XERCESCROOT}
export G4SYSTEM=Linux-g++
export ROOT_PATH=${ROOTSYS}/cmake
export GEANT4_PATH=$(ls -d ${GEANT4_FQ_DIR}/lib64/*/)
#export GEANT4_MAKEFULL_PATH=${GEANT4_DIR}/${GEANT4_VERSION}/source/geant4.10.01.p02
export ROOT_INCLUDE_PATH=${ROOT_INCLUDE_PATH}:${GENIE}/../include/GENIE
export ROOT_LIBRARY_PATH=${ROOT_LIBRARY_PATH}:${GENIE}/../lib
#export LD_LIBRARY_PATH=/annie/app/users/moflaher/WCSim/WCSim:$LD_LIBRARY_PATH
#export ROOT_INCLUDE_PATH=/annie/app/users/moflaher/WCSim/WCSim/include:$ROOT_INCLUDE_PATH

# Added 6/7/19 because some jobs (maybe submitted with OFFSITE?) failed during compilation 
# because it could not find libpcre.so.0 ...
# from https://root.cern/how-setup-root-externals-afscvmfs
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
let THENUM=$((${THECOUNTER}/${SPLITFACTOR}))   # because this division is integer, this rounds DOWN (29->2)
let INFILE_OFFSETFACTOR=$((${THECOUNTER}-(${SPLITFACTOR}*${THENUM}))) # this extracts the difference
let INFILE_OFFSET=$((${INFILE_OFFSETFACTOR}*${EVENTS_PER_WCSIM}))
# e.g. PROCESSNUM=122 -> THENUM=12; INFILE_OFFSETFACTOR=(122-(10*12))=2; -> INFILE_OFFSET=2000 :: process 122 uses file 12, offset 2000
echo "PROCESSNUM=${PROCESSNUM}, PROCESSOFFSET=${PROCESSOFFSET}, THECOUNTER=PROCESSNUM+PROCESSOFFSET=${THECOUNTER}"
echo "SPLITFACTOR=${SPLITFACTOR}"
echo "THENUM=THECOUNTER/SPLITFACTOR=${THENUM}"
echo "INFILE_OFFSETFACTOR=THECOUNTER-(SPLITFACTOR*THENUM)=${INFILE_OFFSETFACTOR}"
echo "INFILE_OFFSET=INFILE_OFFSETFACTOR*1000=${INFILE_OFFSET}"

echo "this is job PROCESS=${PROCESS}, will process file THENUM=${THENUM}, with offset INFILE_OFFSET=${INFILE_OFFSET}"

THEFILENUM=$THENUM

# build the other filenames
#GENIEFILE=gntp.${THEFILENUM}.ghep.root
#GENIEFILE=atmospheric.${THEFILENUM}.root
GENIEFILE=gntp.${THEFILENUM}.gst.root
OUTFILE=wcsim_atmospheric.${THEFILENUM}.${INFILE_OFFSETFACTOR}.root
OUTLOG=wcsim_atmospheric.log

echo "file number extracted from input filepath ${THEFILE}, extracted file number is ${THEFILENUM}"
echo "input dirt file is ${DIRTDIR}/${DIRTFILE}"
echo "input genie file is ${GENIEDIR}/${GENIEFILE}"
echo "input talys files are in directory ${TALYSDIR}"
echo "WCSim output file will be ${OUTDIR}/${OUTFILE}"

# Skip job if output file already exists
echo "checking if output file already exists"
if [ -f ${OUTFILE} ]; then
    echo "output file already exists, skipping this job"
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
echo "copying the input files ${TALYSDIR}/* and ${GENIEDIR}/${GENIEFILE}"
#ifdh cp -D ${DIRTDIR}/${DIRTFILE} .
ifdh cp -D ${GENIEDIR}/${GENIEFILE} .
#ifdh cp -D ${TALYSDIR}/* .
ifdh cp -D ${TALYSDIR}/O15.root .
ifdh cp -D ${TALYSDIR}/N15.root .
ifdh cp -D ${TALYSDIR}/N14.root .
ifdh cp -D ${TALYSDIR}/C14.root .
ifdh cp -D ${TALYSDIR}/C13.root .
ifdh cp -D ${TALYSDIR}/C11.root .
ifdh cp -D ${TALYSDIR}/C10.root .
ifdh cp -D ${TALYSDIR}/Li9.root .
ifdh cp -D ${TALYSDIR}/Li7.root .
ifdh cp -D ${TALYSDIR}/O15.root .
ifdh cp -D ${TALYSDIR}/Be10.root .
ifdh cp -D ${TALYSDIR}/Be9.root .
ifdh cp -D ${TALYSDIR}/B11.root .
ifdh cp -D ${TALYSDIR}/B10.root .
ifdh cp -D ${TALYSDIR}/B9.root .
ifdh cp -D ${TALYSDIR}/O15gamma.root .
ifdh cp -D ${TALYSDIR}/N15gamma.root .
ifdh cp -D ${TALYSDIR}/N14gamma.root .
ifdh cp -D ${TALYSDIR}/C14gamma.root .
ifdh cp -D ${TALYSDIR}/C13gamma.root .
ifdh cp -D ${TALYSDIR}/C11gamma.root .
ifdh cp -D ${TALYSDIR}/C10gamma.root .
ifdh cp -D ${TALYSDIR}/Li9gamma.root .
ifdh cp -D ${TALYSDIR}/Li7gamma.root .
ifdh cp -D ${TALYSDIR}/O15gamma.root .
ifdh cp -D ${TALYSDIR}/Be10gamma.root .
ifdh cp -D ${TALYSDIR}/Be9gamma.root .
ifdh cp -D ${TALYSDIR}/B11gamma.root .
ifdh cp -D ${TALYSDIR}/B10gamma.root .
ifdh cp -D ${TALYSDIR}/B9gamma.root .
echo "contents of pwd after copying:"
ifdh ls ${PWD}
#if [ ! -f ${DIRTFILE} ]; then echo "dirt file not found!!!"; exit 14; fi
if [ ! -f ${GENIEFILE} ]; then echo "genie file not found!!!"; exit 15; fi
if [ ! -f ${TALYSFILE} ]; then echo "talys exemplary file O15 not found!!!"; exit 16; fi

# extract and compile the application
cd .. ## added to move out of build
echo "unzipping source files"
tar zxvf ${SOURCEFILEZIP}
echo "sourcing neutron related hadronic environmental variables"
source WCSim/envHadronic.sh

echo "compiling application"
cd WCSim_SK
make clean
make rootcint
make
cp src/WCSimRootDict_rdict.pcm ./
cd ../build
cmake ../WCSim_SK
make
rm libWCSimRootDict.rootmap
cp ../WCSim_SK/WCSimRootDict_rdict.pcm ./
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
#echo "/mygen/neutrinosdirectory ${PWD}/${GENIEFILENAME}" >  macros/primaries_directory.mac
#echo "/mygen/primariesdirectory ${PWD}/annie_tank_flux.*.root" >>  macros/primaries_directory.mac
echo "/mygen/geniedirectory ${PWD}/${GENIEFILENAME}" >> macros/primaries_directory.mac
echo "/mygen/talysdirectory ${PWD}/" >> macros/primaries_directory.mac
echo "/mygen/primariesoffset ${INFILE_OFFSET}" >> macros/primaries_directory.mac
# backwards compatibilty with old branches, which don't use the macros folder
#echo "/mygen/neutrinosdirectory ${PWD}/${GENIEFILENAME}" >  primaries_directory.mac
#echo "/mygen/primariesdirectory ${PWD}/annie_tank_flux.*.root" >>  primaries_directory.mac
echo "/mygen/geniedirectory ${PWD}/${GENIEFILENAME}" >> primaries_directory.mac
echo "/mygen/talysdirectory ${PWD}/" >> primaries_directory.mac
echo "/mygen/primariesoffset ${INFILE_OFFSET}" >> primaries_directory.mac
echo "/run/beamOn ${EVENTS_PER_WCSIM}" >> WCSim.mac   # will end the run as rqd if there are fewer events in the input file

# so that we can put the information into the WCSimRootHeader, we need to give WCSim the 
# upstream directory information: we'll have it read a couple of files
echo $DIRTDIR >> dirtdirectory.txt
echo $GENIEDIR >> geniedirectory.txt
echo $TALYSDIR >> talysdirectory.txt

#Set random seed
RNDM=$(od -vAn -N2 -tu2 < /dev/urandom)
echo "Random number is ${RNDM}"
sed -i -e "1s/.*/\/WCSim\/random\/seed ${RNDM}/" macros/setRandomParameters.mac

# run executable here, rename the output file
NOWS=`date "+%s"`
DATES=`date "+%Y-%m-%d %H:%M:%S"`
echo "checkpoint start @ ${DATES} s=${NOWS}"
echo " "

./WCSim WCSim.mac > ${OUTLOG} 2>&1
#./WCSim WCSim.mac

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

# copy over the source files, if they don't exist
if [ ! -f ${OUTDIR}/${SOURCEFILEZIP} ]; then
    echo "copying source files"
    ifdh cp -D ${SOURCEFILEDIR}/${SOURCEFILEZIP} ${OUTDIR}
else
    echo "source files already in output directory"
fi

echo "copying the output files to ${OUTDIR}"
# copy back the output files
DATESTRING=$(date)      # contains a bunch of spaces, dont use in filenames
for file in wcsim_*; do
        tmp=${file%.*}  # get filename without extension
	ext=${file##*.} # get extension
	THEOUTFILE=${tmp}.${THEFILENUM}.${INFILE_OFFSETFACTOR}.${ext}
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

# copy the file showing any uncommited git differences from the commit recorded, just in case
if [ -s ../WCSim/gitstatusstring.txt ]; then
  if [ ! -f ${OUTDIR}/gitstatusstring.txt ]; then
    echo "copying uncommited changes!"
    ifdh cp -D ../WCSim/gitstatusstring.txt ${OUTDIR}
  fi
fi

# clean things up
cd ..
rm -rf WCSim
rm -rf build
rm -rf ${SOURCEFILEZIP}
