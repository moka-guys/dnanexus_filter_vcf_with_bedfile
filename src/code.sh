#!/bin/bash

main () {
  # The following line causes bash to exit at any point if there is any error
  # and to output each line as it is executed -- useful for debugging
  set -e -x -o pipefail

  # Fetch input files
  dx download "$input_vcf" -o input_vcf
  dx download "$bedfile" -o bedfile.bed
  dx download "$input_vcf_index" -o input_vcf_index

  # Download and load docker image and call bcftools view. Image is a DNAnexus asset in 001_ToolsReferenceData in
  # compreseed tarball format.
  # The docker -v flag mounts a local directory to the docker environment in the format: -v local_dir:docker_dir
  docker load < project-ByfFPz00jy1fk6PjpZ95F27J:file-G55X9q00jy1ZvJJy4ZGqk2K3

  docker run -v /home/dnanexus:/home/dnanexus samtools/bcftools:1.13 view input_vcf##idx##input_vcf_index \
      -R bedfile.bed -O z -o $input_vcf_prefix.vcf.gz

  # upload filtered vcf and capture the file id
  file_id=$(dx upload $input_vcf_prefix.vcf.gz --brief)

  #assign to filtered vcf output in JSON
  dx-jobutil-add-output "filtered_vcf"  "$file_id"
  }