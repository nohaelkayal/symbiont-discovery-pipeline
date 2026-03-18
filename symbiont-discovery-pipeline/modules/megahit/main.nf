process MEGAHIT {
    tag "${meta.id}"
    label 'process_high'
    
    conda "bioconda::megahit=1.2.9"
    container "biocontainers/megahit:1.2.9--h8b12597_0"
    
    input:
    tuple val(meta), path(reads)
    
    output:
    tuple val(meta), path("${meta.id}/final.contigs.fa"), emit: contigs
    tuple val(meta), path("${meta.id}/log")             , emit: log
    path "versions.yml"                                 , emit: versions
    
    script:
    def args = task.ext.args ?: ''
    def input_reads = meta.single_end ? "-r ${reads}" : "-1 ${reads[0]} -2 ${reads[1]}"
    """
    megahit \\
        ${input_reads} \\
        -t ${task.cpus} \\
        --min-contig-len ${params.min_contig_length} \\
        -o ${meta.id} \\
        ${args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        megahit: \$(echo \$(megahit --version 2>&1) | sed 's/MEGAHIT v//')
    END_VERSIONS
    """
}
