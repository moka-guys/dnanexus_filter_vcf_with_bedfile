#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

# Fetch input files
dx download "$input_vcf" -o input_vcf
dx download "$bedfile" -o bedfile.bed

# Run vcftools
bcftools view input_vcf -R bedfile.bed -O z -o $bedfile_prefix.vcf

# upload filtered vcf and capture the file id
file_id=$(dx upload $input_vcf_prefix.vcf --brief)

#assign to filtered vcf output in JSON
dx-jobutil-add-output "filtered_vcf"  "$file_id"