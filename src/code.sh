#!/bin/bash

main () {
  # The following line causes bash to exit at any point if there is any error
  # and to output each line as it is executed -- useful for debugging
  set -e -x -o pipefail

  # Fetch input files
  dx download "$input_vcf" -o input_vcf
  dx download "$bedfile" -o bedfile
  dx download "$input_vcf_index" -o input_vcf_index
  # Download docker image
  dx download project-ByfFPz00jy1fk6PjpZ95F27J:file-G55XqF00jy1QkJ174ZzZfzV5

  # Create output directory
  out_dir=out/filtered_vcf/output && mkdir -p ${out_dir}

  # Call bcftools view. Docker image is a DNAnexus asset in 001_ToolsReferenceData in compreseed tarball format.
  # The docker -v flag mounts a local directory to the docker environment in the format: -v local_dir:docker_dir
  docker load < bcftools_v1.13.tar.gz

  docker run -v /home/dnanexus:/home/dnanexus samtools/bcftools:1.13 view \
      /home/dnanexus/input_vcf##idx##/home/dnanexus/input_vcf_index -R /home/dnanexus/bedfile -O z \
      -o /home/dnanexus/${out_dir}/"$input_vcf_prefix".vcf.gz

  # Create output directory, move output file into directory, and upload outputs
  # dx-upload-all-outputs uploads contents of the subdirectories on the path $HOME/out/
  dx-upload-all-outputs
  }