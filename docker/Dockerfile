From debian:stretch

RUN apt-get update && \
  apt-get install -y r-base libcurl4-openssl-dev libxml2-dev

# Install DESeq2 and dependencies:
RUN R -e "source('http://bioconductor.org/biocLite.R'); biocLite('RCurl'); biocLite('XML'); biocLite('DESeq2')"

# Install all software under /opt/software:
RUN mkdir -p /opt/software 
ADD deseq2.R /opt/software/

ENTRYPOINT ["/bin/bash"]