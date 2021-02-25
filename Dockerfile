FROM continuumio/miniconda3

RUN conda install -c bioconda blast \
    && conda install python=3.6.5 \
    && conda install -c bioconda snakemake \
    && conda install -c bioconda muscle


LABEL maintainer "elvisa@wustl.edu"

USER dockeruser
CMD ["/bin/bash"]
