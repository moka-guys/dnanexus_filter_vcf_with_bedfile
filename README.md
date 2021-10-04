# dnanexus_filter_vcf_with_bedfile
[samtools/bcftools:1.13](https://github.com/samtools/bcftools/releases/tag/1.13)

## What does this app do?
Uses bcftools view to filter down variants in a VCF using a bed file. Uses dockerised bcftools v1.13.

## What are typical use cases for this app?
Separates the variant calling and bed restriction steps (previously bed restriction was applied by GATK
in the pipelines). This means the entire pipeline will not need to be re-run if a different BED file 
is required.

## What data are required for this app to run?
The required input files are as follows: 

| File | Pattern | Info |
|---------|---------|---------|
| vcf | *.vcf.gz | A vcf file containing variants from vcf that fall within the regions given in the bed file |
| vcf index file | *.vcf.gz.tbi | The index file of the vcf file to be filtered |
| bed file | *.bed | The bedfile you wish to use to filter the vcf file with |

## What does this app output?
* Zipped VCF file (*.vcf.gz) - contains variants from vcf that fall within the regions given in the bed file.

## How does this app work?
1. The app downloads the input files 
2. Loads the bcftools docker image from the .tar.gz file
3. Runs the bcftools command. -R supplies a file containing regions to restrict the input file on. Returns all 
positions overlapping the regions specified in the bed file. Therefore indels that cover both inside and outside a 
region are returned.
    ```
    bcftools view input_vcf##idx##input_vcf_index -R bedfile.bed -O z -o $input_vcf_prefix.vcf.gz
    ```
3. The bcftools output .vcf.gz file is uploaded to DNAnexus. 

## What are the limitations of this app?
* The project which the app is run on must be shared with the user mokaguys

## How was the .tar.gz file created?
The bcftools docker image was created using the Dockerfile, tagged, and saved as a bcftools.tar.gz file, saved in 
the 001_ToolsReferenceData project. The app loads the docker image from the .tar.gz file each time it is run. 
```
sudo docker build - < Dockerfile 
sudo docker tag <image_id> samtools/bcftools:1.13
sudo docker save samtools/bcftools:1.13 | gzip > bcftools_v1.13.tar.gz
```

## This app was made by Viapath Genome Informatics