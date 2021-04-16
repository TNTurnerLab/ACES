**<span style="text-decoration:underline;">VGP Conservation Analysis Pipeline:</span>**

Maintainer: Elvisa Mehinovic

The pipeline created takes unmasked genomes, presented by the Vertebrate Genomes Project (VGP), and an input FASTA  file to create outputs: Blast, Parse, and a final MUSCLE alignment. There is an added feature that allows the user to input any value to a threshold, to only parse out files if it meets the set threshold requirement. This allows the user to only MUSCLE align if the files are at, or below threshold requirement. The pipeline also has the ability to run files that are found on ensembl from their pub/release-103. Specifically those files with '*.dna.toplevel.fa' suffix. These files are the equivilent to unmasked files in the VGP database. The pipeline is currently set up to run all 510 files together, however user can edit the ghold.txt file to include and of their choosing.

When executing the pipeline, there are a total of 10 files will be generated if ran successfully. These files include a ‘*_Parsed_Final.fa’ file which will include all sequences that have met the users threshold requirment.‘*_Files_Generated_Report.fa’ will generate a report on how many files contained hits, no hits, or did not meet the treshold requirement. This file will also tell you exactly how many hits, no hits, and total number of sequences read. After receiving the ‘*_Parsed_Final.fa’, the file will be converted into a ‘*_Multi_Seq_Align.aln’. This file takes all the parsed hit sequences and aligns them for computational use. The ‘*_MSA2GFA.fa’ file will be a file that converts the ‘*_Multi_Seq_Align.aln’ into a GFA file that can be put into a Graphical Fragment Assembly viewer for analysis.‘*_Phy_Align.phy’ is similar to the ‘*_MSA2GFA.fa’, execpt it is a multiple sequence file in Phylip format. This file format is required for running the RAXML analysis. When viewing the Phylip file or any RAXML file, please refer to the ‘*_NameKey.txt’. This Doccument will hold qunique names to identify files and sequences in the named files. Changing this file will not change the names of files or identy names with in files. RAXML will generate 4 files: ‘*_RAxML_bestTree.RAXML_output.phy’ ‘*_RAxML_info. RAXML_output.phy’ ‘*_RAxML_log.RAXML_output.phy’ ‘*_RAxML_parsimonyTree.RAXML_output.phy’. Each file will contain information regarding to the program. In the VGP_Con_Ana21.5.smk, RAXML will be running PROTGAMMAWAG GAMMA model of heterogeneity on a protein dataset while using the empirical base frequencies and the LG substitution model. This can be changed with in the pipline under the users descression. For more information regarding RAXML please refer to the manual linked in the "More Infomation" section. To view a phylogenic tree created from RAXML, the user will need to use an external phylogentic viewer.

**<span style="text-decoration:underline;">User Required Script Files For Pipeline Execution:</span>**

All required script files will be available on github to be pulled on a desktop by using:

	- $ wget ADD GITHUB LINK WHEN PUSHED

Or can be pulled on LSF with command:

	- $ git clone ADD GITHUB LINK WHEN PUSHED

_<span style="text-decoration:underline;">SCRIPT FILES REQUIRED:</span>_



1. Snakefile.smk
2. Dockerfile
3. Config.json

<span style="text-decoration:underline;">SUB-FILES GIVEN:</span>

1. VGP_ONLY_FILE.TXT
2. ENSEMBLE_AND_VGP_TOGETHER_FILE.TXT
3. ENSEMBLE_ONLY_FILE.TXT
4. threshold.txt

<sub><sup>** DISCLAIMER: Files listed are mainainer generated files, user is allowed to input any customization of each file as long as the custom file follows the same format as the given files. File 1 contains only and all VGP files. File 2 will contain a mixture of all files foun in Ensembl pub/release-103 as well as all files in the VGP database. File 3 will only contain the files pub/release-103. File 4 can be edited or created to fir the piprlinr requirments.</sup></sub>
	
<span style="text-decoration:underline;">USER MUST RETREIVE or PROVIDE:</span>

1. {subject}: All VGP ‘*-unmasked.fa’ species files or ensembl ‘*-.dna.toplevel.fa’ species files.
	- These files can be downloaded through provided script.
2. {query}: Any reference genome file that is a FASTA format.


--------------------------------------------------------------------------------------------------------------------------------
**<span style="text-decoration:underline;">GETTING VGP SPECIES FILES:</span>**

Explanation of wgetfile.sh. Could run manually or execute files. Please see FILES GIVEN: _wgetfile.sh_ for more information.

