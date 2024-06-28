process ISOSEQ3_DEDUP {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/isoseq3:3.8.2--h9ee0642_0' :
        'biocontainers/isoseq3:3.8.2--h9ee0642_0' }"


    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.dedup.bam"), emit: dedup_bam     // _rmdup is hardcoded output from dedup
    //tuple val(meta), path("*.dedup.fasta"), emit: dedup_fasta
    //tuple val(meta), path("*.hist")     , emit: hist
    //tuple val(meta), path("*log")       , emit: log
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}"

    """
    isoseq3 \\
        dedup \\
        -j $task.cpus \\
        $bam \\
        ${prefix}.dedup.bam \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dedup: \$( echo \$(dedup --version 2>&1) | tail -n 1 | sed 's/.* v//')

    END_VERSIONS
    """
}