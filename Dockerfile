FROM continuumio/miniconda3


RUN conda install -c bioconda blast \
    && conda install python=3.6.5 \
    && conda install -c bioconda gfapy \
    && conda install -c bioconda snakemake \
    && conda install -c bioconda raxml \
    && conda install -c bioconda muscle 

RUN apt-get update \
  	&& apt-get install -y wget libgtk2.0-0 libgconf-2-4 libcanberra-gtk*



LABEL maintainer "elvisa@wustl.edu"

CMD ["/bin/bash"]
