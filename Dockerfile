FROM continuumio/miniconda3


RUN conda install -c bioconda blast \
    && conda install python=3.6.5 \
    && conda install -c bioconda gfapy \
    && conda install -c bioconda snakemake \
    && conda install -c bioconda raxml \
    && conda install -c bioconda muscle \
    && conda install -c bioconda/label/cf201901 goalign 

RUN apt-get update \
  	&& apt-get install -y wget libgtk2.0-0 libgconf-2-4 libcanberra-gtk*
    

WORKDIR /data
RUN apt-get update \
    && git clone https://github.com/fawaz-dabbaghieh/msa_to_gfa.git


LABEL maintainer "elvisa@wustl.edu"

USER dockeruser
CMD ["/bin/bash"]
