# dnanexus_filter_vcf_with_bedfile v1.2.1

[samtools/bcftools:1.13](https://github.com/samtools/bcftools/releases/tag/1.13)

## Updates

### v1.2 - 15/07/2025 (George)

Added enhanced filtering criteria per GATK Best Practice guidance on [Hard-filtering germline short variants](https://gatk.broadinstitute.org/hc/en-us/articles/360035890471-Hard-filtering-germline-short-variants). The following rules are applied to reduce artefactual calls:

SNPs:

- FisherStrand (FS) > 60
- StrandOddsRatio (SOR) > 3 && GT == "het"
- QualByDepth (QD) < 2.0
- RMSMappingQuality (MQ) < 40
- ReadPosRankSumTest (ReadPosRankSum) < -8.0

Indels:

- FisherStrand (FS) > 200
- StrandOddsRatio (SOR) > 10
- QualByDepth (QD) < 2.0
- ReadPosRankSumTest (ReadPosRankSum) < -20.0
- GT == "het" && AD[0:1] / FORMAT/DP < 25% && ReadPosRankSumTest (ReadPosRankSum) < -4.0

<details>
<summary><em>Validation and benchmarking results using NA12878 data</em></summary>

SNPs:

| Sample | Recall | Precision | F-Score | TP | FN | FP |
| --- | --- | --- | --- | --- | --- | --- |
| NGS688 (Novaseq) | 100.00% | 99.82% | 0.999 | 1640 | 0 | 3 |
| FILTERED NGS688 (Novaseq) | 100.00% | **100.00%** | **1.000** | 1640 | **0** | **0** |
| --- | --- | --- | --- | --- | --- | --- |
| NGS700 (AVITI) | 99.94% | 98.97% | 0.995 | 1639 | 1 | 17 |
| FILTERED NGS700 (AVITI) | 99.94% | **100.00%** | **1.000** | 1639 | 1 | **0** |
| --- | --- | --- | --- | --- | --- | --- |
| NGS702 (AVITI) | 99.94% | 98.85% | 0.994 | 1639 | 1 | 19 |
| FILTERED NGS702 (AVITI) | 99.94% | **99.94%** | **0.999** | 1639 | 1 | **1** |
| --- | --- | --- | --- | --- | --- | --- |
| NGS704 (AVITI) | 100.00% | 98.74% | 0.994 | 1640 | 0 | 21 |
| FILTERED NGS704 (AVITI) | 99.94% | **99.94%** | **0.999** | 1639 | 1* | **1** |

Indels:

| Sample | Recall | Precision | F-Score | TP | FN | FP |
| --- | --- | --- | --- | --- | --- | --- |
| NGS688 (Novaseq) | 91.74% | 66.86% | 0.773 | 111 | 10 | 57 |
| FILTERED NGS688 (Novaseq) | 91.74% | **87.79%** | **0.897** | 111 | 10 | **16** |
| --- | --- | --- | --- | --- | --- | --- |
| NGS700 (AVITI) | 93.39% | 66.29% | 0.775 | 113 | 8 | 59 |
| FILTERED NGS700 (AVITI) | 93.39% | **89.23%** | **0.913** | 113 | 8 | **14** |
| --- | --- | --- | --- | --- | --- | --- |
| NGS702 (AVITI) | 91.74% | 65.52% | 0.764 | 111 | 10 | 60 |
| FILTERED NGS702 (AVITI) | 91.74% | **85.71%** | **0.886** | 111 | 10 | **19** |
| --- | --- | --- | --- | --- | --- | --- |
| NGS704 (AVITI) | 91.74% | 66.86% | 0.773 | 111 | 10 | 57 |
| FILTERED NGS704 (AVITI) | 91.74% | **86.26%** | **0.889** | 111 | 10 | **18** |

</details>


<details>
<summary><em>*FN is caused by a limitation of the --ref-overlap functionality in vcfeval and it's compatibility with bcftools formatting</em></summary>



- NGS704 variant:

```2	152474001	rs4303716	A	G,AG	8002.73	.	AC=1,1;AF=0.5,0.5;AN=2;BaseQRankSum=0.882;ClippingRankSum=0.000;DB;DP=413;ExcessHet=3.0103;FS=2.611;MLEAC=1,1;MLEAF=0.5,0.5;MQ=60.00;MQRankSum=0.000;QD=24.03;ReadPosRankSum=1.560;SOR=0.591	GT:AD:DP:GQ:PL	1/2:31,239,63:333:99:8040,350,334,4160,0,4988```

- After filtration:

```2	152474001	rs4303716	A	G,AG	8002.73	.	AC=1,1;AF=0.5,0.5;AN=2;BaseQRankSum=0.882;ClippingRankSum=0;DB;DP=413;ExcessHet=3.0103;FS=2.611;MLEAC=1,1;MLEAF=0.5,0.5;MQ=60;MQRankSum=0;QD=24.03;ReadPosRankSum=1.56;SOR=0.591	GT:AD:DP:GQ:PL	1/2:31,239,63:333:99:8040,350,334,4160,0,4988```

The key difference is that bcftools has removed redundant decimal points from applicable values (i.e., MQ in the above example)

- Benchmarking call for unfiltered variant:

```2	152474001	.	A	G	.	.	BS=152473987;Regions=CONF,TS_contained	GT:BD:BK:QQ:BI:BVT:BLT	1|1:TP:gm:8002.73:ti:SNP:homalt	0/1:TP:gm:8002.73:ti:SNP:het```

- Benchmarking call for filtered variant:

```2	152474001	.	A	G	.	.	BS=152474001;Regions=CONF,TS_contained	GT:BD:BK:QQ:BI:BVT:BLT	1|1:FN:am:.:ti:SNP:homalt	0/1:FP:am:8002.73:ti:SNP:het```

Note that the BS (Benchmark Set) position used to validate the TP call (BS=152473987) is not concordant with the input VCF position (152474001). With the --ref-overlap parameter set, VCFeval has the leniency to permit overlapping variants to be matched if they agree on what the DNA sequence should be in the overlapping region. However, the formatting difference in the input VCF is preventing the tool from recognising that these are actually the same variant call.

**TLDR; The "FN" in the input VCF is still present and being called identically to the original unfiltered VCF being benchmarked against.**
</details>

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
| bed file | *.bed | Optional. The bedfile you wish to use to filter the vcf file with. If not provided the app will exit without filtering, producing no output |

## What does this app output?

* Zipped VCF file (*.vcf.gz) - contains variants from vcf that fall within the regions given in the bed file.

## How does this app work?

1. Test if a BED file was provided - if not provided does not continue.
2. The app downloads the input files
3. Loads the bcftools docker image from the .tar.gz file
4. Runs the bcftools command. -R supplies a file containing regions to restrict the input file on. Returns all
positions overlapping the regions specified in the bed file. Therefore indels that cover both inside and outside a
region are returned.
`bcftools view input_vcf##idx##input_vcf_index -R bedfile.bed -O z -o $input_vcf_prefix.vcf.gz`
5. The bcftools output .vcf.gz file is uploaded to DNAnexus.

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
