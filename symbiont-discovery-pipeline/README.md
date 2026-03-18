# Marine Symbiotic Consortia Discovery Pipeline

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A525.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](https://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)

A comprehensive Nextflow pipeline for data-driven discovery of symbiotic planktonic consortia through integrated image analysis, metagenomics, and machine learning.

## Overview

This pipeline identifies nitrogen-fixing cyanobacteria-diatom symbioses and predicts their carbon export potential by integrating:

- 🔬 **Image Analysis**: Automated detection of consortia from microscopy
- 🧬 **Metagenomics**: Assembly, annotation, and functional profiling
- 🤖 **Machine Learning**: Carbon export prediction from functional signatures

## Research Background

Marine nitrogen-fixing cyanobacteria (e.g., *Richelia*, *Calothrix*) form symbioses with diatoms (*Hemiaulus*, *Rhizosolenia*) that act as "super-engines" for the ocean's biological pump. This pipeline bridges image-based identification with genomic functional potential to understand carbon export mechanisms.

## Quick Start

### Prerequisites

- Nextflow ≥ 25.04.0
- Docker or Singularity (recommended)
- OR Conda/Mamba

### Installation

```bash
# Install Nextflow
curl -s https://get.nextflow.io | bash

# Clone this repository
git clone https://github.com/nohaelkayal/symbiont-discovery-pipeline.git
cd symbiont-discovery-pipeline
```

### Test Run

```bash
nextflow run main.nf -profile test,docker
```

### Basic Usage

```bash
nextflow run main.nf \
  --input samplesheet.csv \
  --outdir results \
  -profile docker
```

## Pipeline Workflow

```
Input Data → QC → Assembly → Annotation → Pathway Extraction → ML Prediction → Reports
```

### 1. Image Analysis (Optional)
- Detect consortia from microscopy images
- Extract morphological features
- Classify symbiotic relationships

### 2. Metagenomic Assembly
- Quality control (FastQC, fastp)
- De novo assembly (MEGAHIT or MetaSPAdes)
- Quality assessment (QUAST)

### 3. Functional Annotation
- Gene prediction (Prodigal)
- Functional annotation (eggNOG-mapper)
- Pathway mapping

### 4. Pathway Extraction
- Nitrogen fixation genes (*nif* genes)
- Carbon fixation pathways (CBB, rTCA, etc.)
- Metabolic profiles

### 5. Machine Learning
- Feature engineering from gene profiles
- Random Forest model training
- Carbon export predictions

## Input Formats

### Samplesheet

```csv
sample,fastq_1,fastq_2
sample1,data/sample1_R1.fastq.gz,data/sample1_R2.fastq.gz
sample2,data/sample2_R1.fastq.gz,data/sample2_R2.fastq.gz
```

### Carbon Export Data (for ML)

```csv
sample_id,carbon_export
sample1,150.5
sample2,230.8
```

## Key Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--input` | - | Input samplesheet (CSV) |
| `--outdir` | results | Output directory |
| `--image_dir` | - | Microscopy images directory |
| `--assembler` | megahit | Assembler (megahit/spades) |
| `--annotation_method` | eggnog | Annotation method |
| `--carbon_export_data` | - | ML training data |

See full parameters: `nextflow run main.nf --help`

## Output Structure

```
results/
├── fastqc/              # QC reports
├── assembly/            # Assembled contigs
├── annotation/          # Functional annotations
├── pathways/            # Pathway profiles
├── ml_models/           # Trained models
├── predictions/         # Carbon export predictions
└── multiqc/            # Integrated report
```

## Scientific Background

### Key Genes

**Nitrogen Fixation:**
- nifH, nifD, nifK (nitrogenase complex)
- nifE, nifN, nifB (cofactor biosynthesis)

**Carbon Fixation:**
- CBB (Calvin-Benson-Bassham)
- rTCA (reverse TCA)
- 3HP, 4HB, WL pathways

### Machine Learning Approach

Random Forest regression predicts carbon export from:
- Normalized gene counts
- Pathway completeness scores
- Taxonomic composition

## Advanced Usage

### Custom Configuration

```bash
nextflow run main.nf -c custom.config
```

### Module-specific Runs

```bash
# Assembly only
nextflow run main.nf --skip_annotation --skip_ml

# With Wave containers
nextflow run main.nf -profile wave
```

## Troubleshooting

### Memory Issues
Increase in config:
```groovy
params.max_memory = '240.GB'
```

### Database Setup
Download eggNOG database:
```bash
download_eggnog_data.py -y --data_dir /path/to/eggnog
```

## Citation

If you use this pipeline, please cite:

```bibtex
@software{symbiont_pipeline,
  title = {Marine Symbiotic Consortia Discovery Pipeline},
  author = {Noha Elkayal},
  year = {2026},
  url = {https://github.com/nohaelkayal/symbiont-discovery-pipeline}
}
```

## Credits

Developed using:
- [Nextflow](https://www.nextflow.io/)
- [nf-core](https://nf-co.re/) tools
- Various bioinformatics tools

## License

MIT License

## Contact

For questions or issues:
- Open an [issue](https://github.com/nohaelkayal/symbiont-discovery-pipeline/issues)

---

**Project Goal:** Bridge image-based identification of planktonic consortia with genomic functional potential to understand carbon export mechanisms in marine ecosystems.
