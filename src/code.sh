#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
#set -e -x

# Fetch input files
dx download "$input_vcf" -o input_vcf
dx download "$bedfile" -o bedfile.bed

# Run vcftools
vcftools --bed  bedfile.bed --vcf input_vcf  --out $bedfile_prefix --recode --recode-INFO-all

# upload filtered vcf and capture the file id
file_id=$(dx upload $bedfile_prefix.recode.vcf --brief)

#assign to filtered vcf output in JSON
dx-jobutil-add-output "filtered_vcf"  "$file_id"


