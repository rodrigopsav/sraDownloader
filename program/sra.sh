#!/bin/bash


echo "#@##############################################"
echo "#@ PREFETCH SRA: DOWNLOAD SAMPLE $i"
echo
D1=`date "+%D    %T"`
echo "#@ Date and Time: $D1"
echo

START1=$(date +%s)

prefetch --max-size 300000000 --force yes -O $SRA_DIR $i
wait

mv $SRA_DIR/$i/${i}.sra $SRA_DIR/${i}.sra
wait
rm -r $SRA_DIR/$i 2>/dev/null


END1=$(date +%s)
DIFF1=$(( $END1 - $START1 ))

echo
echo "#@ DOWNLOAD SRA SAMPLE $i TOOK $(printf '%dh:%dm:%ds\n' $(($DIFF1/3600)) $(($DIFF1%3600/60)) $(($DIFF1%60)))"
echo "#@##################################################################"

echo
echo

echo "#@##############################################"
echo "#@ INTEGRITY OF DOWNLOADS (MD5SUM): SAMPLE $i"
echo
D2=`date "+%D    %T"`
echo "#@ Date and Time: $D2"
echo

START2=$(date +%s)

vdb-validate $SRA_DIR/${i}.sra
wait

if [[ "$(grep -o 'consistent' $SRA_LOG/${i}.txt)" != "consistent" ]]; then
   rm $SRA_DIR/"${i}.sra"
else
   touch -m $SRA_DIR/"${i}.sra"
fi
wait


END2=$(date +%s)
DIFF2=$(( $END2 - $START2 ))

echo
echo "#@ MD5SUM CHECK SAMPLE $i TOOK $(printf '%dh:%dm:%ds\n' $(($DIFF2/3600)) $(($DIFF2%3600/60)) $(($DIFF2%60)))"
echo "#@##################################################################"

echo
echo


echo "#@##############################################"
echo "#@ CONVERT SRA to FASTQ: SAMPLE $i"
echo
D3=`date "+%D    %T"`
echo "#@ Date and Time: $D1"
echo

START3=$(date +%s)

### ROUND 1
mv $SRA_DIR/${i}.sra $SRA_DIR/${i}
wait

fasterq-dump -f --temp $TMP -O $SRA_DIR $SRA_DIR/$i
wait


### ROUND 2
ls $SRA_DIR/${i}* | grep "fastq" > $SRA_DIR/list1_${i}_fastq.txt
wait
if [[ "$(cat $SRA_DIR/list1_${i}_fastq.txt | wc -l)" -gt "0" ]]; then
   echo "FASTQ files from ${i} had already created in round 1"
else
   fasterq-dump -f --temp $TMP -O $SRA_DIR $SRA_DIR/$i
fi
wait

### ROUND 3
ls $SRA_DIR/${i}* | grep "fastq" > $SRA_DIR/list2_${i}_fastq.txt
wait
if [[ "$(cat $SRA_DIR/list2_${i}_fastq.txt | wc -l)" -gt "0" ]]; then
   echo "FASTQ files from ${i} had already created in round 2"
else
   fasterq-dump -f --temp $TMP -O $SRA_DIR $SRA_DIR/$i
fi
wait

### DELETE FAILED FILES
ls $SRA_DIR/${i}* | grep "fastq" > $SRA_DIR/list3_${i}_fastq.txt
wait
if [[ "$(cat $SRA_DIR/list3_${i}_fastq.txt | wc -l)" -gt "0" ]]; then
   echo "FASTQ files from ${i} had already created in round 3"
else
   echo " FASTQ files from ${i} failed"
fi
wait

mv $SRA_DIR/${i} $SRA_DIR/${i}.sra
wait

rm $SRA_DIR/list1_${i}_fastq.txt 2> /dev/null
rm $SRA_DIR/list2_${i}_fastq.txt 2> /dev/null
rm $SRA_DIR/list3_${i}_fastq.txt 2> /dev/null
rm -r $SRA_DIR/${i}.sra 2> /dev/null
rm -r $PROG_DIR/${i} 2> /dev/null
wait

END3=$(date +%s)
DIFF3=$(( $END3 - $START3 ))

echo
echo "#@ CONVERT SRA TO FASTQ SAMPLE $i TOOK $(printf '%dh:%dm:%ds\n' $(($DIFF3/3600)) $(($DIFF3%3600/60)) $(($DIFF3%60)))"
echo "#@##################################################################"

echo
echo

echo "#@##############################################"
echo "#@ TRIMMOMATIC: SAMPLE $i"
echo
D4=`date "+%D    %T"`
echo "#@ Date and Time: $D1"
echo

START4=$(date +%s)

if [[ "$(ls $SRA_DIR/${i}* | grep "fastq" | wc -l)" == 1 ]]; then

   trimmomatic SE -threads 16 -phred33 \
   $SRA_DIR/${i}.fastq \
   $SRA_DIR/${i}_trim.fastq.gz \
   LEADING:5 TRAILING:5 SLIDINGWINDOW:4:15 AVGQUAL:15 MINLEN:35
   wait
   
   rm -r $SRA_DIR/${i}.fastq
   mv $SRA_DIR/${i}_trim.fastq.gz $SRA_DIR/${i}.fastq.gz

else

   trimmomatic PE -threads 16 -phred33 \
   $SRA_DIR/${i}_1.fastq $SRA_DIR/${i}_1.fastq \
   $SRA_DIR/${i}_R1_paired.fastq.gz $SRA_DIR/${i}_R1_unpaired.fastq.gz \
   $SRA_DIR/${i}_R2_paired.fastq.gz $SRA_DIR/${i}_R2_unpaired.fastq.gz \
   LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 AVGQUAL:20 MINLEN:50
   wait
   
   rm -r $SRA_DIR/${i}_R1_unpaired.fastq.gz $SRA_DIR/${i}_R2_unpaired.fastq.gz
   rm -r $SRA_DIR/${i}_1.fastq $SRA_DIR/${i}_2.fastq
   mv $SRA_DIR/${i}_R1_paired.fastq.gz $SRA_DIR/${i}_1.fastq.gz
   mv $SRA_DIR/${i}_R2_paired.fastq.gz $SRA_DIR/${i}_2.fastq.gz
   
fi
wait




END4=$(date +%s)
DIFF4=$(( $END4 - $START4 ))

echo
echo "#@ TRIMMOMATIC SAMPLE $i TOOK $(printf '%dh:%dm:%ds\n' $(($DIFF4/3600)) $(($DIFF4%3600/60)) $(($DIFF4%60)))"
echo
echo "#@##################################################################"

echo
echo