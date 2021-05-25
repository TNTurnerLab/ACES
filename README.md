**<span style="text-decoration:underline;"><h1>VGP Conservation Analysis Pipeline:</h1></span>**

**Maintainer:** Elvisa Mehinovic\
Laboratory of Dr. Tychele N. Turner, Ph.D.\
Washington University in St. Louis

**<span style="text-decoration:underline;"><a name="HOWRUN"><h1>HOW TO RUN</h1></a></span>**

PLEASE MAKE SURE YOU HAVE READ SECTION [User Required Script Files for Pipeline Execution](#USER_REQUIRED) :

<h4>Note on USER query Files:</h4>

This is an empty folder generated for user to store all their input query files that will be run through the workflow. This is an optional folder however, if user decides to call file outside of this folder, they must include fill path to that file in config.json: 'query'. Query file may not be a repeat sequence nor a file larger than 1 MB. These files will not generate accurate information.


--------------------------------------------------------------------------------------------------------------------------------
**BEFORE EXECUTION:**

[Reference Outline](#O) Provided Image to Better Understand Pipeline File Locations.

1. Start by cloning VGP Conservation Analysis GitHub:

All required script files will be available on GitHub to be pulled on a desktop by using:

	wget https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git

Or can be pulled using `git clone` as follows:

	git clone https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git


2. Pull down ready to run docker image with the code provided below:

   * This docker image is pre-built and needs no modifications to it. If the user wishes to build their own image manually, follow steps in [Dockerfile](#Dock) with the provided Dockerfile in this pipeline.

    	 docker pull tnturnerlab/vgp_ens_pipeline:latest

--------------------------------------------------------------------------------------------------------------------------------

<a name = "HTR"> 3. </a>   Put all VGP species ‘* -unmasked.fa’ files, and '* .dna.toplevel.fa' species files from Ensembl pub/release-103 in the provided Genomes directory and unzip them.

   * See file [DOWNLOADING VGP AND ENSEMBL SPECIES FILES](#DOWNF) for command line codes that will help achieve this.


<a name = "HTT"> 4. </a>   Use or generate empty files corresponding to files named in [SUB-FILES GUIDE](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Sub-Files-Guide) and put your query input files inside the pre-generated folder USER query Files. This folder is found in the folder VGP SnakeFile Pipeline.

   * Files can be modified or changed based on user's requirements


<a name = "HTF"> 5. </a>   Configure all file pathways in file [config](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Config-File-Details).json. This file can be in VGP SnakeFile Pipeline.

* Reference FILES GUIDE: [config](https://github.com/TNTurnerLab/VGP-Conservation-Analysis/wiki/Config-File-Details).json

	* genomesdb:
		* currently defaulted to VGP_AND_ENSEMBL_TOGETHER.txt, unless user wants to change it, this file will un all
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



6. Open file **_config.json_**, and fill in value for "[threshold](#tH)"

  * Within this file, enter a single value with decimal point; can be in scientific notation but not required  
	* Value should correspond to a threshold requirement species blast outputs must meet before they can generate a parse file.
	* The threshold is a value of the expected number of chance matches in a random model. For more information about threshold
		values visit this link: http://pathblast.org/docs/e_value.html



7. Open file **_config.json_**, and fill in value for "[queryLengthPer](#ql)"

	* Fill in decimal value for percent of query length sequences needed in order to be included into the results.
	* This requirement helps eliminate small sequences that may have been generated as hits by BLASTn.
	* The percent of query length will be applied to all subject sequence lengths, and those sequences that met the minimum requirement or
	  better will be allowed to move further into the pipeline.



8. Open file corresponding to that of "[genomesdb](#genomesdb)" in **_config.json_**, This file is in the file genomes input document.

  * Default file is set to run all VGP and Ensembl genomes.
	* Create new file, or modify and close this file when content.



9. Users must upload or have handy their {query} file for Blast.

  * Open  **_config.json _** to set which file is the users query file: "[query](#query)"
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
		
	* View [Output Files Generated: Output](#Outfile) to see which files are generated and more information on each. Output files will be generated inside the VGP_SnakeFile_Pipeline folder. Two folders will be created within the folder. One folder will hold all BLAST outputs from the pipeline execution, and the other holding output files. The file with the name BLAST_Outputfiles_ARCHIVE_For_Genomes_ *
can be deleted or kept. Outputfiles_For_Genomes_ * will hold the name of the folder holding all outputs. The names for these folders will vary based on name of genomes input document used, user query file name, and threshold value used.



17. Once satisfied, user can move or delete all log files with basic mv or rm commands.

 <a name="o"> Workflow Outline </a>

![OUTLINE IMAGE|300x300,20%](https://docs.google.com/drawings/d/e/2PACX-1vRHNT2Uedh4fvA8En-y7ZyXsJTx-u0wDm1CawurKoQl1maBhxsBM0ICK6DdHVWXK33mDKLAJGPcc1bj/pub?w=960&h=720)

**<span style="text-decoration:underline;"><h2>TABLE OF CONTENTS:</h2></span>**
* [HOW TO RUN](#HOWRUN)

* [PIPELINE BACKGROUND](#PB)

* [User Required Script Files for Pipeline Execution](#USER_REQUIRED)

	* [SCRIPT FILES](#Script_req)
	* [SUB-FILES GIVEN](#Given)
	* [USER MUST RETRIEVE or PROVIDE](#USER)


* [RETRIEVING VGP AND ENSEMBL FILES](#RETRIEVING-VGP-AND-ENSEMBL-FILES)

	* [wgetfile_VGP.sh](#VGP)
	* [wgetfile_ensembl.sh](#ENS)
	* [DOWNLOADING VGP AND ENSEMBL SPECIES FILES](#DOWNF)

* [SUB FILES GUIDE: genomes input document](#SUB_FILES_GUIDE)

* [Output Files Generated: Output](#Outfile)
* [More Information](#more)
* [Citations](#cite)


--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="USER_REQUIRED"><h3>User Required Script Files for Pipeline Execution:</h3></a></span>**

All required script files will be available on GitHub to be pulled on a desktop by using:

	wget https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git

Or can be pulled using `git clone` as follows:

	git clone https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git

_<span style="text-decoration:underline;"> <a name="Script_req"><h4>SCRIPT FILES: </h4></a></span>_

These files are given inside of the pipeline in the folder VGP SnakeFile Pipeline:

1. [Local_NAP_Version.smk and LSF_NAP_Version.smk](#SNAKE)
2. [config.json](#config_file)

The provided Dockerfile is given for users to have, but is not required for pipeline execution.
Pipeline will run through an already existing Docker image: (tnturnerlab/vgp_ens_pipeline:latest)

1. [Dockerfile](#Dock)

<span style="text-decoration:underline;"><a name="Given"><h4>SUBFILES_GIVEN </h4></a></span>

   These files can be found inside the folder genomes input document:
   View [SUB FILES GUIDE: genomes input document](#SUB_FILES_GUIDE) for more information on each file.

	1. VGP_ONLY_FILE.TXT
	2. ENSEMBLE_AND_VGP_TOGETHER_FILE.TXT
	3. ENSEMBLE_ONLY_FILE.TXT

   These files can be found in the Genomes folder and should be executed in Genomes folder:
   View [RETRIEVING VGP AND ENSEMBL FILES](#RETRIEVING-VGP-AND-ENSEMBL-FILES) for more information on each file.

	1. wgetfile_ensembl.sh
	2. wgetfile_VGP.sh

   USERS_query_Files is a blank folder that is recommended for user to use to store potential input files:
   *** Files should not contain repeat sequences nor file that is over 1MB large ***
   Open and read PLACE USER QUERY INPUT FILES HERE.txt for more information.

	1. PLACE USER QUERY INPUT FILES HERE.txt

Files listed are maintainer generated files, user can input any customization of each file if the custom file follows the same format as the given files. File 1 contains only and all VGP files. File 2 will contain a mixture of all files found in Ensembl pub/release-103 as well as all files in the VGP database. File 3 will only contain the files pub/release-103. To run user file, make sure to change file pathway for genomesdbs in file [config.json](#config_file).


<span style="text-decoration:underline;"><a name="USER"><h4>USER MUST RETRIEVE or PROVIDE:</h4></a></span>

1. {subject}: All VGP ‘* -unmasked.fa’ species files or Ensembl ‘* -.dna.toplevel.fa’ species files.
	- These files can be downloaded through provided script.

2. {query}: Any reference genome file that is a FASTA forma. PLEASE PUT USER QUERY FILE IN FILE USERS_query_Files


Back to [HOW TO RUN](#HOWRUN)

--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------


**<span style="text-decoration:underline;"><a name="FILES_GUIDE"><h3>FILES GUIDE:</h3></a></span>**

Short guide that explains files in the repository. Users can find examples, commands, and explanations on each file. This also includes a mini summary of internal components of files.

--------------------------------------------------------------------------------------------------------------------------------


Back to [HOW TO RUN](#HOWRUN)

--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="SNAKE"><h4>Local_NAP_Version.smk and LSF_NAP_Version.smk</h4></a></span>**

The user has two options for which snake they can run, Local_NAP_Version.smk is for running on a local device while LSF_NAP_Version.smk is used for running on a LSF server. The files execute the same and can be found in the VGP SnakeFiles folder.



Back to [HOW TO RUN #4](#HTF)

--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="RETRIEVING-VGP-AND-ENSEMBL-FILES"><h3>RETRIEVING VGP AND ENSEMBL FILES</h3></a></span>**
The files named below will be used to download all files needed for this pipeline. Both files must be put in the same directory.

![Warning](images/1200px-Warning.svg.png)
						
***WARNING:***

When conducting the retrieval of files, please ensure that the user has enough storage space. The minimum storage needed for downloading all current VGP files is estimated to be 338.58 GB. The total storage needed for downloading all current Ensembl file is estimated at 669.18 GB. Please insure there is enough storage for all files the minimum recommended free storage should be approximately 1.2TB. This insures all downloaded and created files have enough storage space on users device. There are 522 files in total between the two databases at the time of upload. This is subjected to change. Please ensure that genomes input files reflect on current, new versions of each genome file. Older versions of files may skew data or cause inconsistencies.

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="VGP"><h3>wgetfile_VGP.sh</h3></a></span>**

This file contains the shell file that was used to pull all * -unmasked.fa.gz files from the VGP rapid release archive. This shell file also contains the command used to extract the * -unmasked.fa.gz files and move them into a working directory. Lastly, allowing for the files to then be unzipped through the gunzip * -unmasked.fa.gz. Modification to these commands is a must and should occur before running. The command used could be written into a snake, written directly onto the command line , or by executing the script files found in the /Genomes folder.


***After execution, there should be 213 species files in the given directory.***

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="ENS"><h3>wgetfile_ensembl.sh</h3></a></span>**

This script is used to pull all '* .dna.toplevel.fa' from Ensembl's pub/release-103 archive. The file will contain the command to extract all '* .dna.toplevel.fa' for every species. Shell command is found in the Genomes folder.


***After execution, there should be 310 species files in the given directory.***

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="DOWNF"><h3>DOWNLOADING VGP AND ENSEMBL SPECIES FILES: </h3></a></span>**

					**** FILES UNZIPPED ARE ABOUT 1.2 TB GBS ***

Explanation of wgetfile_ * .sh. Could run manually or execute files with shell commands listed below. 
Please see FILES GIVEN: wgetfile_ * .sh for more information.



Open /VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/Genomes folder and execute the following commands:


1. Before running either file please make sure file is executable this can be done with:

		chmod +x *.sh

2. To run locally to get Ensembl files:

		./wgetfile_ensembl.sh

3. Tor run on an LSF example:

		bsub -q general  -R 'span[hosts=1] rusage[mem=30GB]' -G compute-tychele -a 'docker(emehinovic72/home:bwp2)' ./wgetfile_ensembl.sh

4. To run locally to get VGP files:

		./wgetfile_VGP.sh

5. To run on an LSF example:

		bsub -q general  -R 'span[hosts=1] rusage[mem=30GB]' -G compute-tychele -a 'docker(emehinovic72/home:bwp2)' ./wgetfile_VGP.sh

