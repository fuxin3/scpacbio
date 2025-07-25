process PBINDEX {
    tag "$meta.id"
    label 'process_high'

    // Note: the versions here need to match the versions used in the mulled container below and minimap2/index
    conda "${moduleDir}/environment.yml"
    
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pbbam:2.1.0--h3f0f298_2' :
        'biocontainers/pbbam:2.1.0--h3f0f298_2' }"

    input:
    tuple val(meta), path(bam)
    //tuple val(meta2), path(reference)
    //val bam_format
    //val bam_index_extension
    //val cigar_paf_format
    //val cigar_bam

    output:
    tuple val(meta), path("*.bam")                       , emit: index_bam
    tuple val(meta), path("*.bam.pbi")                   , emit: index
    path "versions.yml"                                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args  = task.ext.args ?: ''
    //def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    //def bam_index = bam_index_extension ? "${prefix}.bam##idx##${prefix}.bam.${bam_index_extension} --write-index" : "${prefix}.bam"
    //def bam_output = bam_format ? "-a | samtools sort -@ ${task.cpus-1} -o ${bam_index} ${args2}" : "-o ${prefix}.paf"
    //def cigar_paf = cigar_paf_format && !bam_format ? "-c" : ''
   // def set_cigar_bam = cigar_bam && bam_format ? "-L" : ''
    """
    cat ${bam} > ${prefix}.index.bam
    pbindex ${prefix}.index.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pbindex: \$(pbindex --version 2>&1)
    END_VERSIONS
    """
}