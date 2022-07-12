#!/bin/bash

mkdir trimmed_reads

for SAMPLE in $(cat samples.txt) ; do

fastp \
    -i "raw_data/${SAMPLE}_1.fastq.gz" \
    -I "raw_data/${SAMPLE}_2.fastq.gz" \
    -o "trimmed_reads/${SAMPLE}_1.fastq.gz" \
    -O "trimmed_reads/${SAMPLE}_2.fastq.gz" \
    --html "trimmed_reads_/${SAMPLE}_fastp.html"
done

#make directories
mkdir -p results/sam results/bam  results/vcf


#index ref. genome

bwa index raw_data/ref_genome/ecoli_rel606.fasta

#Align reads to reference genome


for SAMPLE in $(cat samples.txt) ; do

bwa mem \
 	raw_data/ref_genome/ecoli_rel606.fasta \
  	trimmed_reads/${SAMPLE}_1.fastq.gz \
   	trimmed_reads/${SAMPLE}_2.fastq.gz \
   	> results/sam/${SAMPLE}.aligned.sam

done

#convert sam to bam

for SAMPLE in $(cat samples.txt) ; do

samtools view \
        -S -b results/sam/${SAMPLE}.aligned.sam \
        > results/bam/${SAMPLE}.aligned.bam
done


#Sort BAM file by coordinates

for SAMPLE in $(cat samples.txt) ; do

samtools sort \
        -o results/bam/${SAMPLE}.aligned.sorted.bam \
        results/bam/${SAMPLE}.aligned.bam

done


#Variant Calling

for SAMPLE in $(cat samples.txt) ; do

freebayes \
        -f raw_data/ref_genome/ecoli_rel606.fasta \
        results/bam/${SAMPLE}.aligned.bam \
        > results/vcf/${SAMPLE}.vcf

done
