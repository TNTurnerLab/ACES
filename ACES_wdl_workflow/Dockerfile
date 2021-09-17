FROM continuumio/miniconda3:latest
RUN apt-get update && apt-get install -y --no-install-recommends wget unzip git  && rm -rf /var/lib/apt/lists* \
    && conda install python=3.6  \
    && conda install -c bioconda raxml \
    && conda install -c bioconda muscle

RUN git clone https://github.com/TNTurnerLab/ACES.git
RUN mkdir -p /scripts
COPY find_thresh_and_key.py  /scripts
COPY generateReport_blastparse.py  /scripts
