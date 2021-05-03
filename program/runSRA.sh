#!/bin/bash

echo
echo
echo "#@#############################################################"
echo "#@ DOWNLOAD AND CONVERT SRA FILES: $OUTPUT_NAME "
echo
D1=$(date "+%D    %T")
echo "#@ Date and Time: $D1"
echo

START1=$(date +%s)

##### Run download SRA files and Convert to FASTQ files
n=0
for i in $(cat $SRA_LIST); do
   export i=$i
   echo $i
   
   $PROG_DIR/program/sra.sh > $SRA_LOG/"$i".txt 2>&1 &
   
   # limit jobs
   if (( $(($((++n)) % $BATCH)) == 0 )) ; then
   wait # wait until all have finished (not optimal, but most times good enough)
   echo $n Files completed
   fi

done
wait

##### Check successful and failed SRA run accessions
mkdir -p $SRA_DIR/samples 2> /dev/null
cp $SRA_LIST $SRA_DIR/samples/sra_list.txt 2> /dev/null
ls $SRA_DIR/*fastq* | rev | awk -F\/ '{print $1}' | rev | awk -F"_" '{print $1}' | awk -F"." '{print $1}' | sort | uniq > $SRA_DIR/samples/sra_download_convert_successful.txt

# Compare original list and list with downloaded SRA files (just in case any sample failed during download and convertion)
comm -23 <(cat $SRA_DIR/samples/sra_list.txt | sort | uniq) <(cat $SRA_DIR/samples/sra_download_convert_successful.txt | sort | uniq) > $SRA_DIR/samples/sra_download_convert_failed.txt
wait
echo

rm -r $TMP 2> /dev/null
wait

END1=$(date +%s)
DIFF1=$(( $END1 - $START1 ))

echo
echo "#@ DOWNLOAD AND CONVERT SRA FILES TOOK $(printf '%dh:%dm:%ds\n' $(($DIFF1/3600)) $(($DIFF1%3600/60)) $(($DIFF1%60)))"
echo "#@#############################################################"


