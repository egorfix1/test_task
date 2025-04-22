# Bioinfo Tools Docker Image

## Included Software
- HTSlib 1.21
- SAMtools 1.21
- BCFtools 1.21
- libdeflate 1.23
- VCFtools 0.1.16

### For Python task
- Python 3
- pysam
- pandas
- convert_alleles.py &mdash; Custom script for reference-based allele conversion

## Build
```bash
docker build -t bioinfo-tools:latest .
```

## Run
```bash
docker run -it --rm -v /mnt/data/ref/GRCh38.d1.vd1_mainChr/sepChrs/:/ref/GRCh38.d1.vd1_mainChr/sepChrs/:ro -v "$(pwd)":/mnt/data/task bioinfo-tools:latest bash
```
# Repository structure
```bash
├── Dockerfile                    # Docker image with samtools, htslib, pysam etc.
├── convert_alleles.py            # python script
├── FP_SNPs.txt                   # original file from GRAF
├── FP_SNPs_10k_GB38_twoAllelsFormat.tsv  # pre-prepared file
├── FP_SNPs_10k_GB38_REF_ALT.tsv          # python script output
├── script_logs.log               # log file
└── FP_SNPs_README.md             # instruction for python script
```