#### ADD WRAPPER SCRIPT HERE TO DOWNLOAD ALL FILES####

        **** FILES UNZIPPED ARE ABOUT 300 GBS ***


--------------------------------------------------------------------------------------------------------------------------------
**<span style="text-decoration:underline;">FILES GUIDE:</span>**

Short guide that explains files in the repository. Users can find examples, commands, and explanations on each file. This also includes a mini summary of internal components of files.

**<span style="text-decoration:underline;">Dockerfile</span>**

For those not familiar with docker reference this link: [https://docs.docker.com/get-started/](https://docs.docker.com/get-started/)

*** Disclaimer Make sure to build the Dockerfile locally on machine before attempting to on RIS **



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

**<span style="text-decoration:underline;">Snakefile.smk</span>**

The snakefile consists of a few rules:



*   Rule BLAST:
    *   Takes an input from genomes.txt as the subject and the given FASTA file as query and Blastn the files to create a blast output file
*   Rule findThresh:
    *   This rule will take a value from user input from the threshold.txt and uses the value as a requirement to create a parsed out file. The rule looks at the evalue in the Blast generated document and will continue with parsing out the sequence if the evalue is the same or smaller than the given threshold.
*   Rule parse:
    *   After a file has met the requirement given by rule’ findThresh’, the file generated by rule ‘Blast’ will undergo a parsing of its sequence, header, and species name. This rule will later be used in a combined file to undergo a MUSCLE alignment.
*   Rule generateReport:
    *   The rule generates a report for the user to allow a visual of what files have met the threshold requirement, or returned a hit, and those who have no hit. If file contains ** before its name, this indicates that there was no hit with the given species file based on the query file. There is also a running count of how many files are seen in total, number of hit files, and number of no hit files. Number of no hit files are a combination of files that generated a complete not hit and those who have not meet the threshold requirement. This report will also display the threshold value used. When viewing the file, the user will also notice '#'. Filenames with '#' in front of it indicates these files are specifically from the Ensembl database.  
*   Rule KeyDoc:
    *   KeyDoc will generate a file that holds the unique filenames used throught the pipeline. The RAXML funtion requires a unique naming schema with no more than ten charaters being used. The logic of the naming patterns follows one of two naming techniques. Those files produced by the VGP will have the first letter of the species, followed by the last five values of their id number, file number, and sequence place within the file. File who have been pulled from the Ensembl database willappear to have a '#' inside the produced document. These files have a naming pattern similar to those of the VGP files. The first letter indicates the letter the species name starts with. After the first letter, the last 7 unique consecutive charaters of thespecies name,followed by the equence splace within the file. This file will generate with the word "*NameKey.txt".
*   Rule qInput:
    *   qInput will geneate an empty file with the suffix as "Parsed_Final.fa". This file will be used in the rule ParsedOut to hold all sequences that meet the threshold requirement. 		
*   Rule ParsedOut:
    *   This rule combines all files created by rule ‘parse’ into the "Parsed_Final.fa" file created by the rule qInput. 
*   Rule muscle:
    *   MUSCLE is a multiple sequence alignment tool that takes in the user generated parsed file, and runs this command. 
*   Rule muscle2:
    * MUSCLE will take the multi sequence alignment file generated from rule muscle and convert the file into a Phylips file format. Phylips files are plain text files consisting of 10 charater header of the sequence name and the sequence alignment. 
*   Rule RAXML:
    * Randomized Axelerated Maximum Likelihood, or RAXML, is a program for creating a phylogenetic analysis of large datasets restricted by maximum likelihood. This specific program will generate tress of best fit which may be used in an external phylogenic tree viewer. The pipeline should export 4 different files, one of which would be labled ‘*_RAxML_bestTree.RAXML_output.phy’. This file is recommend to use for analysis. 
*   Rule MSA2GFA:
    * This rule contains code that is not original to the current mantainer but has been slightly modified for use in the pipeline. Please see Citation for credit, and link to creators github repository. This rule will take the generated multi sequence alignment file and convert it to a Graphical Fragment Assembly file. To view the file, the user must use an external GFA viewer for futher analysis. 
*   Rule clean#:
    * All clean rules files will tag all generated files with the users query file name, and move the file to a user provided destination.

**<span style="text-decoration:underline;">config.json</span>**

This will hold all pathways to files. Snakefile uses these pathways to generate files, input rules and more. All rule inputs must include a file path to directory. Example: /My/Path/To/This/File.txt

*   “genomesdb”
    *   This will be the pathway to the one file in which holds the names all genomes that the user will use in the pipeline.
        *   EX: ENSEMBL_AND_VGP_TOGETHER_FILE.txt 
            *   Pre-generated filse with specie named found within the the github. Variations of these files may be used, or one of the pregenerated files could be used as well. 
*   “query”
    *   A file that includes the directory and file name of your input file, this will be used as the query of the blast
        *   Must be a FASTA file
*   “dbs”
    *   The file path in which all '*-unmasked.fa' and '*.dna.toplevel.fa' files are located.
*   “final”
    * User must provide a pathway to where they would prefer to have the pipelines output files to be exported to.
*   “tH”
    *   Path to the user generated threshold.txt file. Users must generate this file before running the pipeline.
        *   threshold.txt 
            *   Blank, pre-generated file that can be used instead of user generated file.
*   “trash” 
    *   Pathway for a directory in which all Blast outputs can be moved to. This allows for the decluttering of working directory and lets the user choose if they would rather keep blast outputs, or remove.
        *   To generate a directory use command:
            *   $ mkdir Your_Directory
        *   If wishing to remove **<span style="text-decoration:underline;">all</span>** files enter directory and use shell command:
            *   $ rm *_blast.txt"
        *   To remove certain files use rm and the given filename:
            *   $ Example: rm This_file.txt

--------------------------------------------------------------------------------------------------------------------------------
**<span style="text-decoration:underline;">RETREIVING VGP AND ENSEMBL FILES</span>**
The files named below will be used to download all files needed for this pipeline. Both files must be put in the same directory. 

							***WARNING:***
			When conductinng the retreival of files, please insure that the user has enough storage space. 
			The total storage needed for downloading all VGP files is estimated to be 337.89GB.
			The total storage needed for downloading all Ensembl file is estimated at 117.84GB.
			Please insure there is enough storage for all files with at least an extra 2GB for 
			those files created in the pipeline.

**<span style="text-decoration:underline;">wgetfile_VGP.sh</span>**

This file contains the shell file that was used to pull all ‘*-unmasked.fa.gz’ files from the VGP rapid release archive. This shell file also contains the command used to extract the ‘*-unmasked.fa.gz’ files and move them into a working directory. Lastly, allowing for the files to then be unzipped through the gunzip *-unmasked.fa.gz. Modification to these commands are a must, and should occur before running. The command used could be written into a snake, written directly onto the command line , or by running a file on the command line with the codes below.



*   $ Chmod +x wget.sh 
*   $ ./wget.sh

***After execution, there should be 198 species files in the given directory.***

**<span style="text-decoration:underline;">wgetfile_ensembl.sh</span>**

This script is used to pull all '*.dna.toplevel.fa' from Ensembl's pub/release-103 archive. The file will contain the command to extract all '*.dna.toplevel.fa' for every species. 




***After execution, there should be 312 species files in the given directory.***


--------------------------------------------------------------------------------------------------------------------------------
**_<span style="text-decoration:underline;">SUBFILES GUIDE:</span>_**

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
**<span style="text-decoration:underline;">HOW TO RUN</span>**

Have all files downloaded and ready to run before moving onto this step. See FILES GUIDE and SUB-FILES GUIDE for more information before moving on.



1. Have all VGP species ‘*-unmasked.fa’ files, and '*.dna.toplevel.fa' species files from Ensembl pub/release-103 in a single directory, and unzipped.
    1. See file **_wgetfile_*.sh_** for command line codes that will help achieve this.
2. Use or generate empty files corresponding to files named in SUB-FILES GUIDE
    2. *** Files can be modified or changed based on user requirements***
3. Configure all file pathways in file**_ config.json_**
    3. Reference FILES GUIDE: _config.json_
        1. Generate new directory for “trash” in _config.json_
4. Open file corresponding to that of “**tH**” in **_config.json_**
    4. Within this file, enter a single value ***can be in scientific notation but not required***
        2. Value should correspond to a threshold requirement species blast outputs must meet before they are allowed to generate a parse file.
5. Open file corresponding to that of “**genomes**” in **_config.json_**
    5. Default file is set to run all 198 specific files given from the VGP database.
        3. Modify or close this file when content.
6. Users must upload or have handy their {query} file for Blast. 
    6. Open  **_config.json _**to configure pathway to user file**_:_**
        4. “query” 
7. Open Snakefile.smk
    7. Rule: muscle:
        5. Check if input file for this rule matches filename as in the file path “par” in **_config.json_**
8. (See FILES GUIDE: Docker for generating docker file)

_<span style="text-decoration:underline;">To Run on Local Machine:</span>_



9. Run Dockerfile command: 
    8. $ docker run &lt;DOCKERFILE NAME GENERATED ABOVE>  
10. Run Snakemake.smk:
    9. $ /opt/conda/bin/snakemake -s Snakefil2.smk -k

_<span style="text-decoration:underline;">To Run On Ris: </span>_



11. Tell Docker where data and code are:
    10. Execute LSF code:
        6. Example: export LSF_DOCKER_VOLUMES="/path/to/data:/path/name /home/directory:/home
        7. Run Docker interactively to see if successful:
            1. bsub -Is -R 'rusage[mem=50GB]' -a 'docker(username/repository:TAGGEDNAME)' /bin/bash
12. Create a group job:
    11. bgadd -L 2000  /username/&lt;ANY NAME YOU WOULD LIKE TO CALL JOB>
13. Run following script:
    12. MODIFY SCRIPT TO YOUR SPECIFIC DOCKER:
        8. bsub -q general -g /username/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=5GB]' -G compute-NAME -a 'docker(username/repository:TAGGEDNAME)' /opt/conda/bin/snakemake --cluster " bsub -q general -g  /username/VGP -oo Done2.log.out -R 'span[hosts=1] rusage[mem=50GB]' -M 50GB -a 'docker(username/repository:TAGGEDNAME)' -n 4 " -j 100  -s Snakefile.smk -k -w 120 --rerun-incomplete --keep-going 
    13. Example:
        9. bsub -q general -g /elvisa/VGP -oo Done.log.out -R 'span[hosts=1] rusage[mem=5GB]' -G compute-tychele -a 'docker(emehinovic72/home:bwp)' /opt/conda/bin/snakemake --cluster " bsub -q general -g /elvisa/VGPl  -oo Done2.log.out -R 'span[hosts=1] rusage[mem=50GB]' -M 50GB -a 'docker(emehinovic72/home:bwp)' -n 4 " -j 100  -s Snakefile.smk -k -w 120 --rerun-incomplete --keep-going 

