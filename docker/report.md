## Report for differential expression analysis


This document discusses the steps that were performed in the analysis pipeline.  It also describes the format of the output files and some brief interpretation.  For more detailed questions about interpretation of results, consult the documentation of the various tools.


#### Version control:
To facilitate reproducible analyses, the analysis pipeline used to process the data is kept under git-based version control.  The repository for this workflow is at 

<{{git_repo}}>

and the commit version was {{git_commit}}.

This allows us to run the *exact* same pipeline at any later time, discarding any updates or changes in the process that may have been added.  


#### Methods:

Integer read-count tables derived from RNA-seq alignments were analyzed for differential expression using Bioconductor's DESeq2 software.  Briefly, this software performs normalization to control for sequencing depth and subsequently performs differential expression testing based on a negative-binomial model.  For further details on both of these steps, please consult the documentation and publications for DESeq2 [1] and its older iteration, DESeq [2].

The R `sessionInfo()` produced the following output:

```
{{session_info}}
```

#### Inputs:
The inputs to the workflow were given as:

Input count matrix: `{{input_count_matrix}}`
Sample annotations file: `{{annotations_file}}`

Parsed sample and condition table:

|Sample|Condition|
|---|---|
{% for item in annotation_objs %}
|{{item.name}} | {{item.condition}} |
{% endfor %}

#### Outputs:

**Differential expression results**
The differential expression results are summarized in a table in the file named `{{deseq2_output_filename}}`.  It is saved in a tab-delimited text format.  Each row contains information about a particular gene and the results of the statistical test performed.  Note that we have added a couple of columns to the standard DESeq2 output.

Although the particulars of DESeq2 are different, it can helpful to recall the Student's t-test when thinking about interpretation of the columns.  The parameter estimates and tests are different, but the ideas are very similar.  We are testing the null hypothesis that there is *no change* in the expression of a particular gene between the two conditions.

The columns and brief interpretations are:

- **Gene**: The gene symbol
- **overall_mean**: You may think of this as a "blended mean" of the expression across all the samples considered (for this gene)
- **Group1**: The average of the normalized expressions for samples from condition 1
- **Group2**: The average of the normalized expressions for samples from condition 2
- **log2FoldChange**: The logarithm (base 2) of the fold-change between the two sample groups.  Note that this is *not* simply based on the ratio of the average expressions in each group.  Details are in the DESEq2 publication.
- **lfcSE**:  You may consider this as you would the standard error, which ultimately feeds into the p-value.  Consistent (i.e. not highly variable) expression within each group of samples yields lower standard error and makes it easier to determine if there are true differences in the mean expression of each group
- **stat**: The value of the test statistic.
- **pvalue**:  The raw p-value of the statistical test.  Lower values indicate more evidence to reject the null hypothesis.
- **padj**: The "adjusted" p-value, which adjusts for the large number of statistical tests performed.  This addresses issues encountered in the "multiple-testing problem".  Corrections are based on the Benjamini-Hochberg procedure.

**Normalized expression table**
A table of normalized read-counts (suitable for using when plotting expression) is provided in `{{normalized_counts_filename}}`.  It is saved in a tab-delimited text file.  

**Figures**
Basic figures are contained in the zip archive named `{{output_figures_zip_name}}`.  We provide scatter plots of the top differentially expressed genes (if any) for quick reference.  Additionally, we provide a dynamic volcano plot which shows the log2 fold-change and adjusted p-value on a single plot.  This may be opened in any modern web browser.


#### References:

[1] Love MI, Huber W, Anders S (2014). "Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2." Genome Biology, 15, 550. doi: 10.1186/s13059-014-0550-8.

[2] Anders S, Huber W (2010). "Differential expression analysis for sequence count data." Genome Biology, 11, R106. doi: 10.1186/gb-2010-11-10-r106.