Example using genomes from Kvon et al. 2016

**Step 1:** Clone repo
`git clone https://github.com/TNTurnerLab/ACES.git`

**Step 2:** Put all genomes in the `Github/ACES/ACES_Pipeline/Genome/` directory

We have aggregated the Kvon et al. 2016 genomes at our public Globus endpoint. It is searchable in Globus as:
"Turner Lab at WashU - assessment of small sequences in many genomes paper" 

or may be accessed using this link 

https://app.globus.org/file-manager?origin_id=97668938-bcc8-11eb-9d92-5f1f6f07872f&origin_path=%2F

For guidance on how to transfer files with Globus, please see this website https://docs.globus.org/how-to/get-started/

**Step 3:** Copy `ZRS_from_Kvon_et_al_2016.fa` from the `Github/ACES/Example` directory to the `Github/ACES/ACES_Pipeline/USERS_query_Files` directory

**Step 4:** Set up config.json as follows
```
{
    "genomesdb": "/ACES/ACES_Pipeline/genomesdb_input_document/Kvon_et_al_2016_species.txt",
    "query": "/ACES/ACES_Pipeline/USERS_query_Files/ZRS_from_Kvon_et_al_2016.fa",
    "dbs": "/ACES/ACES_Pipeline/Genomes",
    "threshold": "0.00001",
    "queryLengthPer": "0.3"
}
```

**Two choices for Step 5**

**Step 5a:** Run the analysis (example here is for a local machine). Note you must have docker working on your local machine and it must have at least 30 GB memory. This website is helpful if you’ve never used Docker: https://docs.docker.com/get-started/.

```
docker run -v "/##FULLPATH TO GITHUB CLONE##/ACES/ACES_Pipeline:/ACES/ACES_Pipeline" tnturnerlab/vgp_ens_pipeline:latest /opt/conda/bin/snakemake -s /ACES/ACES_Pipeline/Local_NAP_Version.smk -k -w 120 --rerun-incomplete --keep-going
```

**Step 5b:** Run the analysis on an LSF server
```
export LSF_DOCKER_VOLUMES="/##PATH_TO##/##_DIRECTORY_##/ACES/ACES_Pipeline/:/ACES/ACES_Pipeline/"
bgadd -L 2000  /username/###ANY NAME YOU WOULD LIKE TO CALL JOB###
bsub -q general -g /username/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=30GB]' -G compute-NAME -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' /opt/conda/bin/snakemake --cluster " bsub -q general -g  /username/VGP -oo %J.log.out -R 'span[hosts=1] rusage[mem=300GB]' -M 300GB -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' -n 4 " -j 100  -s LSF_NAP_Version.smk -k -w 120 --rerun-incomplete --keep-going -F
```

**Final Output**

The output file will be here `Outputfiles_For_Genomes_Kvon_et_al_2016_species.txt_and_Query_ZRS_from_Kvon_et_al_2016_TH_0.00001/`

