**<span style="text-decoration:underline;"><h1>VGP Conservation Analysis Pipeline:</h1></span>**

Maintainer: Elvisa Mehinovic

The pipeline created takes unmasked genomes, presented by the Vertebrate Genomes Project (VGP), and an input FASTA  file to create outputs: Blast, Parse, MUSCLE alignment, phylips reformatting, conversion to a GFA file, and finaly a RAXML best tree output. There is an added feature that allows the user to input any value to a threshold, to only parse out files if it meets the set threshold requirement. This allows the user to only MUSCLE align if the files are at, or below threshold requirement. The pipeline also has the ability to run files that are found on ensembl from their pub/release-103. Specifically those files with '*.dna.toplevel.fa' suffix. These files are the equivilent to unmasked files in the VGP database. The pipeline is currently set up to run all 510 files together, however user can edit those files found in the sub-file folder.

When executing the pipeline, there are a total of 10 files will be generated if ran successfully. These files include a ‘*_Parsed_Final.fa’ file which will include all sequences that have met the users threshold requirment.‘*_Files_Generated_Report.fa’ will generate a report on how many files contained hits, no hits, or did not meet the treshold requirement. This file will also tell you exactly how many hits, no hits, and total number of sequences read. After receiving the ‘*_Parsed_Final.fa’, the file will be converted into a ‘*_Multi_Seq_Align.aln’. This file takes all the parsed hit sequences and aligns them for computational use. The ‘*_MSA2GFA.fa’ file will be a file that converts the ‘*_Multi_Seq_Align.aln’ into a GFA file that can be put into a Graphical Fragment Assembly viewer for analysis.‘*_Phy_Align.phy’ is similar to the ‘*_MSA2GFA.fa’, execpt it is a multiple sequence file in Phylip format. This file format is required for running the RAXML analysis. When viewing the Phylip file or any RAXML file, please refer to the ‘*_NameKey.txt’. This Doccument will hold qunique names to identify files and sequences in the named files. Changing this file will not change the names of files or identy names with in files. RAXML will generate 4 files: ‘*_RAxML_bestTree.RAXML_output.phy’ ‘*_RAxML_info. RAXML_output.phy’ ‘*_RAxML_log.RAXML_output.phy’ ‘*_RAxML_parsimonyTree.RAXML_output.phy’. Each file will contain information regarding to the program. In the VGP_Con_Ana21.5.smk, RAXML will be running PROTGAMMAWAG GAMMA model of heterogeneity on a protein dataset while using the empirical base frequencies and the LG substitution model. This can be changed with in the pipline under the users descression. For more information regarding RAXML please refer to the manual linked in the "More Infomation" section. To view a phylogenic tree created from RAXML, the user will need to use an external phylogentic viewer.

The purpose of this pipeline is to create a full scale analysis of vertebrate species either or both from the Vertebrate Genome Project, or from Ensembl, in a quick and accurate manner. The files produced may also be looked at in external viewers for deeper, more complexed analysis. 


**<span style="text-decoration:underline;"><h2>TABLE OF CONTENTS:</h2></span>**

