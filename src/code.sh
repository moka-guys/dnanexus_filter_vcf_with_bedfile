#!/bin/bash

main () {
  # The following line causes bash to exit at any point if there is any error
  # and to output each line as it is executed -- useful for debugging
  set -e -x -o pipefail
  # BED file is optional. If it is not provided skip this step.
  if [[ -z $bedfile_path ]]
  then
    echo "No BEDFILE provided. Not filtering"
    exit 0
  # if bedfile is present...
  else
    # Fetch input files
    dx-download-all-inputs --parallel
    # Download docker image, get tag and print
    DOCKER_FILE_ID=project-ByfFPz00jy1fk6PjpZ95F27J:file-G55XqF00jy1QkJ174ZzZfzV5
    dx download ${DOCKER_FILE_ID}

    DOCKER_IMAGE_FILE=$(dx describe ${DOCKER_FILE_ID} --name)
    DOCKER_IMAGE_NAME=$(tar xfO "${DOCKER_IMAGE_FILE}" manifest.json | sed -E 's/.*"RepoTags":\["?([^"]*)"?.*/\1/')

    # Create output directory
    out_dir=/home/dnanexus/out/filtered_vcf/output && mkdir -p ${out_dir}

    # Call bcftools view (Bcftools v1.13). Docker image is a DNAnexus asset in 001_ToolsReferenceData in compressed
    # tarball format.
    # The docker -v flag mounts a local directory to the docker environment in the format: -v local_dir:docker_dir.
    # -R = supplies file containing regions to restrict the input file.  a file containing regions to restrict the input
            #file on. Returns all positions overlapping the regions specified in the bed file. Therefore indels that
            # cover both inside and outside a region are returned.
    # -O z = output type compressed vcf file
    docker load < /home/dnanexus/"${DOCKER_IMAGE_FILE}"
    echo "Using docker image ${DOCKER_IMAGE_NAME}"
    docker run -v /home/dnanexus:/home/dnanexus "${DOCKER_IMAGE_NAME}" view "$vcf_file_path"##idx##"$vcf_index_path" \
        -R "$bedfile_path" -O z -o ${out_dir}/"$vcf_file_prefix".bedfiltered.vcf.gz

    # Create output directory, move output file into directory, and upload outputs
    # dx-upload-all-outputs uploads contents of the subdirectories on the path $HOME/out/
    dx-upload-all-outputs
  fi
  }