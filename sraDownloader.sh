#!/bin/bash

###################################$$$$$$$$$###
##### GET PARAMETER FILES FROM ivdpRun.sh #####
###################################$$$$$$$$$###
usage() { echo "Usage: $0 -s < submission system > -l <sraList file> -n <number of parallel samples> -o <path/to/output/folder>
       -s: submission system (1: local server; 2: HPCC with slurm)
       -l: path to list of sra run accessions
       -n: number of samples to run in parallel (default=5)
       -o: output directory
       Example: $0 -s 1 -l sraList.txt -n 5 -o /home/rps
       
       " 1>&2; exit 1; }

while getopts :s:l:n:o: option; do
   case "${option}" in
   s) SUBMISSION_SYSTEM=${OPTARG};;
   l) SRA_LIST=${OPTARG};;
   n) BATCH=${OPTARG};;
   o) SRA_DIR=${OPTARG};;
   *) usage;;
   esac
done
shift $((OPTIND -1))


##### PARAMETERS #####
export PROG_DIR=$(dirname $(readlink -f $0))
export SRA_DIR=$(readlink -f $SRA_DIR)
export SRA_LOG=$SRA_DIR/log
export TMP=$SRA_DIR/tmp
export ANALYSIS_ID=$(echo $RANDOM)


##### TEST PARAMETERS sraDownloader.sh #####
if [[ -z $SUBMISSION_SYSTEM ]]; then
   echo "ERROR: -s flag is empty"
   echo "Aborting analysis"
   usage
   exit 1
else
   if [[ $SUBMISSION_SYSTEM != 1 && $SUBMISSION_SYSTEM != 2 ]]; then
      echo "ERROR: invalid value for -s"
      echo "Aborting analysis"
      usage
      exit 1
   fi
fi
   
   
#
if [[ -z "$SRA_LIST" ]]; then
   echo "ERROR: -l flag is empty"
   echo "Aborting analysis"
   usage
   exit 1

else

   export SRA_LIST=$(readlink -f $SRA_LIST)
   
   if [[ ! -f "$SRA_LIST" ]]; then
      echo "ERROR: check the path to list of sra run accessions (-l option)"
      echo "Aborting analysis"
      usage
      exit 1
   fi
fi
wait


#  
if [[ -z "$SRA_DIR" ]]; then
   echo "ERROR: -o flag is empty"
   echo "Aborting analysis"
   usage
   exit 1

else

   mkdir -p $SRA_DIR/log 2> /dev/null
   mkdir -p $SRA_DIR/tmp 2> /dev/null
fi
wait


#
if [[ ! -d "$SRA_DIR" ]]; then
   echo "ERROR: $SRA_DIR is not a valid directory. Check -o option"
   usage
   exit 1
fi


#
if [[ -z "$BATCH" ]]; then
   export BATCH=5
else
   export BATCH=$BATCH
fi


### CHECK CONDA ENVIRONMENTS
eval "$(conda shell.bash hook)"
conda activate sra
export CONDA_DEFAULT_ENV=$CONDA_DEFAULT_ENV

# Check if conda ivdp environment is active
if [[ "$CONDA_DEFAULT_ENV" != "sra" ]]; then
   echo
   echo "ERROR: Install conda dependencies before run sraDownloader"
   exit 1
fi


##### PREPARE SAMPLE LIST
dos2unix $SRA_LIST 2> /dev/null


##### RUN sraDownloader #####

if [[ $SUBMISSION_SYSTEM == 1 ]]; then
   set -m
   nohup $PROG_DIR/program/runSRA.sh > $SRA_LOG/logSraDownloader.txt 2>&1 &
   echo $! > $SRA_LOG/pid_SraDownloader.txt
   echo "Running sraDownloader"
   echo "To check the main log, run the command line: tail -f -n +1 $SRA_LOG/logSraDownloader.txt"
   echo "To kill this SRA analysis, run the command line: kill -- -$(cat "$SRA_LOG"/pid_SraDownloader.txt)"

else

   rm $SRA_LOG/jobid1.txt > /dev/null 2>&1
   
   for i in $(cat $SRA_LIST); do
      JOBID1=$(sbatch --output $SRA_LOG/${i}.txt  --job-name="$ANALYSIS_ID"_sra \
      --export=PROG_DIR=$PROG_DIR,SRA_DIR=$SRA_DIR,SRA_LOG=$SRA_LOG,TMP=$TMP,i=$i \
      $PROG_DIR/program/sraSlurm.sb)
      echo $JOBID1 >> $SRA_LOG/jobid1.txt
   done
   
   WAIT1=$(cat $SRA_LOG/jobid1.txt | awk '{print $4}' | tr "\n" ":" | sed 's/.$//')
   wait
   
   sbatch --dependency=afterok:$WAIT1 --job-name="$ANALYSIS_ID"_sraList \
   --output=$SRA_LOG/sraFinalList.txt \
   --export=PROG_DIR=$PROG_DIR,SRA_DIR=$SRA_DIR,SRA_LOG=$SRA_LOG,TMP=$TMP,SRA_LIST=$SRA_LIST \
   $PROG_DIR/program/sraFinalList.sb
   wait
   echo

   echo "Running sraDownloader"
   echo "To check each individual log, run the command line: tail -f -n +1 $SRA_LOG/sra_number.txt"
   echo "Just replace sra_number by SRA run accession number"
   echo "To kill this sraDownloader, run the command line:"
   echo "    for job in \$(squeue -u $USER | grep "$ANALYSIS_ID" | awk '{print \$1}'); do scancel \$job; done"

fi
