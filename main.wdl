workflow Deseq2Dge {

    File sample_annotations
    File raw_count_matrix
    String contrast_name
    String base_group
    String experimental_group

    call run_differential_expression as dge {
        input:
            sample_annotations = sample_annotations,
            raw_count_matrix = raw_count_matrix,
            contrast_name = contrast_name, 
            base_group = base_group,
            experimental_group = experimental_group
    }

    output {
        File dge_table = dge.dge_table
        File normalized_counts = dge.nc_table
    }

    meta {
        workflow_title : "DESeq2 differential expression analysis"
        workflow_short_description : "For finding differentially expressed genes from RNA-seq."
        workflow_long_description : "Use this workflow for determining potentially differentially expressed genes from a RNA-Seq experiment.  "
    }


}


task run_differential_expression {
    File sample_annotations
    File raw_count_matrix
    String contrast_name
    String base_group
    String experimental_group

    Int disk_size = 10
    String output_deseq2 = "deseq2_output.tsv"
    String normalized_counts = "normalized_read_counts.tsv"

    command <<<
        Rscript /opt/software/deseq2.R \
            ${raw_count_matrix} \
            ${sample_annotations} \
            ${base_group} \
            ${experimental_group} \
            ${output_deseq2} \
            ${normalized_counts}
    >>>

    output {
        File dge_table = "${output_deseq2}"
        File nc_table = "${normalized_counts}"
    }  

    runtime {
        docker: "docker.io/blawney/deseq2:v0.0.1"
        cpu: 2
        memory: "6 G"
        disks: "local-disk " + disk_size + " HDD"
        preemptible: 0
    }
}



