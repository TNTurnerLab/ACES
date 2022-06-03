FROM continuumio/miniconda3:4.5.4
RUN apt-get update && apt-get install -y --no-install-recommends wget unzip git  && rm -rf /var/lib/apt/lists* \
    && conda install python=3.6  \
    && conda install -c bioconda raxml=8.2.12 \
    && conda install -c bioconda muscle=3.8.1551 \
    && conda install -c conda-forge openjdk=11.0.1

RUN git clone https://github.com/TNTurnerLab/ACES.git
RUN mkdir -p /scripts
COPY find_thresh_and_key.py  /scripts
COPY generateReport_blastparse.py  /scripts
