process MULTIQC {
    label 'process_low'
    
    conda "bioconda::multiqc=1.23"
    container "biocontainers/multiqc:1.23--pyhdfd78af_0"
    
    input:
    path(multiqc_files)
    
    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data"       , emit: data
    path "versions.yml"       , emit: versions
    
    script:
    def args = task.ext.args ?: ''
    """
    multiqc \\
        ${args} \\
        .
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$(multiqc --version 2>&1 | sed 's/multiqc, version //')
    END_VERSIONS
    """
}
