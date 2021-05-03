#!/bin/bash

################################
##### INSTALL DEPENDENCIES #####
################################

##### SET PARAMETERS
usage() { echo "Usage: $0 -d path/to/install/dependencies/programs
       -d: directory path to install dependencies programs
       " 1>&2; exit 1; }

while getopts :s:d: option; do
   case "${option}" in
   d) INSTALL_FOLDER=${OPTARG};;
   *) usage;;
   esac
done
#shift "$((OPTIND-1))"

##### TEST INSTALL_FOLDER VARIABLE
if [[ -z "$INSTALL_FOLDER" ]]; then
   echo "Error: -d flag is empty"
   usage
   exit 1

else

   export INSTALL_FOLDER=$(readlink -f $INSTALL_FOLDER)
   
   if [[ ! -d "$INSTALL_FOLDER" ]]; then
      echo "ERROR: wrong directory path. Please check -d flag"
      echo "Aborting analysis"
      usage
      exit 1
   fi
fi
wait

echo "Install programs in: "$INSTALL_FOLDER


##### Make Installation folder
#export INSTALL_FOLDER=$INSTALL_FOLDER
#mkdir -p $INSTALL_FOLDER


echo "
#--------------------------------#
##### INSTALLING MINICONDA 3 #####
#--------------------------------#
"

if ! command -v conda &> /dev/null; then
   echo "conda CANNOT BE FOUND"
   
   # Make Installation folder
   export INSTALL_FOLDER=$INSTALL_FOLDER
   mkdir -p $INSTALL_FOLDER

   cd $INSTALL_FOLDER
   if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
      chmod +x Miniconda3-latest-Linux-x86_64.sh
      # https://docs.anaconda.com/anaconda/install/silent-mode/
      ./Miniconda3-latest-Linux-x86_64.sh -b -p $INSTALL_FOLDER/miniconda3 -f
      source $INSTALL_FOLDER/miniconda3/bin/activate
      conda init bash
      #https://www.kangzhiq.com/2020/05/02/how-to-activate-a-conda-environment-in-a-remote-machine/
      eval "$(conda shell.bash hook)"
      rm Miniconda3-latest-Linux-x86_64.sh
   elif [[ "$OSTYPE" == "darwin"* ]]; then
      wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
      chmod +x Miniconda3-latest-MacOSX-x86_64.sh
      ./Miniconda3-latest-MacOSX-x86_64.sh -b -p $INSTALL_FOLDER/miniconda3 -f
      source $INSTALL_FOLDER/miniconda3/bin/activate
      conda init bash
      #https://www.kangzhiq.com/2020/05/02/how-to-activate-a-conda-environment-in-a-remote-machine/
      eval "$(conda shell.bash hook)"
      rm Miniconda3-latest-MacOSX-x86_64.sh
   else
      "Error: This is neither linux nor MacOS system"
       exit 1
   fi

else
   echo "conda is installed" 
fi
   
### Configure conda channels
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels anaconda
conda config --add channels conda-forge

### Create conda environment to save Bioinformatic programs
#https://www.kangzhiq.com/2020/05/02/how-to-activate-a-conda-environment-in-a-remote-machine/
conda init bash
eval "$(conda shell.bash hook)"
conda create -y --name sra python=3.8

### Activate conda ivdp environment
conda activate sra

echo "
#-----------------------------#
##### INSTALLING PARALLEL #####
#-----------------------------#
"
conda install -y -n sra -c conda-forge parallel


echo "
#-----------------------------#
##### INSTALLING DOS2UNIX #####
#-----------------------------#
"
conda install -y -n sra -c trent dos2unix 


echo "
#---------------------------#
##### INSTALLING RENAME #####
#---------------------------#
"
conda install -y -n ivdp -c bioconda rename


echo "
#------------------------#
##### INSTALLING SED #####
#------------------------#
"
conda install -y -n sra -c conda-forge sed 


echo "
#------------------------#
##### INSTALLING GIT #####
#------------------------#
"
conda install -y -n sra -c anaconda git


echo "
#-------------------------#
##### INSTALLING PIGZ #####
#-------------------------#
"
conda install -y -n sra -c anaconda pigz


echo "
#-----------------------------#
##### INSTALLING DATAMASH #####
#-----------------------------#
"
conda install -y -n sra -c anaconda datamash


echo "
#-------------------------------#
##### INSTALLING SRATOOLKIT #####
#-------------------------------#
"
conda install -y -n sra -c bioconda sra-tools=2.10.8


echo "
#----------------------------------#
##### INSTALLING ENTREZ-DIRECT #####
#----------------------------------#
"
conda install -y -n sra -c bioconda entrez-direct=13.9


echo "
#---------------------------------#
##### INSTALLING TRIMMOMATICS #####
#---------------------------------#
"
conda install -y -n sra -c bioconda trimmomatic


echo "
#----------------------------------#
##### CHECK INSTALLED PROGRAMS #####
#----------------------------------#
"

echo "#############################################################################"
echo "############## CHECK IF ALL THE PROGRAMS ARE INSTALLED ######################"
echo "If any installed program failed, re-install a previous version. To do that:"
echo "Example using sra-tools package"
echo "Search for versions: conda search sra-tools --info"
echo "Choose a previous version: eg.2.10.8"
echo "Install: conda install --force-reinstall -y -n sra -c bioconda sra-tools=2.10.8"
echo "#############################################################################"
echo
###
###
if ! command -v parallel &> /dev/null; then
   echo "parallel CANNOT BE FOUND"
else
   echo "parallel is installed" 
fi

if ! command -v dos2unix &> /dev/null; then
   echo "dos2unix CANNOT BE FOUND"
else
   echo "dos2unix is installed" 
fi

###
if ! command -v rename &> /dev/null; then
   echo "rename CANNOT BE FOUND"
else
   echo "rename is installed" 
fi

###
if ! command -v sed &> /dev/null; then
   echo "sed CANNOT BE FOUND"
else
   echo "sed is installed" 
fi

###
if ! command -v git &> /dev/null; then
   echo "git CANNOT BE FOUND"
else
   echo "git is installed" 
fi

###
if ! command -v pigz &> /dev/null; then
   echo "pigz CANNOT BE FOUND"
else
   echo "pigz is installed" 
fi

###
if ! command -v datamash &> /dev/null; then
   echo "datamash CANNOT BE FOUND"
else
   echo "datamash is installed" 
fi

###
if ! command -v prefetch &> /dev/null; then
   echo "sra-toolkit CANNOT BE FOUND"
else
   echo "sra-toolkit is installed" 
fi

###
if ! command -v esearch &> /dev/null; then
   echo "entrez-direct CANNOT BE FOUND"
else
   echo "entrez-direct is installed" 
fi

###
if ! command -v trimmomatic &> /dev/null; then
   echo "trimmomatic CANNOT BE FOUND"
else
   echo "trimmomatic is installed" 
fi

##### Deactivate ivdp conda environment
conda deactivate


echo "################################################################################"
echo "# TO RUN THESE PROGRAMS FOR OTHER APPLICATION, ACTIVATE SRA CONDA ENVIRONMENTS #"
echo "############ TO ACTIVATE, TYPE ON TERMINAL: conda activate sra #################"
echo "################################################################################"

echo "
#--------------------------------#
##### INSTALLATION COMPLETED #####
#--------------------------------#
"