--------------------------------------------------------------------------------------------------------------------------------
**<span style="text-decoration:underline;">Output Files Generated:</span>**

When ran successfully these output files should be generated or filled with information:

View FILES GUIDE: for more information.

1. '*_Multi_Seq_Align.fa'
    
	1. Generated results to rule ‘muscle’.

2. '*SPECIESNAME*_blast_results.txt'
    
	2. Should be generated and moved to archived directory

3. '*_Files_Generated_Report.txt'
    
	3. Report of all files created from rule ‘BLAST’ and if their hits were significant or not.

4. '*_Parsed_Final.fa':
    
	4. Should contain all parsed files that were generated by rule ‘parsed’ and moved into this file by rule ‘ParsedOut’ because the files meet the threshold                
       requirement from rule ‘findThresh’.

5. '*_NameKey.txt'

	5. This file will contain all generated files and their respective unqiue names generated from the VGPA pipeline. Those files seen with a '#' are Ensembl files. 

6. '*_Phy_Align.py'

	6. Multi sequence file given from rule muscle, and converted into a phylips file format.

7. '*_*.RAXML_output.phy"
    
   	7. The rule RAXML will generate 4 files total:
   	
   		7a."*_RAxML_info.RAXML_output.phy"
		
			a. Information about RAXML and user genrated tree.
			
		7b."*_RAxML_parsimonyTree.RAXML_output.phy"
		
			b. A file that can be viewed with a parsimony tree viewer. This file contained grouped taxas together based on their minimal evolutionary change.
			
		7c."*_RAxML_log.RAXML_output.phy"
		
			c. Logs of program running.
			
		7d."*_RAxML_bestTree.RAXML_output.phy" *REFER TO DOC '*_NameKey.txt' FOR NAMING OF SPECIES IN FILES*
		
			d. Will be generated last and takes the longest to geteate. This file can be viewed with a phylogenic tree veiwer. It contains a computer generated tree that is presumed to best fit species sequences into their respecive branch.

8. Done.log.out and Done2.log.out
    
	8. Flags used to indicate job progress

--------------------------------------------------------------------------------------------------------------------------------
**<span style="text-decoration:underline;"> More Information </span>**

https://cme.h-its.org/exelixis/resource/download/NewManual.pdf

**<span style="text-decoration:underline;"> Citations </span>**
 A. Stamatakis: "RAxML Version 8: A tool for Phylogenetic Analysis and Post-Analysis of Large Phylogenies". In Bioinformatics, 2014, open access.


