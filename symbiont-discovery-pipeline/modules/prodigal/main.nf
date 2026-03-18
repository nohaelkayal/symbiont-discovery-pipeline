process PRODIGAL {
    tag "${meta.id}"
    label 'process_medium'
    
    conda "bioconda::prodigal=2.6.3"
    container "biocontainers/prodigal:2.6.3--h516909a_2"
    
    input:
    tuple val(meta), path(contigs)
    
    output:
    tuple val(meta), path("${meta.id}.faa")    , emit: proteins
    tuple val(meta), path("${meta.id}.fna")    , emit: genes
    tuple val(meta), path("${meta.id}.gff")    , emit: gff
    path "versions.yml"                        , emit: versions
    
    script:
    def args = task.ext.args ?: '-p meta'
    """
    prodigal \\
        -i ${contigs} \\
        -a ${meta.id}.faa \\
        -d ${meta.id}.fna \\
        -f gff \\
        -o ${meta.id}.gff \\
        ${args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prodigal: \$(prodigal -v 2>&1 | sed -n 's/Prodigal V\\(.*\\):.*/\\1/p')
    END_VERSIONS
    """
}
