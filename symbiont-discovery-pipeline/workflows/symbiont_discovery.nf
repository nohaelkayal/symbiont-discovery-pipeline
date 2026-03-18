/*
 * Symbiont Discovery Pipeline
 * Main workflow for metagenomics assembly, gene prediction, and functional annotation
 */

include { MEGAHIT        } from '../modules/megahit/main'
include { PRODIGAL       } from '../modules/prodigal/main'
include { EGGNOG_MAPPER  } from '../modules/eggnog_mapper/main'
include { MULTIQC        } from '../modules/multiqc/main'

workflow SYMBIONT_DISCOVERY {
    
    take:
    reads_ch      // tuple val(meta), path(reads)
    eggnog_db_ch  // path to eggnog database
    
    main:
    
    // Assembly with MEGAHIT
    MEGAHIT(reads_ch)
    
    // Gene prediction with Prodigal
    PRODIGAL(MEGAHIT.out.contigs)
    
    // Functional annotation with eggNOG-mapper
    EGGNOG_MAPPER(
        PRODIGAL.out.proteins,
        eggnog_db_ch
    )
    
    // Collect versions
    ch_versions = channel.empty()
    ch_versions = ch_versions.mix(MEGAHIT.out.versions)
    ch_versions = ch_versions.mix(PRODIGAL.out.versions)
    ch_versions = ch_versions.mix(EGGNOG_MAPPER.out.versions)
    
    // Collect logs for MultiQC
    ch_multiqc_files = channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(MEGAHIT.out.log.collect { _meta, log -> log })
    
    // Generate MultiQC report
    MULTIQC(ch_multiqc_files.collect())
    
    emit:
    contigs     = MEGAHIT.out.contigs
    proteins    = PRODIGAL.out.proteins
    genes       = PRODIGAL.out.genes
    gff         = PRODIGAL.out.gff
    annotations = EGGNOG_MAPPER.out.annotations
    orthologs   = EGGNOG_MAPPER.out.orthologs
    multiqc     = MULTIQC.out.report
    versions    = ch_versions
}
