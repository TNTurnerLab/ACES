**<span style="text-decoration:underline;"><h1>VGP Conservation Analysis Pipeline:</h1></span>**

**Maintainer:** Elvisa Mehinovic\
Laboratory of Dr. Tychele N. Turner, Ph.D.\
Washington University in St. Louis

**<span style="text-decoration:underline;"><a name="HOWRUN"><h1>HOW TO RUN</h1></a></span>**

<h4>Note on USER query Files:</h4>

This is an empty folder generated for user to store all their input query files that will be run through the workflow. This is an optional folder however, if user decides to call file outside of this folder, they must include fill path to that file in config.json: 'query'. Query file may not be a repeat sequence nor a file larger than 1 MB. These files will not generate accurate information.

<h4>Prior to running the pipeline ensure that you have the reference genome data as described on our wiki</h4>

[wiki link](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Retrieving-Reference-Genome-Data)

--------------------------------------------------------------------------------------------------------------------------------
**Steps:**

[Reference Outline](#O) Provided Image to Better Understand Pipeline File Locations.

1. Start by cloning VGP Conservation Analysis GitHub:

All required script files will be available on GitHub to be pulled on a desktop by using:

	wget https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git

Or can be pulled using `git clone` as follows:

	git clone https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git


2. Pull down ready to run docker image with the code provided below:

   * This docker image is pre-built and needs no modifications to it. If the user wishes to build their own image manually, follow steps in [Dockerfile](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Building-the-Dockerfile) with the provided Dockerfile in this pipeline.

    	 docker pull tnturnerlab/vgp_ens_pipeline:latest

--------------------------------------------------------------------------------------------------------------------------------

<a name = "HTR"> 3. </a>   Put all VGP species ‘* -unmasked.fa’ files, and '* .dna.toplevel.fa' species files from Ensembl pub/release-103 in the provided Genomes directory and unzip them.

   * See file [DOWNLOADING VGP AND ENSEMBL SPECIES FILES](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Retrieving-Reference-Genome-Data) for command line codes that will help achieve this.


<a name = "HTT"> 4. </a>   Use or generate empty files corresponding to files named in [SUB-FILES GUIDE](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Sub-Files-Guide) and put your query input files inside the pre-generated folder USER query Files. This folder is found in the folder VGP SnakeFile Pipeline.

   * Files can be modified or changed based on user's requirements


<a name = "HTF"> 5. </a>   Configure all file pathways in file [config](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Config-File-Details).json. This file can be in VGP SnakeFile Pipeline.

* Reference FILES GUIDE: [config](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Config-File-Details).json

	* genomesdb:
		* currently defaulted to VGP_AND_ENSEMBL_TOGETHER.txt, unless user wants to change it, this file will run all
      		  VGP and Ensembl genomes against users query sequence.

	* query:
		* Pathway to this file does not have to change if user puts their input file inside the pre-generated folder,
		  USER query Files. When editing this portion of the config, please only input the filename after the last '/'.
		  User does not need to edit path unless they did not place their input file in provided folder.
	  	* Input file may not be a repeat sequence nor a file larger than 1MB. These files will not generate accurate information.
	  	
	* dbs:
		* Do not edit this path, this path is the pathway to /Genomes folder.
      		
	* threshold:
		 * E-value threshold requirement. Default is set to 0.0001. User may change if desired. It is recommended value is in decimal format.

	* queryLengthPer
		* Minimum % of query length requirement. Default is set to 0.5, or 50%. User may keep default or replace with decimal value



6. Open file **_config.json_**, and fill in value for "threshold"

  * Within this file, enter a single value with decimal point; can be in scientific notation but not required  
	* Value should correspond to a threshold requirement species blast outputs must meet before they can generate a parse file.
	* The threshold is a value of the expected number of chance matches in a random model. For more information about threshold
		values visit this link: http://pathblast.org/docs/e_value.html



7. Open file **_config.json_**, and fill in value for "queryLengthPer"

	* Fill in decimal value for percent of query length sequences needed in order to be included into the results.
	* This requirement helps eliminate small sequences that may have been generated as hits by BLASTn.
	* The percent of query length will be applied to all subject sequence lengths, and those sequences that met the minimum requirement or
	  better will be allowed to move further into the pipeline.



8. Open file corresponding to that of "[genomesdb](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Config-File-Details)" in **_config.json_**, This file is in the file genomes input document.

  * Default file is set to run all VGP and Ensembl genomes.
	* Create new file, or modify and close this file when content.



9. Users must upload or have handy their {query} file for Blast.

  * Open  **_config.json _** to set which file is the users query file: "[query](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Config-File-Details)"
	* Your query file should be put in file USERS_query_Files, if not please modify complete pathway to input file in config.json file.
	* Query file cannot be full genomes nor repeat elements.



10. Locate [Local_NAP_Version.smk and LSF_NAP_Version.smk](#SNAKE) in VGP SnakeFile Pipeline folder, decide whether user will be using file LSF_NAP_Version.smk for running on a LSF server, or Local_NAP_Version.smk for running on a local machine.



_<span style="text-decoration:underline;"><h3>To Run on a Local Machine: Local_NAP_Version.smk</h3></span>_


11. Run Dockerfile command - CHECK:

		docker run tnturnerlab/vgp_ens_pipeline:latest (CHECKS IF PULL IS SUCCESSFUL AND FILE IS READY TO RUN)



12. Run the following script:

		docker run -v "/##FULLPATH TO GITHUB CLONE##/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline:/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline" tnturnerlab/vgp_ens_pipeline:latest /opt/conda/bin/snakemake -s /VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/Local_NAP_Version.smk -k -w 120 --rerun-incomplete --keep-going




_<span style="text-decoration:underline;"><h3>To Run On LSF: LSF_NAP_Version.smk </h3></span>_


13. Tell Docker where data and code are:

	* Execute on LSF code:

     		export LSF_DOCKER_VOLUMES="/##PATH_TO##/##_DIRECTORY_##/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/:/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/"

	Example:

		export LSF_DOCKER_VOLUMES="/path/to/data:/path/name /home/directory:/home 	

       * Run Docker interactively to see if successful:

           		bsub -Is -R 'rusage[mem=50GB]' -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' /bin/bash



14. Create a group job:

    	bgadd -L 2000  /username/###ANY NAME YOU WOULD LIKE TO CALL JOB###



15. Run following script:

    * MUST MODIFY SCRIPT TO RUN:

        	bsub -q general -g /username/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=30GB]' -G compute-NAME -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' /opt/conda/bin/snakemake --cluster " bsub -q general -g  /username/VGP -oo %J.log.out -R 'span[hosts=1] rusage[mem=300GB]' -M 300GB -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' -n 4 " -j 100  -s LSF_NAP_Version.smk -k -w 120 --rerun-incomplete --keep-going -F
    
    * Example:

        	bsub -q general -g /elvisa/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=30GB]' -G compute-tychele -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' /opt/conda/bin/snakemake --cluster " bsub -q general -g /elvisa/VGP  -oo %J.log.out -R 'span[hosts=1] rusage[mem=300GB]' -M 300GB -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' -n 4 " -j 100  -s LSF_NAP_Version.smk -k -w 120 --rerun-incomplete --keep-going -F



16. Output files will be generated in the Output folder provided in this pipeline.
		
	* View [Output Files Generated: Output](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Output-Files-Description) to see which files are generated and more information on each. Output files will be generated inside the VGP_SnakeFile_Pipeline folder. Two folders will be created within the folder. One folder will hold all BLAST outputs from the pipeline execution, and the other holding output files. The file with the name BLAST_Outputfiles_ARCHIVE_For_Genomes_ *
can be deleted or kept. Outputfiles_For_Genomes_ * will hold the name of the folder holding all outputs. The names for these folders will vary based on name of genomes input document used, user query file name, and threshold value used.



17. Once satisfied, user can move or delete all log files with basic mv or rm commands.

 <a name="o"> Workflow Outline </a>

![OUTLINE IMAGE|300x300,20%](https://docs.google.com/drawings/d/e/2PACX-1vRHNT2Uedh4fvA8En-y7ZyXsJTx-u0wDm1CawurKoQl1maBhxsBM0ICK6DdHVWXK33mDKLAJGPcc1bj/pub?w=960&h=720)


--------------------------------------------------------------------------------------------------------------------------------
