process EGGNOG_MAPPER {
    tag "${meta.id}"
    label 'process_high'
    
    conda "bioconda::eggnog-mapper=2.1.12"
    container "biocontainers/eggnog-mapper:2.1.12--pyhdfd78af_0"
    
    input:
    tuple val(meta), path(proteins)
    path eggnog_db
    
    output:
    tuple val(meta), path("${meta.id}.emapper.annotations")    , emit: annotations
    tuple val(meta), path("${meta.id}.emapper.seed_orthologs") , emit: orthologs
    path "versions.yml"                                        , emit: versions
    
    script:
    def args = task.ext.args ?: ''
    """
    emapper.py \\
        -i ${proteins} \\
        --data_dir ${eggnog_db} \\
        --cpu ${task.cpus} \\
        -o ${meta.id} \\
        --output_dir . \\
        ${args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        eggnog-mapper: \$(echo \$(emapper.py --version 2>&1) | sed 's/emapper-//')
    END_VERSIONS
    """
}
