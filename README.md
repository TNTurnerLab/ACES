**<span style="text-decoration:underline;"><h1>VGP Conservation Analysis Pipeline:</h1></span>**

**Maintainer:** Elvisa Mehinovic\
Laboratory of Dr. Tychele N. Turner, Ph.D.\
Washington University in St. Louis

**<span style="text-decoration:underline;"><a name="HOWRUN"><h1>HOW TO RUN</h1></a></span>**
<h3>Minimum Compute Requirements: </h3>

* 30GB RAM
* 1TB FREE storage space minimum
* recommended dual or quad core, 64-bit, x86 CPU, equivalent or better

PLEASE MAKE SURE YOU HAVE READ SECTION [User Required Script Files for Pipeline Execution](#USER_REQUIRED) :

--------------------------------------------------------------------------------------------------------------------------------
Approximate Runtime Seen Running All 522 Genome Inputs At Default values:

	Minimum: 3.5 hours
	Maximum: 10+ hours
	Average: 6 Hours

Runtime depends on many factors such as size of users query file, RAxML file input size, users ram amount, number of genomes being ran against, etc.

--------------------------------------------------------------------------------------------------------------------------------
Approximate Download and Unzip All 522 VGP and Ensembl Genomes if Ran Simultaneously: (Average based on 40Mbps Download speed)

	Minimum: 15 hours
	Maximum: 24+ hours
	Average: 24 Hours

Download time will vary between users.

--------------------------------------------------------------------------------------------------------------------------------

<h4>USERS query Files:</h4>

This is an empty folder generated for user to store all their input query files that will be run through the workflow. This is an optional folder however, if user decides to call file outside of this folder, they must include fill path to that file in config.json: 'query'. Query file may not be a repeat sequence nor a file larger than 1 MB. These files will not generate accurate information.


--------------------------------------------------------------------------------------------------------------------------------
**BEFORE EXECUTION:**

[Reference Outline](#O) Provided Image to Better Understand Pipeline File Locations.

Start by cloning VGP Conservation Analysis GitHub:

All required script files will be available on GitHub to be pulled on a desktop by using:

	wget https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git

Or can be pulled using `git clone` as follows:

	git clone https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git


1. Pull down ready to run docker image with the code provided below:

   * This docker image is pre-built and needs no modifications to it, if user wishes to build their own image manually,
      follow steps in [Dockerfile](#Dock) with the provided Dockerfile in this pipeline.

    	 docker pull tnturnerlab/vgp_ens_pipeline:latest

--------------------------------------------------------------------------------------------------------------------------------

<a name = "HTR"> 2. </a>   Have all VGP species ‘* -unmasked.fa’ files, and '* .dna.toplevel.fa' species files from Ensembl pub/release-103 in the provided Genomes directory and unzip them.

   * See file [DOWNLOADING VGP AND ENSEMBL SPECIES FILES](#DOWNF) for command line codes that will help achieve this.



<a name = "HTT"> 3. </a>   Use or generate empty files corresponding to files named in [SUB-FILES GUIDE](#SUB_FILES_GUIDE) and put your query input files inside the pre-generated folder USER query Files. This folder is found in the folder VGP SnakeFile Pipeline.

   * Files can be modified or changed based on user's requirements



<a name = "HTF"> 4. </a>   Configure all file pathways in file [config](#config_file).json. This file can be in VGP SnakeFile Pipeline.

* Reference FILES GUIDE: [config](#config_file).json

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



5. Open file **_config.json_**, and fill in value for "[threshold](#tH)"

  * Within this file, enter a single value with decimal point; can be in scientific notation but not required  
	* Value should correspond to a threshold requirement species blast outputs must meet before they can generate a parse file.
	* The threshold is a value of the expected number of chance matches in a random model. For more information about threshold
		values visit this link: http://pathblast.org/docs/e_value.html



6. Open file **_config.json_**, and fill in value for "[queryLengthPer](#ql)"

	* Fill in decimal value for percent of query length sequences needed in order to be included into the results.
	* This requirement helps eliminate small sequences that may have been generated as hits by BLASTn.
	* The percent of query length will be applied to all subject sequence lengths, and those sequences that met the minimum requirement or
	  better will be allowed to move further into the pipeline.



7. Open file corresponding to that of "[genomesdb](#genomesdb)" in **_config.json_**, This file is in the file genomes input document.

  * Default file is set to run all VGP and Ensembl genomes.
	* Create new file, or modify and close this file when content.



8. Users must upload or have handy their {query} file for Blast.

  * Open  **_config.json _** to set which file is the users query file: "[query](#query)"
	* Your query file should be put in file USERS_query_Files, if not please modify complete pathway to input file in config.json file.
	* Query file cannot be full genomes nor repeat elements.



9. Locate [Local_NAP_Version.smk and LSF_NAP_Version.smk](#SNAKE) in VGP SnakeFile Pipeline folder, decide whether user will be using file LSF_NAP_Version.smk for running on a LSF server, or Local_NAP_Version.smk for running on a local machine.



_<span style="text-decoration:underline;"><h3>To Run on a Local Machine: Local_NAP_Version.smk</h3></span>_


10. Run Dockerfile command - CHECK:

		docker run tnturnerlab/vgp_ens_pipeline:latest (CHECKS IF PULL IS SUCCESSFUL AND FILE IS READY TO RUN)



11. Run the following script:

		docker run -v "/##FULLPATH TO GITHUB CLONE##/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline:/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline" tnturnerlab/vgp_ens_pipeline:latest /opt/conda/bin/snakemake -s /VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/Local_NAP_Version.smk -k -w 120 --rerun-incomplete --keep-going




_<span style="text-decoration:underline;"><h3>To Run On LSF: LSF_NAP_Version.smk </h3></span>_


12. Tell Docker where data and code are:

	* Execute on LSF code:

     		export LSF_DOCKER_VOLUMES="/##PATH_TO##/##_DIRECTORY_##/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/:/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/"

	Example:

		export LSF_DOCKER_VOLUMES="/path/to/data:/path/name /home/directory:/home 	

       * Run Docker interactively to see if successful:

           		bsub -Is -R 'rusage[mem=50GB]' -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' /bin/bash



13. Create a group job:

    	bgadd -L 2000  /username/###ANY NAME YOU WOULD LIKE TO CALL JOB###



14. Run following script:

    * MUST MODIFY SCRIPT TO RUN:

        	bsub -q general -g /username/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=30GB]' -G compute-NAME -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' /opt/conda/bin/snakemake --cluster " bsub -q general -g  /username/VGP -oo %J.log.out -R 'span[hosts=1] rusage[mem=300GB]' -M 300GB -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' -n 4 " -j 100  -s LSF_NAP_Version.smk -k -w 120 --rerun-incomplete --keep-going -F
    
    * Example:

        	bsub -q general -g /elvisa/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=30GB]' -G compute-tychele -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' /opt/conda/bin/snakemake --cluster " bsub -q general -g /elvisa/VGP  -oo %J.log.out -R 'span[hosts=1] rusage[mem=300GB]' -M 300GB -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' -n 4 " -j 100  -s LSF_NAP_Version.smk -k -w 120 --rerun-incomplete --keep-going -F



15. Output files will be generated in the Output folder provided in this pipeline.
		
	* View [Output Files Generated: Output](#Outfile) to see which files are generated and more information on each. Output files will be generated inside the VGP_SnakeFile_Pipeline folder. Two folders will be created within the folder. One folder will hold all BLAST outputs from the pipeline execution, and the other holding output files. The file with the name BLAST_Outputfiles_ARCHIVE_For_Genomes_ *
can be deleted or kept. Outputfiles_For_Genomes_ * will hold the name of the folder holding all outputs. The names for these folders will vary based on name of genomes input document used, user query file name, and threshold value used.



16. Once satisfied, user can move or delete all log files with basic mv or rm commands.

 <a name="o"> Workflow Outline </a>

![OUTLINE IMAGE|300x300,20%](https://docs.google.com/drawings/d/e/2PACX-1vRHNT2Uedh4fvA8En-y7ZyXsJTx-u0wDm1CawurKoQl1maBhxsBM0ICK6DdHVWXK33mDKLAJGPcc1bj/pub?w=960&h=720)

**<span style="text-decoration:underline;"><h2>TABLE OF CONTENTS:</h2></span>**
* [HOW TO RUN](#HOWRUN)

* [PIPELINE BACKGROUND](#PB)

* [User Required Script Files for Pipeline Execution](#USER_REQUIRED)

	* [SCRIPT FILES](#Script_req)
	* [SUB-FILES GIVEN](#Given)
	* [USER MUST RETRIEVE or PROVIDE](#USER)

* [FILES GUIDE](#FILES_GUIDE)
	* [Dockerfile](#Dock)
   	* [Local_NAP_Version.smk and LSF_NAP_Version.smk](#SNAKE)

		*  [Rule Blast](#RB)
		*  [Rule findThresh](#RFT)
		*  [Rule Parse](#RP)
		*  [Rule generateReport](#RGR)
		*  [Rule KeyDoc](#RKD)
		*  [Rule muscle](#RM)
		*  [Rule muscle2](#RM2)
		*  [Rule MSA2GFA](#RMG)
		*  [Rule RAXML](#RR)
		*  [Rule clean](#RC)

	*  [config.json](#config_file)
		*  [genomesdb](#genomesdb)
		*  [query](#query)
		*  [dbs](#dbs)
		*  [threshold](#tH)
		*	 ["queryLengthPer"](#ql)


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
<a name="PB"><h3>PIPELINE BACKGROUND</h3></a>

This pipeline was developed to query small sequences in a large number of genomes. For example, one could look at conservation of an enhancer sequence in many genomes. In particular, we developed this pipeline to utilize genome data from the newly generated in genomes in the [Vertebrate Genomes Project (VGP)!](https://vertebrategenomesproject.org/) as well as from the standard genomes in the [Ensembl database!](http://ensembl.org). The input file is a FASTA file and the outputs are: Blast results of the sequence to each reference genome, MUSCLE alignment of all sequences, PHYLIP reformatting, conversion to a GFA file, and finally a RAXML phylogenetic tree output. One particular feature users can modify is the threshold value from BLAST. This allows the user to only MUSCLE align if the files are at, or below the threshold requirement (i.e., high-quality matches). In addition to the threshold requirement, there is also a percent query length requirement. This requirement will take in a decimal value corresponding to a percent of sequenced covered in the alignment and filters out smaller miscellaneous sequences that may have a good e-value score. To assess homology between sequences, it is advised that sequences be over 30% identical across their entire lengths. By setting a minimum length requirement, this will ensure that larger sequences, with corresponding e-values will be the only sequences processed in the pipeline. This gives a cleaner and more concise result.

The pipeline is defaulted to run 522 genomic files (all available genome data as of today) together at a threshold value of 0.0001, and percent query length at 0.5 (50%). Users can edit those files found in the sub-file folder. The query file cannot be larger than 1 Megabase pair (Mbp) in size and cannot be a repeat element as the pipeline is not optimized to work on those sequences.

When executing the pipeline, there are a total of 7 files will be generated if ran successfully. These files include a `_Parsed_Final.fa` file which will include all sequences that have met the user’s threshold requirement.`_Files_Generated_Report.fa` will generate a report on how many files contained hits, no hits, or had not met the threshold requirement. This file will also tell the user exactly how many hits, no hits, and total number of sequences read. After receiving the `_Parsed_Final.fa`, the file will be converted into a `_Multi_Seq_Align.aln`. This file takes all the parsed hit sequences and aligns them for computational use. The `_MSA2GFA.fa` file will be a file that converts the `_Multi_Seq_Align.aln` into a GFA file that can be put into a Graphical Fragment Assembly viewer for analysis. `_Phy_Align.phy` is like the `_MSA2GFA.fa`, except it is a multiple sequence file in PHYLIP format. This file format is required for running the RAXML analysis. When viewing the PHYLIP file or any RAXML file, please refer to the `_NameKey.txt`. This document will hold unique names to identify files and sequences in the named files. Changing this file will not change the names of files or identity names within files. RAXML will also generate a single file consisting of the optimum tree created based on 100 bootstraps. This file will be called `_RAxML_Output_Phylogenetic_Tree.phy`. RAXML will be running PROTGAMMAWAG model of heterogeneity on a protein dataset while using the empirical base frequencies and the LG substitution model. This can be changed with in the pipeline under the user’s discretion. For more information regarding RAXML please refer to the manual linked in the "More Information" section. To view a phylogenic tree created from RAXML, the user will need to use an external phylogenetic viewer.

The purpose of this pipeline is to provide a reproducible, and faster way to obtain an in depth analysis of paritcualr sequences of interest in genomes from the Vertebrate Genome Project and Ensembl by using a user inputted query sequence to run a BLASTn on both databases. Outputted sequences that have met a user set threshold value will be combined to create multiple files. These files include those that can be inputted in an external Graphical Fragment Assembly viewer and Phylogenetic tree viewer for further visual analysis of the data.


--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="USER_REQUIRED"><h3>User Required Script Files for Pipeline Execution:</h3></a></span>**

All required script files will be available on GitHub to be pulled on a desktop by using:

	wget https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git

Or can be pulled on LSF with command:

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
**<span style="text-decoration:underline;"><a name="Dock"><h4>Dockerfile</h4></a></span>**

** Disclaimer Make sure to build the Dockerfile locally on machine before attempting to on LSF server **

For those not familiar with docker reference this link: [https://docs.docker.com/get-started/](https://docs.docker.com/get-started/)

--------------------------------------------------------------------------------------------------------------------------------
<h5> There is a Dockerfile provided for user to modify or view, however by executing the command in [HOW TO RUN](#HOWRUN),
	docker image is pre-built and ready to run. Only follow these steps if user wishes to manually build the docker image.</h5>


1. Find folder VGP-Conservation-Analysis. This is the folder user will use to build docker image.

2.   Docker files must be built locally before use; therefore, you must build a Docker image by the command :

		   docker build  ###PATH TO DIRECTORY/VGP-Conservation-Analysis
	
3. Once the Docker has built an image for the Dockerfile, it is beneficial to tag the image for later use:
 
    * To view IMAGE ID for tagging run command :
	
			docker images
	
    *   To tag Dockerfile run command:
    
    		docker tag ###IMAGE ID NUMBER##  ##(your_docker_username##/##the_name_of_useres_repository>:&lt;what_you_would_like_to_call_the_image)##
     	
   	  	Ex: docker tag myuser01/home:##myimagename##
 
 4. Push docker image to your docker hub:

 		docker push ##(docker_username>/repo_name:image_name)##
   
   *   ***If executed on a LSF server one must execute export LSF. ***
  
   			export LSF_DOCKER_VOLUMES="/path/to/data:/path/name /home/directory:/home"


Back to [HOW TO RUN](#HOWRUN)

--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="SNAKE"><h4>Local_NAP_Version.smk and LSF_NAP_Version.smk</h4></a></span>**

The user has two options for which snake they can run, Local_NAP_Version.smk is for running on a local device while LSF_NAP_Version.smk is used for running on a LSF server. The files execute the same and can be found in the VGP SnakeFiles folder.

--------------------------------------------------------------------------------------------------------------------------------
The snakefile consists of a few rules:

*   <a name= "RB"><h5>Rule BLAST:</h5></a>
    *   Takes a text input from the folder genomes input document as the subject and the given FASTA file as query and BLASTn the files to create a BLAST output file
*   <a name= "RP"><h5>Rule parse:</h5></a>
    *   Each BLASTn output file will undergo a tagging system which will help identify weather the sequence has met the e-value threshold requirement and query length minimum or not. This starts by sorting through each sequence and finding its sequence length. Then from the query sequence percent set by the user, the program with either tag the sequence 'Y' for yes, or 'N' for no. Those tagged 'N' will automatically be excluded from the final file containing every accepted sequence. At this point, the sequences will also be tagged with their respective e-values. Once completed, the file will be created and moved to final stage of filtering in the rule findThresh.
*   <a name= "RFT"><h5>Rule findThresh:</h5></a>
    *   Using the users applied threshold for the maximum e-value allowed, each sequence will be filtered according to their 'Y'/'N' tag and e-value. The rule looks for sequences tagged 'Y' and checks their e-value score against the users threshold value. If both requirements are met, the sequence is written to the ' *_ Parsed_Final.fa' file. Those sequences with a 'N' tag are automatically excluded out of the final parsed file.   
*   <a name= "RGR"><h5>Rule generateReport:</h5></a>
    *   The rule generates a report for the user to allow a visual of what sequences and files have met the e-value threshold and query length sequence minimum requirement. The file will list all 'Rejected' and 'Accepted' sequences ID's and files, along with a summary of results including Threshold Value Used, Total # of Files, Total # Of Sequences Found, Total # Of Rejected Sequences Found, and Total # Of Accepted Sequences Found. Rejected files will be tagged with any of the three keys: N/L, N/H, N/A. These keys correspond to Sequence Length Did Not Meet % Of Query Length Requirement, E-Value Did Not Meet Threshold Requirements, and No Hits Were Found In This Genome respectively. All genomes from the Ensembl database will also be tagged with the key '@-'.
*   <a name= "RKD"><h5>Rule KeyDoc:</h5></a>  
    *   KeyDoc will generate a file that holds the unique filenames used throughout the pipeline. The RAXML function requires a unique naming schema with no more than ten characters being used. The logic of the naming patterns follows one of two naming techniques. Those files produced by the VGP will have the first letter of the species, followed by the last five values of their id number, file number, and sequence place within the file. File who has been pulled from the Ensembl database will appear to have a '@-' inside the produced document. These files have a naming pattern like those of the VGP files. The first letter indicates the letter the species name starts with. After the first letter, the last 7 unique consecutive characters of the species name, followed by the sequence place within the file. If files have more than 9 sequences as hits, then end value will be noted by a letter of the alphabet starting with 'a' = 10. The file generated is "* NameKey.txt".		 
*   <a name= "RM"><h5> Rule muscle:</h5></a>
    *   MUSCLE is a multiple sequence alignment tool that takes in the user generated parsed file and runs this command.
*  <a name= "RM2"><h5> Rule muscle2:</h5></a>
    * MUSCLE will take the multi sequence alignment file generated from rule muscle and convert the file into a PHYLIP file format. PHYLIP files are plain text files consisting of 10-character header of the sequence name and the sequence alignment.
*   <a name= "RR"><h5> Rule RAXML:</h5></a>
	  * Randomized Accelerated Maximum Likelihood, or RAXML, is a program for creating a phylogenetic analysis of large datasets restricted by maximum likelihood. This specific program will generate tress of best fit which may be used in an external phylogenic tree viewer. The pipeline should export the file '*_RAxML_Output_Phylogenetic_Tree.phy'. RAXML requires many sequences in order to run. If rule does not execute, it may be caused by a small number of sequences in its input file. Try rerunning at lower threshold value or use an external phylogenic tree builder.
*   <a name= "RMG"><h5> Rule MSA2GFA:</h5></a>
    * This rule contains code that is not original to the current maintainer but has been slightly modified for use in the pipeline. Please see Citation for credit, and link to creators GitHub repository. This rule will take the generated multi sequence alignment file and convert it to a Graphical Fragment Assembly file. To view the file, the user must use an external GFA viewer for further analysis.

-------------------------------------------------------------------------------------------------------------------------------
Cleaning Working Directory Rules:

*   <a name= "RC"><h5> Rule Move:</h5></a>
    * Moves BLASTn outputs to generated file in BLAST_Outputfiles_ARCHIVE_For_Genomes_* and will tag BLASTn files with users query file name, threshold value used, and query length value inputted.
*   <a name= "RC"><h5> Rule cleanRAxML:</h5></a>
    * Tags and moves RAxML output to output folder
*   <a name= "RC"><h5> Rule Delete:</h5></a>
    * Removes unnecessary files generated by snakemake.
*   <a name= "RC"><h5> Rule Move:</h5></a>
    * Tags and moves all BLASTn outputs into ' * BLAST_Outputfiles_ARCHIVE_For_Genomes_*' folder so that user may view files or delete


--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="config_file"><h3>config.json </h3></a></span>**


*   <a name="genomesdb"><h5>"genomesdb"</h5></a>
    *   This will be the pathway to the one txt document that holds the names all genomes that the user will use in the pipeline.
        *   EX: ENSEMBL_AND_VGP_TOGETHER_FILE.txt
            *   Pre-generated file with species names found within the GitHub. Variations of these files may be used, or one of the pre-generated files could be used as well.
*   <a name="query"><h5>"query"</h5></a>
    *   A file that includes the directory and file name of your input file, this will be used as the query of the BLASTn. It is recommended that user puts file inside pre generated file named USERS query Files. If user chooses not use folder, user must provide full file path along with file name needs to be changed in config.json file. Users input file may not be a repeat sequence nor a file larger than 1MB.
        *   Must be a FASTA file
*   <a name="dbs"><h5>"dbs"</h5></a>
    *   The file path in which all '*-unmasked.fa' and '*.dna.toplevel.fa' files are located. File path should NOT end with '/'.
*   <a name="tH"><h5>"threshold"</h5></a>
    *   Default value 0.0001. User can input a value to create a maximum threshold for e-value. Recommended to be in decimal format.
*   <a name="ql"><h5>"queryLengthPer"</h5></a>
    *   Default value at 0.5 or 50%. Value must be in decimal format or value 1. User can input a query length minimum requirement to help eliminate small misalliance sequences produced by BLASTn that have met the required threshold. The pipeline will find both the query input sequence length and the subject sequence length. It will then apply a length minimum requirement, and strands that are smaller than the percent inputted of the query length will not be included in results. This can also be set to 1 to allow for all sequences found by BLASTn and meeting the e-value threshold requirement to be used.

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


Back to [HOW TO RUN #2](#HTR)


--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------

**_<span style="text-decoration:underline;"><a name="SUB_FILES_GUIDE"><h3>SUBFILES GUIDE: genomes input document </h3></a></span>_**

Guide that explained files generated by the maintainer and their purpose. These files could be used as a reference if the user wishes to create their own. Genomes labeled reflect on genomes present at time of developing pipeline and exclude older versions of genomes.

All these files can be found in the folder genomes input document.

VGP_ONLY_FILE.txt

	Pre-generated file created by maintainer that has a list of every species corresponding '*-unmasked.fa' file
	from ONLY the VGP database. Can be modified or ignored. Users may generate their own file but must change the
	path file in config to adapt to change.

	User can follow command below  while inside the /VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/Genomes folder 
	to quickly generate file, but user must manually exclude older versions of genomes. User may keep alternative 
	assemblies of genomes.

	/Genomes$ ls *-unmasked.fa >> /VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/VGP_Only_UserFile.txt


ENSEMBL_AND_VGP_TOGETHER_FILE.txt

	Pre-generated file created by maintainer that has a list of every species corresponding '*-unmasked.fa' file
	from the VGP database AND '*.dna.toplevel.fa' files from Ensembl pub/release-103 database. Can be modified or
	ignored. Users may generate their own file but must change the path file in config to adapt to change.

	User can follow command below while inside the /VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/Genomes folder
	to quickly generate file, but user must manually exclude older versions of genomes. User may keep alternative 
	assemblies of genomes.

	/Genomes$ ls *.fa >> /VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/VGP_And_ENSEMBL_UserFile.txt


ENSEMBL_ONLY_FILE.txt

	Pre-generated file created by maintainer that has a list of every species corresponding '*.dna.toplevel.fa'files
	from ONLY Ensembl pub/release-103 database. Can be modified or ignored. Users may generate their own file but must
	change the path file in config to adapt to change.

	User can follow command below  while inside the /VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/Genomes folder 
	to quickly generate file, but user must manually exclude older versions of genomes. User may keep alternative 
	assemblies of genomes.

	/Genomes$ ls *toplevel.fa >> /VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/ENSEMBL_Only_UserFile.txt


Back to [HOW TO RUN #3](#HTT)


--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"> <a name="Outfile"><h3> Output Files Generated: Output </h3></a></span>**

When ran successfully these output files should be generated with a unique naming scheme related to user inputted files and input threshold. These names will come from the config.json file's information.

There will be two folders created inside VGP_SnakeFile_Pipeline, one with the tag name of Outputfiles_For_Genomes_ * that will hold the output files generated. Another folder named with the tag BLAST_Outputfiles_ARCHIVE_For_Genomes_ * will hold a copy of all BLASTn files generated. User may choose to delete this folder if they would like. Each generated folder full name will contain the name of the genomes input document, the tag, users query name, and threshold value used.

	Example:
	   path:/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/*

		Blast folder output:

			BLAST_Outputfiles_ARCHIVE_For_Genomes_[genomedb_File_Used]_and_Query_[Users_QUERY.fa]_TH_[THRESHOLD_VALUE]

		Output files folder:

			Outputfiles_For_Genomes_[genomedb_File_Used]_and_Query_[Users_QUERY.fa]_TH_[threshold]

--------------------------------------------------------------------------------------------------------------------------------

Filenames will vary:

	These filenames will have the name of the users query file name, threshold value, and query length value in the 
	position where the star (*) is denoted.
		Example:
			[Users_QUERY.fa]_TH_[threshold]_And_Length_[queryLengthPer]_*** OUTPUTFILE ***


1. <h4> '*_blast_results.txt' </h4>

	* Should be generated tagged and moved to a pipeline generated directory in the genomes input document folder. Created 
	  in [Rule BLAST](#RB) , and moved by Rule Move.

		* The series of files that will be generated is created by taking the users query sequence and
		  running a Nucleotide BLAST search on all the genome files. BLAST will generate an alignment of
		  the genome that matched closes with the users query file. Each alignment will be given scores,
		  identities, and E-values. Specifically in this pipeline, the E-value provided is used as the
		  restrictive element that tells the pipeline if the BLASTn sequence is significant or not.

2. <h4> '*_Files_Generated_Report.txt' </h4>

	* Report of all files created from rule ‘BLAST’ and if their hits were significant or not. Generated in [Rule generateReport](#RGR).

		* After all the genomes have run through a BLASTn search:

		  	*_Files_Generated_Report.txt will loop through all parsed files and report back sequences that have 
			and have not met the users threshold e-value requirement, and if the sequence has met the query 
			length minimum.
				
			Inside this file will contain a key for symbols used inside document and sequence IDs with which file 
			they were found in.
			
					Key:
						N/L : Sequence Length Did Not Meet % Of Query Length Requirement
						N/H : E-Value Did Not Meet Threshold Requirements
						N/A : No Hits Were Found In This Genome
					@- : Sequence Is From Ensembl Database

			Below the key will be a summary of the results against applied requirements.

					Example:
					['#']: Threshold Value Used
					#: Total # of Files
					#: Total # Of Sequences Found
					#: Total # Of Rejected Sequences Found
					#: Total # Of Accepted Sequences Found


		  	Finally, sequences are organized into 'Rejected' and 'Accepted' categories. User can physically
			see which sequences, from which genomic file, have meet the e-value threshold requirement, as well 
			as the query length minimum requirement. These sequences in the 'Accepted' categories are those 
			used to generate results.

3. <h4> '*_Parsed_Final.fa' </h4>

	* File is created by [Rule parsed](#RP). Should contain all parsed files that have met the requirements set by user in [Rule findThresh](#RFT).

		* This file contains all raw-unaligned sequences that meet the threshold requirement. User can refer to
		  this file if wanted, but file will be used in the creation of '*_Multi_Seq_Align.fa'.              

			1. <h4> '*_Multi_Seq_Align.aln' </h4>

				* Generated results from [Rule muscle](#RM).

				* This file will contain all sequences that have meet the e-value threshold requirement and query length sequence minimum.More importantly, the sequences have been modified to be arranged in a multi sequence alignment format. This format allows multiple biological sequences to be aligned with one another by length. This formatting caused to show the homology of the sequences and infer about their evolutionary relationships.

4. <h4> '*_NameKey.txt' </h4>

	* This file will contain all the name of all genome files and their respective unique names generated from the VGPA pipeline. Generated in [Rule keyDoc](#RKD) .

		* When converting a multi-sequence alignment to a PHYLIP file format, the formatting only allows for 10
		  characters to be used. This PHYLIP file is necessary for the RAxML execution, however RAxML requires
		  all sequences to be named in a unique manner. To meet this requirement the pipeline generates a unique
		  naming schema for all the genomes files. When looking at the RAxML best tree in a viewer, the unique
		  names will be present. '*_NameKey.txt' will provide user with a document containing all unique names
		  and their corresponding genome file. for a quick visual, filenames that came from the Ensembl genome
		  will have a '#' before its name. The naming scheme for how the ID's were generated follows these patterns.

		1: VGP Genomes:

		    Example: A87025.1.2

				1. A: First letter of the species name: Accipiter_gentilis

				2. 87025: Last five numbers of its unique Genome Collections Accession: GCA_012487025

				3. .1: Version of file number: .1

				4. .2: Sequence order number: Second sequence in species parsed out file.
				       * If there is a letter in place of a value in this position, then starting
				         with sequence number 10, 'a' will denote that sequence. 'b' will denote the 11th sequence and so on.

		2: Ensembl Genomes:

		    Example: AAver1.0.1

				1. A: First letter of the species name: Accipiter nisus

				2. A: First letter of the Genome Assembly

				3. ver1.0: Last six letters of Genome Assembly not including endings:
					- '_v1'
					- 'na-1'
					- '_pig'

				4. .1: Sequence order number: First sequence in species parsed out file.
				       * If there is a letter in place of a value in this position, then starting
				         with sequence number 10, 'a' will denote that sequence. 'b' will denote the
								 11th sequence and so on.

5. <h4>'*_Phy_Align.phy' </h4>

	* Multi sequence file given from rule muscle and converted into a PHYLIP file format. Generated by [Rule muscle2](#RM2).

		* *_Phy_Align.phy is a multisequence alignment file that follows the formatting of PHYLIP files.
		  The file contains a unique id for all the sequences that are hits and found in the file
		  *_Multi_Seq_Align.fa . This file is used as the input to rule [Rule RAXML](#RR), and can be
		  referenced by user at any time. PHYLIPS formatting consist of two main parts a header that
		  describes the dimensions of the alignment, and the sequences itself. To understand ID name,
		  reference *_NameKey.txt. 
		  
	* '* _ Phy_Align.phy.reduced' may also be created, but is not needed for pipeline execution. This file is a compressed form of the PHYLIPS file created.

6. <h4> '*_MSA2GFA.gfa' </h4>  

	* This file will be used in addition to an external GFA viewer and will be generated by [Rule MSA2GFA](#RMG).

		* *_MSA2GFA.gfa is a file originally converted from a multi sequence alignment format to a
		   Graphical Fragment Assembly format. The purpose of a GFA format is to take sequence the
		   sequence graphs made from the assembly, splice the genes in the graph, show overlap in reads,
		   or replicants a variation in a genome. This file needs to export out into an GFA viewer, such
		   as Bandage, in order to view a graph.  

7. <h4> '*_RAxML_Output_Phylogenetic_Tree.phy' </h4>

      * The [Rule RAXML](#RR) will generate 4 files total:

			REFER TO DOC '*_NameKey.txt' FOR NAMING OF SPECIES IN FILES
			* This file will need to be viewed in an external phylogenetic viewer. It contains the best
			  scoring maximum likely hood from 100 trees, for a DNA alignment, based on an RAxMLHPC 
			  computing.


    * These files are produced by inputting the '*_Phy_Align.py' into the RAxML program. The program is used for creating a sequential and parallel Maximum Likelihood [1] based deduction of large phylogenetic trees.

8. <h4> Done.log.out and #.log.out </h4>

	* Flags used to indicate job progress, can be kept or erased after use.

*** Files 3, 5, 6, 7 listed above will not generate if there are no file hits ***


Back to [HOW TO RUN](#HOWRUN)

View [FILES GUIDE](#FILES_GUIDE): for more information.

--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------



**<span style="text-decoration:underline;"> <a name="more"><h4>More Information</h4></a> </span>**

https://cme.h-its.org/exelixis/resource/download/NewManual.pdf

[https://docs.docker.com/get-started/](https://docs.docker.com/get-started/)

https://github.com/fawaz-dabbaghieh/msa_to_gfa.

https://www.ncbi.nlm.nih.gov/books/NBK279690/

http://www.drive5.com/muscle/muscle.html

http://pathblast.org/docs/e_value.html



--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------




**<span style="text-decoration:underline;"> <a name="cite"><h4> Citations </h4></a></span>**
 A. Stamatakis: "RAxML Version 8: A tool for Phylogenetic Analysis and Post-Analysis of Large Phylogenies". In Bioinformatics, 2014, open access.


** DISCLAIMER: I am not the original creator of the msa_to_gfa program found in this repository. I have a slightly modified version of an existing workflow from the GitHub: https://github.com/fawaz-dabbaghieh/msa_to_gfa.
