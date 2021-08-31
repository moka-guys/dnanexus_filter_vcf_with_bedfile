# dnanexus_filter_vcf_with_bedfile

Uses bcftools view to filter down variants in a VCF using a bed file.

### Inputs and Outputs
The required input files are as follows: 

| File | Pattern | Info |
|---------|---------|---------|
| vcf | *.vcf.gz | A vcf file containing variants from vcf that fall within the regions given in the bed file |
| vcf index file | *.vcf.gz.tbi | The index file of the vcf file to be filtered |
| bed file | *.bed | The bedfile you wish to use to filter the vcf file with |

The app outputs a zipped vcf file (*.vcf.gz) containing variants from vcf that fall within the regions given in the bed file.