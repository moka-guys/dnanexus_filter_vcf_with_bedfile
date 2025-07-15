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
    
    # Load docker image
    docker load < /home/dnanexus/"${DOCKER_IMAGE_FILE}"
    echo "Using docker image ${DOCKER_IMAGE_NAME}"
    
    # Apply BED file filtering and variant quality filtering in one command
    docker run -v /home/dnanexus:/home/dnanexus "${DOCKER_IMAGE_NAME}" view "$vcf_file_path"##idx##"$vcf_index_path" \
        -R "$bedfile_path" \
        -e '(INFO/FS > 60) || (INFO/SOR > 3) || (INFO/QD < 2.0) || (INFO/MQ < 40) || (INFO/ReadPosRankSum < -8.0) || ((GT="het") && ((AD[0:1] / FORMAT/DP) < 0.25) && (INFO/ReadPosRankSum < -4.0))' \
        -O z -o ${out_dir}/"$vcf_file_prefix".bedfiltered.vcf.gz
    
    # dx-upload-all-outputs uploads contents of the subdirectories on the path $HOME/out/
    dx-upload-all-outputs
fi
}