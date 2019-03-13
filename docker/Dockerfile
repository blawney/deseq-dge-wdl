From debian:stretch

RUN apt-get update && \
  apt-get install -y \
    build-essential \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libncurses-dev \
    libbz2-dev \
    liblzma-dev \
    libxml2-dev \
    python3-dev \
    python3-pip \
    r-base

# Install DESeq2 and dependencies:
RUN R -e "source('http://bioconductor.org/biocLite.R'); biocLite('RCurl'); biocLite('XML'); biocLite('DESeq2')"

# Install all software under /opt/software:
RUN mkdir -p /opt/software 

ADD deseq2.R /opt/software/
ADD make_plots.py /opt/software/
ADD requirements.txt /opt/software/

# Install python dependencies:
RUN pip3 install -r /opt/software/requirements.txt

ENTRYPOINT ["/bin/bash"]
