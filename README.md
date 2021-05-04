**<span style="text-decoration:underline;"><h1>VGP Conservation Analysis Pipeline:</h1></span>**

Maintainer: Elvisa Mehinovic

**<span style="text-decoration:underline;"><a name="HOWRUN"><h1>HOW TO RUN</h1></a></span>**
<h3>Minimum Compute Requirements: </h3>
	
	30 GB RAM, 500 GB FREE Storage Space, recomended that user has a dual or quad core, 64-bit, x86 CPU or better.

PLEASE MAKE SURE YOU HAVE READ SECTION [User Required Script Files for Pipeline Execution](#USER_REQUIRED) :

--------------------------------------------------------------------------------------------------------------------------------
Approximate Runtime Seen Running All 511 Genome Inputs: 

	Minimum: 1.5 hours

	Maximum: 12+ hours

	Average: 4 to 5 Hours

Runtime depends on many factors such as size of users query file, RAxML file input size, users ram amount, number of genomes being ran agasint, etc. 

--------------------------------------------------------------------------------------------------------------------------------
Approximate Download and Unzip All 511 VGP and Ensembl Genomes if Ran Simultaneously: (Average based on 40Mbps Download speed)

	Minimum: 15 hours

	Maximum: 24+ hours

	Average: 24 Hours

Download time will vary between users.

--------------------------------------------------------------------------------------------------------------------------------

<h4>USERS query Files:</h4>

		    This is an empty folder generated for user to store all their input query files 
		    that will be ran currently or later. This is an optional folder however, if user 
		    decides to call file outside of this folder, they must include fill path to that 
		    file in config.json: 'query'. Open and read file the inside USERS query Files called
		    PLACE USER QUERY INPUT FILES HERE.txt for more information and example.

      

--------------------------------------------------------------------------------------------------------------------------------
BEFORE EXECUTION: 

[Refrence Outline](#O) Provided Below to Better Understand Pipeline File Locations.



1. Pull down ready to run docker image with the code provided below:

        - $ docker pull tnturnerlab/vgp_ens_pipeline:latest 
    * This docker image is pre-built and needs no modifications to it, if user wishes to build their own image manually, follow steps in [Dockerfile](#Dock) with the provided dockerfile in this pipeline.


<a name = "HTR"> 2 </a>. Have all VGP species ‘* -unmasked.fa’ files, and '* .dna.toplevel.fa' species files from Ensembl pub/release-103 in the provided Genomes directory and unzip them. 
    
   * See file [DOWNLOADING VGP AND ENSEMBL SPECIES FILES](#DOWNF) for command line codes that will help achieve this.

<a name = "HTT"> 3 </a>. Use or generate empty files corresponding to files named in [SUB-FILES GUIDE](#SUB_FILES_GUIDE) and put your query input files inside the pregenerated folder USER query Files. This folder is found in the folder VGP SnakeFile Pipeline.
    
    * Files can be modified or changed based on user's requirements

<a name = "HTF"> 4 </a>. Configure all file pathways in file [config](#config_file).json. This file can be located in VGP SnakeFile Pipeline.
    
   * Reference FILES GUIDE: [config](#config_file).json
        
	* genomesdb: 
            * currently defaulted to VGP_AND_ENSEMBL_TOGETHER.txt, unless user wants to change it, this file will run all 
              VGP and Ensembl genomes agaist users query sequence.
   	
	* query: 
           * Pathway to this file does not have to change if user puts their input file inside the pre-generated folder, 
             USER query Files. When editing this portion of the config, please only input the filename after the last /. 
	         User does not need to edit path unless they did not place their input file in provided folder.
           
   	* dbs: 
           * Do not edit this path
           
   	* tH: 
           * Defualt is set to 0.001. User may change if desired. 

5. Open file **_config.json_**, and fill in value for "[tH](#tH)" 
    
    * Within this file, enter a single value with decimal point ***can be in scientific notation but not required***  
	* Value should correspond to a threshold requirement species blast outputs must meet before they can generate a parse file.

6. Open file corresponding to that of "[genomesdb](#genomesdb)" in **_config.json_**, This file is located in the file genomes input document.
    
    * Default file is set to run all VGP and Ensembl genomes.
	* Modify and/or close this file when content.

7. Users must upload or have handy their {query} file for Blast. 
    
    * Open  **_config.json _** to set which file is the users query file: "[query](#query)"
	* Your query file should be put in file USERS_query_Files, if not please modify complete pathway to input file in config.json file.
	* Query file can not be full genomes nor LINE repeat elements. 

8. Locate [Snakefile.smk](#SNAKE) in VGP SnakeFile Pipeline folder, decide whether user will be using file VGP_Con_Ana24.smk for running on a LSF server or Desktop_VS_VGP_Con_Ana25.smk for running on a local machine.


_<span style="text-decoration:underline;"><h4>To Run on a Local Machine:</h4></span>_


9. Run Dockerfile command - CHECK: 

		- $  docker run tnturnerlab/vgp_ens_pipeline:latest (CHECKS IF PULL IS SUCCESSFUL AND FILE IS READY TO RUN)
    
10. Run Desktop_VS_VGP_Con_Ana25.smk:

		- $ docker run -v "##FULLPATH TO GITHUB CLONE##/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline:/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline" tnturnerlab/vgp_ens_pipeline:latest /opt/conda/bin/snakemake -s /VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/Desktop_VS_VGP_Con_Ana25.smk -k -w 120 --rerun-incomplete --keep-going

_<span style="text-decoration:underline;"><h4>To Run On LSF:</h4></span>_



11. Tell Docker where data and code are:
	
		* Execute LSF code:
     
     		- $ export LSF_DOCKER_VOLUMES="/##PATH_TO##/##_DIRECTORY_##/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline/:/##PATH_TO##/##_DIRECTORY_##/VGP-Conservation-Analysis/VGP_SnakeFile_Pipeline:/VGP_SnakeFile_Pipeline"
     		
		Example: 
		
			- $ export LSF_DOCKER_VOLUMES="/path/to/data:/path/name /home/directory:/home 	
		
        * Run Docker interactively to see if successful:
	
           	- $. bsub -Is -R 'rusage[mem=50GB]' -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' /bin/bash
12. Create a group job:

    	- $ bgadd -L 2000  /username/###ANY NAME YOU WOULD LIKE TO CALL JOB###
    
13. Run following script:

    	* MUST MODIFY SCRIPT TO RUN:
    
        	- $ bsub -q general -g /username/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=30GB]' -G compute-NAME -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' /opt/conda/bin/snakemake --cluster " bsub -q general -g  /username/VGP -oo %J.log.out -R 'span[hosts=1] rusage[mem=300GB]' -M 300GB -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' -n 4 " -j 100  -s VGP_Con_Ana24.smk -k -w 120 --rerun-incomplete --keep-going -F
    	* Example:
    
        	- $  bsub -q general -g /elvisa/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=30GB]' -G compute-tychele -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' /opt/conda/bin/snakemake --cluster " bsub -q general -g /elvisa/VGP  -oo %J.log.out -R 'span[hosts=1] rusage[mem=300GB]' -M 300GB -a 'docker(tnturnerlab/vgp_ens_pipeline:latest)' -n 4 " -j 100  -s VGP_Con_Ana24.smk -k -w 120 --rerun-incomplete --keep-going -F

* View [Output Files Generated](#Outfile) to see which files are generated and more information on each.
 
 <a name="o"> Refrence Outline </a>
 
![OUTLINE IMAGE|300x300,20%](https://docs.google.com/drawings/d/e/2PACX-1vRHNT2Uedh4fvA8En-y7ZyXsJTx-u0wDm1CawurKoQl1maBhxsBM0ICK6DdHVWXK33mDKLAJGPcc1bj/pub?w=960&h=720) 

**<span style="text-decoration:underline;"><h2>TABLE OF CONTENTS:</h2></span>**
* [HOW TO RUN](#HOWRUN)

* [PIPELINE BACKGROUND](#PB)

* [User Required Script Files for Pipeline Execution](#USER_REQUIRED)

	* [SCRIPT FILES](#Script_req)
	* [SUB-FILES GIVEN](#Given)
	* [USER MUST RETREIVE or PROVIDE](#USER)
  		
* [FILES GUIDE](#FILES_GUIDE) 
	* [Dockerfile](#Dock)
   	* [Snakefile.smk](#SNAKE) 
 
		*  [Rule Blast](#RB) 
		*  [Rule findThresh](#RFT) 
		*  [Rule Parse](#RP) 
		*  [Rule generateReport](#RGR)
		*  [Rule KeyDoc](#RKD) 
		*  [Rule qInput](#RQI) 
		*  [Rule ParsedOut](#RPO)
		*  [Rule muscle](#RM) 
		*  [Rule muscle2](#RM2) 
		*  [Rule MSA2GFA](#RMG) 
		*  [Rule RAXML](#RR)
		*  [Rule clean](#RC) 
		
	*  [config.json](#config_file)
		*  [genomesdb](#genomesdb)
		*  [query](#query)
		*  [dbs](#dbs)
		*  [tH](#tH)
		
		
* [RETREIVING VGP AND ENSEMBL FILES](#RETREIVING-VGP-AND-ENSEMBL-FILES)

	* [wgetfile_VGP.sh](#VGP)
	* [wgetfile_ensembl.sh](#ENS)
	* [DOWNLOADING VGP AND ENSEMBL SPECIES FILES](#DOWNF)
	
* [SUB FILES GUIDE: genomes input document](#SUB_FILES_GUIDE)

* [Output Files Generated](#Outfile)
* [More Information](#more)
* [Citations](#cite)
		
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
<a name="PB"><h3>PIPELINE BACKGROUND</h3></a>

The pipeline created takes unmasked genomes, presented by the Vertebrate Genomes Project (VGP), and an input FASTA  file to create outputs: Blast, Parse, MUSCLE alignment, PHYLIP reformatting, conversion to a GFA file, and finally a RAXML best tree output. There is an added feature that allows the user to input any value to a threshold, to only parse out files if it meets the set threshold requirement. This allows the user to only MUSCLE align if the files are at, or below threshold requirement. The pipeline also can run files that are found on Ensembl from their pub/release-103. Specifically, those files with '*.dna.toplevel.fa' suffix. These files are the equivalent to unmasked files in the VGP database. The pipeline is currently set up to run all 511 files together, however user can edit those files found in the sub-file folder. When choosing a query file to blast against, please not that LINE element repeats are not able to be run on this pipeline. This pipeline is currently set up to handle files that can be generated with a BLASTn search. The pipeline will also not handle full genomes as query inputs. 

   When executing the pipeline, there are a total of 10 files will be generated if ran successfully. These files include a ‘*_Parsed_Final.fa’ file which will include all sequences that have met the user’s threshold requirement.‘*_Files_Generated_Report.fa’ will generate a report on how many files contained hits, no hits, or did not meet the threshold requirement. This file will also tell you exactly how many hits, no hits, and total number of sequences read. After receiving the ‘*_Parsed_Final.fa’, the file will be converted into a ‘*_Multi_Seq_Align.aln’. This file takes all the parsed hit sequences and aligns them for computational use. The ‘*_MSA2GFA.fa’ file will be a file that converts the ‘*_Multi_Seq_Align.aln’ into a GFA file that can be put into a Graphical Fragment Assembly viewer for analysis.‘*_Phy_Align.phy’ is like the ‘*_MSA2GFA.fa’, except it is a multiple sequence file in PHYLIP format. This file format is required for running the RAXML analysis. When viewing the PHYLIP file or any RAXML file, please refer to the ‘*_NameKey.txt’. This Document will hold unique names to identify files and sequences in the named files. Changing this file will not change the names of files or identity names within files. RAXML will generate 4 files: ‘*_RAxML_bestTree.RAXML_output.phy’ ‘*_RAxML_info. RAXML_output.phy’ ‘*_RAxML_log.RAXML_output.phy’ ‘*_RAxML_parsimonyTree.RAXML_output.phy’. Each file will contain information regarding to the program. In the VGP_Con_Ana21.5.smk, RAXML will be running PROTGAMMAWAG GAMMA model of heterogeneity on a protein dataset while using the empirical base frequencies and the LG substitution model. This can be changed with in the pipeline under the user’s discretion. For more information regarding RAXML please refer to the manual linked in the "More Information" section. To view a phylogenic tree created from RAXML, the user will need to use an external phylogenetic viewer.

The purpose of this pipeline is to create a full-scale analysis of vertebrate species either or both from the Vertebrate Genome Project, or from Ensembl, in a quick and accurate manner. The files produced may also be looked at in external viewers for deeper, more complexed analysis. 

--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="USER_REQUIRED"><h3>User Required Script Files for Pipeline Execution:</h3></a></span>**

All required script files will be available on GitHub to be pulled on a desktop by using:

	- $ wget https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git

Or can be pulled on LSF with command:

	- $ git clone https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git

_<span style="text-decoration:underline;"> <a name="Script_req"><h4>SCRIPT FILES: </h4></a></span>_

These files are given inside of the pipeline In the folder VGP SnakeFile Pipeline:

1. [Snakefile.smk](#SNAKE)
2. [config.json](#config_file)

The provided Docker file is given for users to have, but is not required for pipeline execution.
Pipeline will run through an already existing Docker image: (tnturnerlab/vgp_ens_pipeline:latest)

1. [Dockerfile](#Dock)

<span style="text-decoration:underline;"><a name="Given"><h4>SUBFILES_GIVEN </h4></a></span>

   These files can be found inside the folder genomes input document:
   View [SUB FILES GUIDE: genomes input document](#SUB_FILES_GUIDE) for more information on each file.
	
	1. VGP_ONLY_FILE.TXT
	2. ENSEMBLE_AND_VGP_TOGETHER_FILE.TXT
	3. ENSEMBLE_ONLY_FILE.TXT

   These files can be found in the Genomes folder and should be executed in Genomes folder:
   View [RETREIVING VGP AND ENSEMBL FILES](#RETREIVING-VGP-AND-ENSEMBL-FILES) for more information on each file.
	
	1. wgetfile_ensembl.sh
	2. wgetfile_VGP.sh

   USERS_query_Files is a blank folder that is recommended for user to use to store potential input files:
   Open and read PLACE USER QUERY INPUT FILES HERE.txt for more information.
    	
	1. PLACE USER QUERY INPUT FILES HERE.txt

Files listed are maintainer generated files, user can input any customization of each file if the custom file follows the same format as the given files. File 1 contains only and all VGP files. File 2 will contain a mixture of all files found in Ensembl pub/release-103 as well as all files in the VGP database. File 3 will only contain the files pub/release-103. To run user file, make sure to change file pathway for genomesdbs in file [config.json](#config_file).


	
<span style="text-decoration:underline;"><a name="USER"><h4>USER MUST RETREIVE or PROVIDE:</h4></a></span>

1. {subject}: All VGP ‘*-unmasked.fa’ species files or Ensembl ‘*-.dna.toplevel.fa’ species files.
	- These files can be downloaded through provided script.
	
2. {query}: Any reference genome file that is a FASTA forma. PLEASE PUT USER QUERY FILE IN FILE USERS_query_Files


Back to [HOW TO RUN](#HOWRUN)



--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------






**<span style="text-decoration:underline;"><a name="FILES_GUIDE"><h3>FILES GUIDE:</h3></a></span>**

Short guide that explains files in the repository. Users can find examples, commands, and explanations on each file. This also includes a mini summary of internal components of files.

--------------------------------------------------------------------------------------------------------------------------------
**<span style="text-decoration:underline;"><a name="Dock"><h4>Dockerfile</h4></a></span>**

*** Disclaimer Make sure to build the Dockerfile locally on machine before attempting to on LSF server **

For those not familiar with docker reference this link: [https://docs.docker.com/get-started/](https://docs.docker.com/get-started/)

<h4>There is a dockerfile provided for user to modify or view, however by executing the command in [HOW TO RUN](#HOWRUN), docker image is pre-built and ready to run. Only follow these steps if user wishes to manually build the docker image.</h4>

* Find folder VGP-Conservation-Analysis. This is the folder user will use to build docker image.
*   Docker files must be built locally before use; therefore, you must build a Docker image by the command :
*   			- $  docker build  ###PATH TO DIRECTORY/VGP-Conservation-Analysis
*   Once the Docker has built an image for the Dockerfile, it is beneficial to tag the image for later use:
    *   To view IMAGE ID for tagging run command :
    *   		- $ docker images
    *   To tag Dockerfile run command:
    *   		- $ docker tag ###IMAGE ID NUMBER##  ##(your_docker_username##/##the _name_ of_useres_repository>:&lt;what_you_would_like_to_call_the_image)##
    *   		Ex: docker tag myuser01/home:##myimagename##
    *   Push docker image to your docker hub:
    *   		- $ docker push ##(docker_username>/repo_name:image_name)##
    *   ***If executed on a LSF server one must execute export LSF. ***
    *   		-  $ export LSF_DOCKER_VOLUMES="/path/to/data:/path/name /home/directory:/home"


Back to [HOW TO RUN](#HOWRUN)

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="SNAKE"><h4>Snakefile.smk</h4></a></span>**

The user has two options for which snake they can run, Desktop_VS_VGP_Con_Ana25.smk is for running on a local device while VGP_Con_Ana24.smk is used for running on a LSF server. The files execute the same and can be found in the VGP SnakeFiles folder. 
--------------------------------------------------------------------------------------------------------------------------------
The snakefile consists of a few rules:

*   <a name= "RB"><h5>Rule BLAST:</h5></a>
    *   Takes an input from genomes.txt as the subject and the given FASTA file as query and Blastn the files to create a blast output file
*   <a name= "RFT"><h5>Rule findThresh:</h5></a>
    *   This rule will take a value from user input from the threshold.txt and uses the value as a requirement to create a parsed-out file. The rule looks at the evalue in the Blast generated document and will continue with parsing out the sequence if the evalue is the same or smaller than the given threshold.
*   <a name= "RP"><h5>Rule parse:</h5></a>
    *   After a file has met the requirement given by rule’ findThresh’, the file generated by rule ‘Blast’ will undergo a parsing of its sequence, header, and species name. This rule will later be used in a combined file to undergo a MUSCLE alignment.
*   <a name= "RGR"><h5>Rule generateReport:</h5></a> 
    *   The rule generates a report for the user to allow a visual of what files have met the threshold requirement, or returned a hit, and those who have not hit. If file contains ** before its name, this indicates that there was no hit with the given species file based on the query file. There is also a running count of how many files are seen in total, number of hit files, and number of no-hit files. Number of no-hit files are a combination of files that generated a complete not hit and those who have not meet the threshold requirement. This report will also display the threshold value used. When viewing the file, the user will also notice '#'. Filenames with '#' in front of it indicates these files are specifically from the Ensembl database. Keep in mind that this file will generate if there are no hits on the query sequence that meet the threshold. If no other files aside from this rule, there is no hit, or not enough significant hits.
*   <a name= "RKD"><h5>Rule KeyDoc:</h5></a>  
    *   KeyDoc will generate a file that holds the unique filenames used throughout the pipeline. The RAXML function requires a unique naming schema with no more than ten characters being used. The logic of the naming patterns follows one of two naming techniques. Those files produced by the VGP will have the first letter of the species, followed by the last five values of their id number, file number, and sequence place within the file. File who has been pulled from the Ensembl database will appear to have a '#' inside the produced document. These files have a naming pattern like those of the VGP files. The first letter indicates the letter the species name starts with. After the first letter, the last 7 unique consecutive characters of the species name, followed by the sequence place within the file. This file will generate with the word "*NameKey.txt".
*   <a name= "RQI"><h5>Rule qInput:</h5></a>
    *   qInput will generate an empty file with the suffix as "Parsed_Final.fa". This file will be used in the rule ParsedOut to hold all sequences that meet the threshold requirement. 		
*   <a name= "RPO"><h5>Rule ParsedOut:</h5></a> 
    *   This rule combines all files created by rule ‘parse’ into the "Parsed_Final.fa" file created by the rule qInput. 
*   <a name= "RM"><h5> Rule muscle:</h5></a>
    *   MUSCLE is a multiple sequence alignment tool that takes in the user generated parsed file and runs this command. 
*  <a name= "RM2"><h5> Rule muscle2:</h5></a>
    * MUSCLE will take the multi sequence alignment file generated from rule muscle and convert the file into a PHYLIP file format. PHYLIP files are plain text files consisting of 10-character header of the sequence name and the sequence alignment. 
*   <a name= "RR"><h5> Rule RAXML:</h5></a>
    * Randomized Accelerated Maximum Likelihood, or RAXML, is a program for creating a phylogenetic analysis of large datasets restricted by maximum likelihood. This specific program will generate tress of best fit which may be used in an external phylogenic tree viewer. The pipeline should export 4 different files, one of which would be labeled ‘*_RAxML_bestTree.RAXML_output.phy’. This file is recommended to use for analysis. RAXML requires many sequences in order to run. If rule does not execute, it may be caused by a small number of sequences in its input file. Try rerunning at lower threshold value or use an external phylogenic tree builder. 
*   <a name= "RMG"><h5> Rule MSA2GFA:</h5></a>
    * This rule contains code that is not original to the current maintainer but has been slightly modified for use in the pipeline. Please see Citation for credit, and link to creators GitHub repository. This rule will take the generated multi sequence alignment file and convert it to a Graphical Fragment Assembly file. To view the file, the user must use an external GFA viewer for further analysis. 

-------------------------------------------------------------------------------------------------------------------------------
*   <a name= "RC"><h5> Rule Move:</h5></a>
    * Moves blast outputs to generated file in genomesdb_input_document and tags files with users threshold value and query file.
*   <a name= "RC"><h5> Rule clean:</h5></a>
    * All clean* rules files will tag their respective generated files with the users query file name and move the file to a generated folder in genomesdb_input_document.
*   <a name= "RC"><h5> Rule Delete:</h5></a>
    * Removes unnecessary files generated by snakemake.


--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="config_file"><h3>config.json </h3></a></span>**

This will hold all pathways to files. Snakefile uses these pathways to generate files, input rules and more. All rule inputs must include a file path to directory. Example: /My/Path/To/This/File.txt

*   <a name="genomesdb"><h5>"genomesdb"</h5></a>
    *   This will be the pathway to the one txt document that holds the names all genomes that the user will use in the pipeline.
        *   EX: ENSEMBL_AND_VGP_TOGETHER_FILE.txt 
            *   Pre-generated files with specie named found within the  GitHub. Variations of these files may be used, or one of the pre-generated files could be used as well. 
*   <a name="query"><h5>"query"</h5></a>
    *   A file that includes the directory and file name of your input file, this will be used as the query of the blast. It is recommended that user puts file inside pre generated file named USERS query Files. If user chooses not to, full file path along with file name needs to be changed in config.json file.
        *   Must be a FASTA file
*   <a name="dbs"><h5>"dbs"</h5></a>
    *   The file path in which all '*-unmasked.fa' and '*.dna.toplevel.fa' files are located. File path should NOT end with '/'.
*   <a name="tH"><h5>"tH"</h5></a>
    *   User generated threshold value that can be changed. Can contain user decimals. 


Back to [HOW TO RUN #4](#HTF)



--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------





**<span style="text-decoration:underline;"><a name="RETREIVING-VGP-AND-ENSEMBL-FILES"><h3>RETREIVING VGP AND ENSEMBL FILES</h3></a></span>**
The files named below will be used to download all files needed for this pipeline. Both files must be put in the same directory. 

						***WARNING:***
		When conducting the retrieval of files, please ensure that the user has enough storage space. 
		The total storage needed for downloading all VGP files is estimated to be 339.09GB.
		The total storage needed for downloading all Ensembl file is estimated at 117.84GB.
		Please insure there is enough storage for all files the minimum recomended free storage
		should be  approximitly 500 BG. This insures all downloaded and created files have enough
		stroage space on users device.
		
		
--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="VGP"><h3>wgetfile_VGP.sh</h3></a></span>**

This file contains the shell file that was used to pull all ‘*-unmasked.fa.gz’ files from the VGP rapid release archive. This shell file also contains the command used to extract the ‘*-unmasked.fa.gz’ files and move them into a working directory. Lastly, allowing for the files to then be unzipped through the gunzip *-unmasked.fa.gz. Modification to these commands is a must and should occur before running. The command used could be written into a snake, written directly onto the command line , or by running a file on the command line with code given in DOWNLOADING VGP AND ENSEMBL SPECIES FILES.Shell command is found in the Genomes folder.



***After execution, there should be 199 species files in the given directory.***

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="ENS"><h3>wgetfile_ensembl.sh</h3></a></span>**

This script is used to pull all '*.dna.toplevel.fa' from Ensembl's pub/release-103 archive. The file will contain the command to extract all '*.dna.toplevel.fa' for every species. Shell command is found in the Genomes folder.



***After execution, there should be 312 species files in the given directory.***

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="DOWNF"><h3>DOWNLOADING VGP AND ENSEMBL SPECIES FILES: </h3></a></span>**
	
					**** FILES UNZIPPED ARE ABOUT 458.93 GBS ***

Explanation of wgetfile_*.sh. Could run manually or execute files with shell commands listed below. Please see FILES GIVEN: wgetfile_*.sh for more information.

Open /Genomes folder and execute the following commands:

Before running either file please make sure file is executable this can be done with:

        - $ chmod +x *.sh

To run locally to get Ensembl files:

	- $ ./wgetfile_ensembl.sh 
	
Tor run on an LSF example:

	- $  bsub -q general  -R 'span[hosts=1] rusage[mem=30GB]' -G compute-tychele -a 'docker(emehinovic72/home:bwp2)' ./wgetfile_ensembl.sh
	
To run locally to get VGP files:

	- $ ./wgetfile_VGP.sh 
	
Tor run on an LSF example:

	- $  bsub -q general  -R 'span[hosts=1] rusage[mem=30GB]' -G compute-tychele -a 'docker(emehinovic72/home:bwp2)' ./wgetfile_VGP.sh
	

Back to [HOW TO RUN #2](#HTR)




--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------




**_<span style="text-decoration:underline;"><a name="SUB_FILES_GUIDE"><h3>SUBFILES GUIDE: genomes input document </h3></a></span>_**

Guide that explained files generated by the maintainer and their purpose. These files could be used as a reference if the user wishes to  create their own.
All these files can be found in the folder genomes input document. 

**VGP_ONLY_FILE.txt _**

Pre-generated file created by maintainer that has a list of every species corresponding '*-unmasked.fa' file from ONLY the VGP database. Can be modified or ignored. Users may generate their own file but must change the path file in config to adapt to change.

**ENSEMBL_AND_VGP_TOGETHER_FILE.txt _**

Pre-generated file created by maintainer that has a list of every species corresponding '*-unmasked.fa' file from the VGP database AND '*.dna.toplevel.fa' files from Ensembl pub/release-103 database. Can be modified or ignored. Users may generate their own file but must change the path file in config to adapt to change.

**ENSEMBL_ONLY_FILE.txt _**

Pre-generated file created by maintainer that has a list of every species corresponding '*.dna.toplevel.fa'files from ONLY Ensembl pub/release-103 database. Can be modified or ignored. Users may generate their own file but must change the path file in config to adapt to change.


Back to [HOW TO RUN #3](#HTT)


--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"> <a name="Outfile"><h3> Output Files Generated: </h3></a></span>**

When ran successfully these output files should be generated in a unique folder with a naming scheme related to user inputted files and input threshold:
This folder will be created in the folder genomesdb_input_document.


View [FILES GUIDE](#FILES_GUIDE): for more information.

Filenames may vary:
These filenames will also have the name of the users query file and threshold value in the position where the star is denoted.

1. <h4> '*_Multi_Seq_Align.fa' </h4> 
    
	1. Generated results from [Rule muscle](#RM). 
		
		a. This file will contain all sequences that have meet the threshold requirement. More importantly, the sequences have been modified to be arranged in a multi sequence alignment format. This format allows multiple biological sequences to be aligned with one another by length. This formatting can used to show the homology of the sequences and infer about their evolutionary relationships.

2. <h4> '*USERES_QUERYFILE_USERES_TREASH_VALUE_SPECIESNAME*_blast_results.txt' </h4> 
    
	2. Should be generated tagged and moved to a pipeline generated directory in the genomes input document folder. Created in [Rule BLAST](#RB) , and moved by Rule Move.
		
		a. The series of files that will be generated is created by taking the users query sequence and running a Nucleotide blast search on all the genome files. BLAST will generate an alignment of the genome that matched closes with the users query file. Each alignment will be given scores, identities, and E-values. Specifically in this pipeline, the E-value provided is used as the restrictive element that tells the pipeline if the blast sequence is significant or not. 

3. <h4> '*_Files_Generated_Report.txt' </h4> 
    
	3. Report of all files created from rule ‘BLAST’ and if their hits were significant or not. Generated in [Rule genratedReport](#RGR).
		
		a. After all the genomes have run through a BLASTn search,   *_Files_Generated_Report.txt will loop through all BLAST outputs and report back if the genome had met the users threshold value requirement or not. There is a header file at the top. The header states that the first column is 'No Hit files' meaning that the file had no BLAST hits at all, denoted with a star '*', or a sequence in that file did not meet the threshold requirement. The second are files that had sequences generating a hit and meet the threshold requirement set by user. In the third column there is a count of how many sequences where no hits-to-hits ratio, followed by a print of the users threshold value in the fourth column, and a total number of sequences seen in the fifth.   

4. <h4> '*_Parsed_Final.fa' </h4> 
    
	4. File is created by [Rule qInput](#RQI) . Should contain all parsed files that were generated by [Rule parsed](#RP) and moved into this file by rule [Rule ParsedOut](#RPO) because the files meet the threshold requirement in rule [Rule findThresh](#RFT). 
		
		a. This file contains all raw-unaligned sequences that meet the threshold requirement. User can refer to this file if wanted, but file will be used in the creation of '*_Multi_Seq_Align.fa'.              
       

5. <h4> '*_NameKey.txt' </h4> 

	5. This file will contain all the name of all genome files and their respective unique names generated from the VGPA pipeline. Generated in [Rule keyDoc](#RKD) .
		
		a. When converting a multisequence alignment to a PHYLIP file format, the formatting only allows for 10 characters to be used. This PHYLIP file is necessary for the RAxML execution, however RAxML requires all sequences to be named in a unique manner. To meet this requirement the pipeline generates a unique naming schema for all the genomes files. When looking at the RAxML best tree in a viewer, the unique names will be present. '*_NameKey.txt' will provide user with a document containing all unique names and their corresponding genome file. for a quick visual, filenames that came from the Ensembl genome will have a '#' before its name. The naming scheme for how the ID's were generated follows these patterns. 
			
			1.VGP Genomes:
			
			Example: A87025.1.2
			
				a. A: First letter of the species name: Accipiter_gentilis
				
				b. 87025: Last five numbers of its unique Genome Collections Accession: GCA_012487025
				
				c. .1: Version of file number: .1
				
				d. .2: Sequence order number: Second sequence in species parsed out file. 
			2: Ensembl Genomes:
			
			Example: AAver1.0.1
			
				a. A: First letter of the species name: Accipiter nisus
				
				b. A: First letter of the Genome Assembly
				
				c. ver1.0: Last six letters of Genome Assembly not including endings:
					- '_v1'
					- 'na-1'
					- '_pig'
				
				d. .1: Sequence order number: First sequence in species parsed out file. 

6. <h4> '*_Phy_Align.py' </h4> 

	6. Multi sequence file given from rule muscle and converted into a PHYLIP file format. Generated by [Rule muscle2](#RM2).

		a. '*_Phy_Align.py' is a multisequence alignment file that follows the formatting of PHYLIP files. The file contains a unique id for all the sequences that are hits and found in file '*_Multi_Seq_Align.fa'. This file is used as the input to rule [Rule RAXML](#RR), and can be referenced by user at any time. PHYLIPS formatting consist of two main parts a header that describes the dimensions of the alignment, and the sequences itself. To understand ID name, reference '*_NameKey.txt'.  
	
7. <h4> '*_MSA2GFA.gfa' </h4>  

	7. This file will be used in addition to an external GFA viewer and will be generated by [Rule MSA2GFA](#RMG). 

		a. '*_MSA2GFA.gfa' is a file originally converted from a multi sequence alignment format to a Graphical Fragment Assembly format. The purpose of a GFA format is to take sequence the sequence graphs made from the assembly, splice the genes in the graph, show overlap in reads, or replicants a variation in a genome. This file needs to export out into an GFA viewer, such as Bandage, in order to view a graph.  

8. <h4> '*_.RAXML_output.phy' </h4> 
    
   	8. The [Rule RAXML](#RR) will generate 4 files total:
   	
   		8a."*_RAxML_info.RAXML_output.phy"
		
			a. This file holds information about RAXML and the user generated tree.
			
		8b."*_RAxML_parsimonyTree.RAXML_output.phy"
		
			b. A file that can be viewed with a parsimony tree viewer. This file contained grouped taxas together based on their minimal evolutionary change.
			
		8c."*_RAxML_log.RAXML_output.phy"
		
			c. Logs of program running.
			
		8d."*_RAxML_bestTree.RAXML_output.phy" *REFER TO DOC '*_NameKey.txt' FOR NAMING OF SPECIES IN FILES*
		
			d. This file will be generated last and takes the longest to be made. This file can be viewed with a phylogenic tree viewer. It contains a computer-generated tree that is presumed to best fit species sequences into their respective branch. In order to view the tree, user must use an external viewer of their chose that is designed for viewing phylogenetic trees.
	a. These files are produced by inputting the '*_Phy_Align.py into the RAxML program. The program is used for creating a sequential and parallel Maximum Likelihood [1] based deduction of large phylogenetic trees.

9. <h4> Done.log.out and #.log.out </h4> 
    
	8. Flags used to indicate job progress, can be kept or erased after use.

*** Files 1, 6, 7 ,8 listed above will not generate if there are no file hits ***


Back to [HOW TO RUN](#HOWRUN)


--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------




**<span style="text-decoration:underline;"> <a name="more"><h4>More Information</h4></a> </span>**

https://cme.h-its.org/exelixis/resource/download/NewManual.pdf

[https://docs.docker.com/get-started/](https://docs.docker.com/get-started/)

https://github.com/fawaz-dabbaghieh/msa_to_gfa.




--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------




**<span style="text-decoration:underline;"> <a name="cite"><h4> Citations </h4></a></span>**
 A. Stamatakis: "RAxML Version 8: A tool for Phylogenetic Analysis and Post-Analysis of Large Phylogenies". In Bioinformatics, 2014, open access.


** DISCLAIMER: I am not the original creator of the msa_to_gfa program found in this repository. I have a slightly modified version of an existing workflow from the GitHub: https://github.com/fawaz-dabbaghieh/msa_to_gfa.
