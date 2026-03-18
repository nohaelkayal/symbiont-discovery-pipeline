#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Marine Symbiotic Consortia Discovery Pipeline
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nohaelkayal/symbiont-discovery-pipeline
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SYMBIONT_DISCOVERY       } from './workflows/symbiont_discovery'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def helpMessage() {
    log.info"""
    =========================================
    Marine Symbiotic Consortia Discovery Pipeline v1.0
    =========================================
    
    Usage:
      nextflow run main.nf --input samplesheet.csv --outdir results [options]
    
    Required Arguments:
      --input                Path to input samplesheet (CSV format)
      --outdir               Output directory for results
    
    Assembly Options:
      --assembler            Assembler to use [megahit, spades] (default: megahit)
      --min_contig_length    Minimum contig length (default: 1000)
    
    Annotation Options:
      --annotation_method    Annotation method [eggnog, diamond, both] (default: eggnog)
      --eggnog_db            Path to eggNOG database directory
      --diamond_db           Path to DIAMOND database file
    
    Pathway Options:
      --nif_genes            Nitrogen fixation genes to search (default: nifH,nifD,nifK,nifE,nifN,nifB)
      --carbon_pathways      Carbon pathways to extract (default: CBB,rTCA,3HP,4HB,WL)
    
    Machine Learning Options:
      --carbon_export_data   Path to CSV file with carbon export measurements
      --ml_model             ML model type (default: random_forest)
      --n_estimators         Number of trees in Random Forest (default: 100)
      --test_size            Test set proportion (default: 0.2)
    
    Resource Options:
      --max_cpus             Maximum CPUs per process (default: 16)
      --max_memory           Maximum memory per process (default: 128.GB)
      --max_time             Maximum time per process (default: 240.h)
    
    Profile Options:
      -profile               Configuration profile [docker, singularity, conda, test]
    
    Other Options:
      --skip_assembly        Skip assembly step (provide assembled contigs)
      --skip_annotation      Skip functional annotation
      --skip_ml              Skip machine learning prediction
      --help                 Display this help message
    """.stripIndent()
}



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    main:
    // Create input channel from samplesheet
    def reads_ch = channel.fromPath(params.input)
        | splitCsv(header: true, sep: ',')
        | map { row ->
            def meta = [
                id: row.sample,
                single_end: row.fastq_2 ? false : true
            ]
            def reads = row.fastq_2 ? 
                [file(row.fastq_1), file(row.fastq_2)] : 
                file(row.fastq_1)
            return [meta, reads]
        }
    
    // Create eggnog database channel
    def eggnog_db_ch = channel.fromPath(params.eggnog_db, type: 'dir', checkIfExists: true)
    
    // Run main workflow
    SYMBIONT_DISCOVERY(
        reads_ch,
        eggnog_db_ch
    )
    
    // Workflow completion handlers
    workflow.onComplete = {
        log.info "Pipeline completed at: ${workflow.complete}"
        log.info "Execution status: ${workflow.success ? 'SUCCESS' : 'FAILED'}"
        log.info "Duration: ${workflow.duration}"
    }
    
    workflow.onError = {
        log.error "Pipeline execution failed: ${workflow.errorMessage}"
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
