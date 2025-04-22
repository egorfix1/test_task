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
docker run -it --rm -v "$(pwd)":/mnt/data bioinfo-tools:latest
```