* [User Required Script Files For Pipeline Execution](#USER_REQUIRED)

	* [SCRIPT FILES REQUIRED](#Script_req)
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
		*  [Rule clean#](#RC) 
		
	*  [config.json](#config_file)
		*  [genomesdb](#genomesdb)
		*  [query](#query)
		*  [dbs](#dbs)
		*  [final](#final)
		*  [tH](#tH)
		*  [trash](#trash)
		
* [RETREIVING VGP AND ENSEMBL FILES](#RETREIVING-VGP-AND-ENSEMBL-FILES)

	* [wgetfile_VGP.sh](#VGP)
	* [wgetfile_ensembl.sh](#ENS)
	* [DOWNLOADING VGP AND ENSEMBL SPECIES FILES](#DOWNF)
	
* [SUB FILES GUIDE](#SUB_FILES_GUIDE)

* [HOW TO RUN](#HOWRUN)
* [Output Files Generated](#Outfile)
* [More Information](#more)
* [Citations](#cite)
		

<sub><sup>** DISCLAIMER: I am not the orginal creater of the msa_to_gfa program found in this repository. I have a slightly modified version of an existing workflow from the github: https://github.com/fawaz-dabbaghieh/msa_to_gfa. </sup></sub>




--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------


**<span style="text-decoration:underline;"><a name="USER_REQUIRED"><h3>User Required Script Files For Pipeline Execution:</h3></a></span>**

All required script files will be available on github to be pulled on a desktop by using:

	- $ wget https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git

Or can be pulled on LSF with command:

	- $ git clone https://github.com/TNTurnerLab/VGP-Conservation-Analysis.git

_<span style="text-decoration:underline;"> <a name="Script_req"><h4>SCRIPT FILES REQUIRED: </h4></a></span>_



1. Snakefile.smk
2. Dockerfile
3. Config.json

<span style="text-decoration:underline;"><a name="Given"><h4>SUB-FILES GIVEN: </h4></a></span>

1. VGP_ONLY_FILE.TXT
2. ENSEMBLE_AND_VGP_TOGETHER_FILE.TXT
3. ENSEMBLE_ONLY_FILE.TXT
4. threshold.txt

<sub><sup>** DISCLAIMER: Files listed are mainainer generated files, user is allowed to input any customization of each file as long as the custom file follows the same format as the given files. File 1 contains only and all VGP files. File 2 will contain a mixture of all files foun in Ensembl pub/release-103 as well as all files in the VGP database. File 3 will only contain the files pub/release-103. File 4 can be edited or created to fir the piprlinr requirments.</sup></sub>
	
<span style="text-decoration:underline;"><a name="USER"><h4>USER MUST RETREIVE or PROVIDE:</h4></a></span>

1. {subject}: All VGP ‘*-unmasked.fa’ species files or ensembl ‘*-.dna.toplevel.fa’ species files.
	- These files can be downloaded through provided script.
2. {query}: Any reference genome file that is a FASTA format.



--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------



**<span style="text-decoration:underline;"><a name="FILES_GUIDE"><h3>FILES GUIDE:</h3></a></span>**

Short guide that explains files in the repository. Users can find examples, commands, and explanations on each file. This also includes a mini summary of internal components of files.

**<span style="text-decoration:underline;"><a name="Dock"><h4>Dockerfile</h4></a></span>**

For those not familiar with docker reference this link: [https://docs.docker.com/get-started/](https://docs.docker.com/get-started/)

*** Disclaimer Make sure to build the Dockerfile locally on machine before attempting to on LSF server **



*   Docker files must be built locally before use, therefore you must build a Docker image by the command :
    *   Docker build &lt;THE DIRECTORY / WHERE THE DOCKERFILE IS LOCATED>
*   Once the Docker has built an image for the Dockerfile, it is beneficial to tag the image for later use:
    *   To view &lt;IMAGE ID> for tagging run command :
        *   $ docker images
    *   To tag Dockerfile run command:
        *   docker tag &lt;IMAGE ID> &lt;your_docker_username>**/**&lt;the _name_ of_repository>:&lt;what_you_would_like_to_call_the_image>
            *   Ex: docker tag myuser01/home**:**myimage
    *   Push docker image to your docker hub:
        *   $ docker push &lt;docker_username>/&lt;repo_name>:&lt;image_name>
    *   ***If executed on Ris server one must execute export LSF. ***
        *   $ export LSF_DOCKER_VOLUMES="/path/to/data:/path/name /home/directory:/home"

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="SNAKE"><h4>Snakefile.smk</h4></a></span>**

The snakefile consists of a few rules:

*   <a name= "RB"><h5>Rule BLAST:</h5></a>
    *   Takes an input from genomes.txt as the subject and the given FASTA file as query and Blastn the files to create a blast output file
*   <a name= "RFT"><h5>Rule findThresh:</h5></a>
    *   This rule will take a value from user input from the threshold.txt and uses the value as a requirement to create a parsed out file. The rule looks at the evalue in the Blast generated document and will continue with parsing out the sequence if the evalue is the same or smaller than the given threshold.
*   <a name= "RP"><h5>Rule parse:</h5></a>
    *   After a file has met the requirement given by rule’ findThresh’, the file generated by rule ‘Blast’ will undergo a parsing of its sequence, header, and species name. This rule will later be used in a combined file to undergo a MUSCLE alignment.
*   <a name= "RGR"><h5>Rule generateReport:</h5></a> 
    *   The rule generates a report for the user to allow a visual of what files have met the threshold requirement, or returned a hit, and those who have no hit. If file contains ** before its name, this indicates that there was no hit with the given species file based on the query file. There is also a running count of how many files are seen in total, number of hit files, and number of no hit files. Number of no hit files are a combination of files that generated a complete not hit and those who have not meet the threshold requirement. This report will also display the threshold value used. When viewing the file, the user will also notice '#'. Filenames with '#' in front of it indicates these files are specifically from the Ensembl database. Keep in mind that this file will generate if there are no hits on the query sequence that meet the treshold. If no other files aside from this rule, there is no hit, or not enough significant hits.
*   <a name= "RKD"><h5>Rule KeyDoc:</h5></a>  
    *   KeyDoc will generate a file that holds the unique filenames used throught the pipeline. The RAXML funtion requires a unique naming schema with no more than ten charaters being used. The logic of the naming patterns follows one of two naming techniques. Those files produced by the VGP will have the first letter of the species, followed by the last five values of their id number, file number, and sequence place within the file. File who have been pulled from the Ensembl database willappear to have a '#' inside the produced document. These files have a naming pattern similar to those of the VGP files. The first letter indicates the letter the species name starts with. After the first letter, the last 7 unique consecutive charaters of thespecies name,followed by the equence splace within the file. This file will generate with the word "*NameKey.txt".
*    <a name= "RQI"><h5>Rule qInput:</h5></a> 
    *   qInput will geneate an empty file with the suffix as "Parsed_Final.fa". This file will be used in the rule ParsedOut to hold all sequences that meet the threshold requirement. 		
*   <a name= "RPO"><h5>Rule ParsedOut:</h5></a> 
    *   This rule combines all files created by rule ‘parse’ into the "Parsed_Final.fa" file created by the rule qInput. 
*   <a name= "RM"><h5> Rule muscle:</h5></a>
    *   MUSCLE is a multiple sequence alignment tool that takes in the user generated parsed file, and runs this command. 
*  <a name= "RM2"><h5> Rule muscle2:</h5></a>
    * MUSCLE will take the multi sequence alignment file generated from rule muscle and convert the file into a Phylips file format. Phylips files are plain text files consisting of 10 charater header of the sequence name and the sequence alignment. 
*   <a name= "RR"><h5> Rule RAXML:</h5></a>
    * Randomized Axelerated Maximum Likelihood, or RAXML, is a program for creating a phylogenetic analysis of large datasets restricted by maximum likelihood. This specific program will generate tress of best fit which may be used in an external phylogenic tree viewer. The pipeline should export 4 different files, one of which would be labled ‘*_RAxML_bestTree.RAXML_output.phy’. This file is recommend to use for analysis. RAXML requires a large number of sequences in order to run. If rule does not execute, it may be caused by a small amount of sequences in its input file. Try rerunning at lower treshold value or use an external phylogenic tree builder. 
*   <a name= "RMG"><h5> Rule MSA2GFA:</h5></a>
    * This rule contains code that is not original to the current mantainer but has been slightly modified for use in the pipeline. Please see Citation for credit, and link to creators github repository. This rule will take the generated multi sequence alignment file and convert it to a Graphical Fragment Assembly file. To view the file, the user must use an external GFA viewer for futher analysis. 
*   <a name= "RC"><h5> Rule clean#:</h5></a>
    * All clean rules files will tag all generated files with the users query file name, and move the file to a user provided destination.


--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="config_file"><h3>config.json </h3></a></span>**

This will hold all pathways to files. Snakefile uses these pathways to generate files, input rules and more. All rule inputs must include a file path to directory. Example: /My/Path/To/This/File.txt

*   <a name="genomesdb"><h5>"genomesdb"</h5></a>
    *   This will be the pathway to the one file in which holds the names all genomes that the user will use in the pipeline.
        *   EX: ENSEMBL_AND_VGP_TOGETHER_FILE.txt 
            *   Pre-generated filse with specie named found within the the github. Variations of these files may be used, or one of the pregenerated files could be used as well. 
*   <a name="query"><h5>"query"</h5></a>
    *   A file that includes the directory and file name of your input file, this will be used as the query of the blast
        *   Must be a FASTA file
*   <a name="dbs"><h5>"dbs"</h5></a>
    *   The file path in which all '*-unmasked.fa' and '*.dna.toplevel.fa' files are located. File path should NOT end with '/'.
*   <a name="final"><h5>"final"</h5></a>
    * User must provide a pathway to where they would prefer to have the pipelines output files to be exported to. File path should end with a '/'.
*   <a name="tH"><h5>"tH"</h5></a>
    *   Path to the user generated threshold.txt file. Users must generate this file before running the pipeline.
        *   threshold.txt 
            *   Blank, pre-generated file that can be used instead of user generated file.
*   <a name="trash"><h5>"trash"</h5></a>
    *   Pathway for a directory in which all Blast outputs can be moved to. This allows for the decluttering of working directory and lets the user choose if they would rather keep blast outputs, or remove.
        *   To generate a directory use command:
            *   $ mkdir Your_Directory
        *   If wishing to remove **<span style="text-decoration:underline;">all</span>** files enter directory and use shell command:
            *   $ rm *_blast.txt"
        *   To remove certain files use rm and the given filename:
            *   $ Example: rm This_file.txt



--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------


**<span style="text-decoration:underline;"><a name="RETREIVING-VGP-AND-ENSEMBL-FILES"><h3>RETREIVING VGP AND ENSEMBL FILES</h3></a></span>**
The files named below will be used to download all files needed for this pipeline. Both files must be put in the same directory. 

						***WARNING:***
		When conductinng the retreival of files, please insure that the user has enough storage space. 
		The total storage needed for downloading all VGP files is estimated to be 337.89GB.
		The total storage needed for downloading all Ensembl file is estimated at 117.84GB.
		Please insure there is enough storage for all files with at least an extra 2GB for 
		those files created in the pipeline.
		
--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="VGP"><h3>wgetfile_VGP.sh</h3></a></span>**

This file contains the shell file that was used to pull all ‘*-unmasked.fa.gz’ files from the VGP rapid release archive. This shell file also contains the command used to extract the ‘*-unmasked.fa.gz’ files and move them into a working directory. Lastly, allowing for the files to then be unzipped through the gunzip *-unmasked.fa.gz. Modification to these commands are a must, and should occur before running. The command used could be written into a snake, written directly onto the command line , or by running a file on the command line with code given in DOWNLOADING VGP AND ENSEMBL SPECIES FILES.Shell command is found in the Genomes folder.



***After execution, there should be 198 species files in the given directory.***

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="ENS"><h3>wgetfile_ensembl.sh</h3></a></span>**

This script is used to pull all '*.dna.toplevel.fa' from Ensembl's pub/release-103 archive. The file will contain the command to extract all '*.dna.toplevel.fa' for every species. Shell command is found in the Genomes folder.



***After execution, there should be 312 species files in the given directory.***

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="DOWNF"><h3>DOWNLOADING VGP AND ENSEMBL SPECIES FILES: </h3></a></span>**
	
					**** FILES UNZIPPED ARE ABOUT 455.73 GBS ***

Explanation of wgetfile_*.sh. Could run manually or execute files with shell commands listed below. Please see FILES GIVEN: wgetfile_*.sh for more information.


To run locally to get Ensembl files:

	- $ nohup bash wgetfile_ensembl.sh &
	
Tor run on an LSF example:

	- $  bsub -q general  -R 'span[hosts=1] rusage[mem=30GB]' -G compute-tychele -a 'docker(emehinovic72/home:bwp2)' wget wgetfile_ensembl.sh
	
To run locally to get VGP files:

	- $ nohup bash wgetfile_VGP.sh &
	
Tor run on an LSF example:

	- $  bsub -q general  -R 'span[hosts=1] rusage[mem=30GB]' -G compute-tychele -a 'docker(emehinovic72/home:bwp2)' wget wgetfile_VGP.sh
	



--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------

**_<span style="text-decoration:underline;"><a name="SUB_FILES_GUIDE"><h3>SUBFILES GUIDE:</h3></a></span>_**

Guide that explained files generated by the maintainer and their purpose. These files could be used as a reference if the user wishes to  create their own. 

**VGP_ONLY_FILE.txt _**

Pregenerated file created by maintainer that has a list of every species corresponding '*-unmasked.fa' file from ONLY the VGP database. Can be modified or ignored. Users may generate their own file, but must change the path file in config to adapt to change.

**ENSEMBL_AND_VGP_TOGETHER_FILE.txt _**

Pregenerated file created by maintainer that has a list of every species corresponding '*-unmasked.fa' file from the VGP database AND '*.dna.toplevel.fa' files from Ensembl pub/release-103 database. Can be modified or ignored. Users may generate their own file, but must change the path file in config to adapt to change.

**ENSEMBL_ONLY_FILE.txt _**

Pregenerated file created by maintainer that has a list of every species corresponding '*.dna.toplevel.fa'files from ONLY Ensembl pub/release-103 database. Can be modified or ignored. Users may generate their own file, but must change the path file in config to adapt to change.


**_threshold.txt_**

Empty file that user may or may not use when inputting threshold value. Users may generate their own file, but must change the path file in config to adapt to change.





--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------

**<span style="text-decoration:underline;"><a name="HOWRUN"><h3>HOW TO RUN</h3></a></span>**

Have all files downloaded and ready to run before moving onto this step. See FILES GUIDE and SUB-FILES GUIDE for more information before moving on.

PLEASE MAKE SURE YOU HAVE READ SECTION [User Required Script Files For Pipeline Execution](#USER_REQUIRED):

1. Have all VGP species ‘*-unmasked.fa’ files, and '*.dna.toplevel.fa' species files from Ensembl pub/release-103 in a single directory, and unzipped.
    
    1. See file [RETREIVING VGP AND ENSEMBL FILES](#RETREIVING-VGP-AND-ENSEMBL-FILES) for command line codes that will help achieve this.

2. Use or generate empty files corresponding to files named in [SUB-FILES GUIDE](#SUB_FILES_GUIDE)
    
    2. *** Files can be modified or changed based on user requirements***

3. Configure all file pathways in file [config](#config_file).json
    
    3. Reference FILES GUIDE: [config](#config_file).json
        
	1. Generate new directory for "[trash](#trash)" in _config.json_
	2. Generate new directory for "[final](#final)" in _config.json_

4. Open file corresponding to that of "[tH](#tH)" in **_config.json_**
    
    4. Within this file, enter a single value ***can be in scientific notation but not required***
        
	2. Value should correspond to a threshold requirement species blast outputs must meet before they are allowed to generate a parse file.

5. Open file corresponding to that of "[genomesdb](#genomesdb)" in **_config.json_**
    
    5. Default file is set to run all 198 specific files given from the VGP database.
        
	3. Modify or close this file when content.

6. Users must upload or have handy their {query} file for Blast. 
    
    6. Open  **_config.json _** to configure pathway to user file**_:_**
        
	4. "[query](#query)"

7. Open [Snakefile.smk](#SNAKE) 

        
8. (See FILES GUIDE: Docker for generating [Dockerfile](#Dock))


_<span style="text-decoration:underline;"><h4>To Run on Local Machine:</h4></span>_


9. Run Dockerfile command: 

    8. $ docker run &lt;DOCKERFILE NAME GENERATED ABOVE>  
    
10. Run Snakemake.smk:

    9. $ /opt/conda/bin/snakemake -s Snakefil2.smk -k

_<span style="text-decoration:underline;"><h4>To Run On LSF:</h4></span>_



11. Tell Docker where data and code are:

    10. Execute LSF code:
        6. Example: export LSF_DOCKER_VOLUMES="/path/to/data:/path/name /home/directory:/home
        7. Run Docker interactively to see if successful:
            1. bsub -Is -R 'rusage[mem=50GB]' -a 'docker(username/repository:TAGGEDNAME)' /bin/bash
12. Create a group job:

    11. bgadd -L 2000  /username/&lt;ANY NAME YOU WOULD LIKE TO CALL JOB>
    
13. Run following script:

    12. MODIFY SCRIPT TO YOUR SPECIFIC DOCKER:
    
        8. bsub -q general -g /username/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=30GB]' -G compute-NAME -a 'docker(username/repository:TAGGEDNAME)' /opt/conda/bin/snakemake --cluster " bsub -q general -g  /username/VGP -oo Done2.log.out -R 'span[hosts=1] rusage[mem=300GB]' -M 300GB -a 'docker(username/repository:TAGGEDNAME)' -n 4 " -j 100  -s Snakefile.smk -k -w 120 --rerun-incomplete --keep-going 
    13. Example:
    
        9. bsub -q general -g /elvisa/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=30GB]' -G compute-tychele -a 'docker(emehinovic72/home:bwp2)' /opt/conda/bin/snakemake --cluster " bsub -q general -g /elvisa/VGPl  -oo Done2.log.out -R 'span[hosts=1] rusage[mem=300GB]' -M 300GB -a 'docker(emehinovic72/home:bwp2)' -n 4 " -j 100  -s Snakefile.smk -k -w 120 --rerun-incomplete --keep-going 



--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------


**<span style="text-decoration:underline;">< a name="Outfile"><h3>Output Files Generated:</h3></a></span>**

When ran successfully these output files should be generated or filled with information:

View [FILES GUIDE](#FILES_GUIDE): for more information.

1. <h4> '*_Multi_Seq_Align.fa' </h4> 
    
	1. Generated results from [Rule muscle](#RM). 

2. <h4> '*SPECIESNAME*_blast_results.txt' </h4> 
    
	2. Should be generated and moved to archived directory. Created in [Rule BLAST](#RB) , and moved by [Rule clean0](#RC)

3. <h4> '*_Files_Generated_Report.txt' </h4> 
    
	3. Report of all files created from rule ‘BLAST’ and if their hits were significant or not. Generated in [Rule genratedReport](#RGR). 

4. <h4> '*_Parsed_Final.fa' </h4> 
    
	4. File is created by [Rule qInput](#RQI) . Should contain all parsed files that were generated by [Rule parsed](#RP) and moved into this file by rule [Rule ParsedOut](#RPO) because the files meet the threshold requirement in rule [Rule findThresh](#RFT).               
       

5. <h4> '*_NameKey.txt' </h4> 

	5. This file will contain all generated files and their respective unqiue names generated from the VGPA pipeline. Those files seen with a '#' are Ensembl files. Generated in [Rule keyDoc](#RKD) .

6. <h4> '*_Phy_Align.py' </h4> 

	6. Multi sequence file given from rule muscle, and converted into a phylips file format. Generated by [Rule muscle2](#RM2) .

7. <h4> '*_.RAXML_output.phy' </h4> 
    
   	7. The [Rule RAXML](#RR) will generate 4 files total:
   	
   		7a."*_RAxML_info.RAXML_output.phy"
		
			a. Information about RAXML and user genrated tree.
			
		7b."*_RAxML_parsimonyTree.RAXML_output.phy"
		
			b. A file that can be viewed with a parsimony tree viewer. This file contained grouped taxas together based on their minimal evolutionary change.
			
		7c."*_RAxML_log.RAXML_output.phy"
		
			c. Logs of program running.
			
		7d."*_RAxML_bestTree.RAXML_output.phy" *REFER TO DOC '*_NameKey.txt' FOR NAMING OF SPECIES IN FILES*
		
			d. Will be generated last and takes the longest to geteate. This file can be viewed with a phylogenic tree veiwer. It contains a computer generated tree that is presumed to best fit species sequences into their respecive branch.

8. <h4> Done.log.out and Done2.log.out </h4> 
    
	8. Flags used to indicate job progress


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


