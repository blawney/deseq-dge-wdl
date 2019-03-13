workflow Deseq2Dge {

    File sample_annotations
    File raw_count_matrix
    String contrast_name
    String base_group
    String experimental_group
    String git_repo_url
    String git_commit_hash

    String output_deseq2 = "deseq2_output.tsv"
    String normalized_counts = "normalized_read_counts.tsv"
    String output_figures_zip = "figures.zip"

    call run_differential_expression as dge {
        input:
            sample_annotations = sample_annotations,
            raw_count_matrix = raw_count_matrix,
            contrast_name = contrast_name, 
            base_group = base_group,
            experimental_group = experimental_group,
            output_deseq2 = output_deseq2,
            normalized_counts = normalized_counts,
            output_figures_zip = output_figures_zip
    }

    call generate_report as report {
        input:
            git_repo_url = git_repo_url,
            git_commit_hash = git_commit_hash,
            input_matrix = raw_count_matrix,
            annotations = sample_annotations,
            deseq_output_filename = output_deseq2,
            normalized_counts_filename = normalized_counts,
            figures_zip_filename = output_figures_zip
    }

    output {
        File dge_table = dge.dge_table
        File normalized_counts = dge.nc_table
        File figures_zip = dge.figures_zip
        File report = report.report
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
    String output_deseq2
    String normalized_counts
    String output_figures_zip

    Int disk_size = 10
    String output_figures_dir = "figures"

    command <<<
        Rscript /opt/software/deseq2.R \
            ${raw_count_matrix} \
            ${sample_annotations} \
            ${base_group} \
            ${experimental_group} \
            ${output_deseq2} \
            ${normalized_counts}
        mkdir ${output_figures_dir}
        python3 /opt/software/make_plots.py \
            -i ${output_deseq2} \
            -c ${normalized_counts} \
            -s ${sample_annotations} \
            -o ${output_figures_dir}
        zip -r ${output_figures_zip} ${output_figures_dir}
    >>>

    output {
        File dge_table = "${output_deseq2}"
        File nc_table = "${normalized_counts}"
        File figures_zip = "${output_figures_zip}"
    }  

    runtime {
        docker: "docker.io/blawney/deseq2:v0.0.1"
        cpu: 2
        memory: "6 G"
        disks: "local-disk " + disk_size + " HDD"
        preemptible: 0
    }
}


task generate_report {
    
    String git_repo_url
    String git_commit_hash
    String input_matrix
    File annotations
    String deseq_output_filename
    String normalized_counts_filename
    String figures_zip_filename

    Int disk_size = 10

    command <<<
        python3 /opt/report/generate_report.py \
          -i ${input_matrix} \
          -a ${annotations} \
          -d ${deseq_output_filename} \
          -n ${normalized_counts_filename} \
          -f ${figures_zip_filename} \
          -r ${git_repo_url} \
          -c ${git_commit_hash} \
          -t /opt/report/report.md \
          -o completed_report.md

        pandoc -H /opt/report/report.css -s completed_report.md -o analysis_report.html
    >>>

    output {
        File report = "analysis_report.html"
    }

    runtime {
        docker: "docker.io/blawney/deseq2:v0.0.1"
        cpu: 2
        memory: "2 G"
        disks: "local-disk " + disk_size + " HDD"
        preemptible: 0
    }
}



