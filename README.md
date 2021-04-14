<!-- Output copied to clipboard! -->

<!-----
NEW: Check the "Suppress top comment" option to remove this info from the output.

Conversion time: 1.154 seconds.


Using this Markdown file:

1. Paste this output into your source file.
2. See the notes and action items below regarding this conversion run.
3. Check the rendered output (headings, lists, code blocks, tables) for proper
   formatting and use a linkchecker before you publish this page.

Conversion notes:

* Docs to Markdown version 1.0β29
* Thu Feb 25 2021 01:41:53 GMT-0800 (PST)
* Source doc: readme file
----->


**<span style="text-decoration:underline;">VGP Conservation Analysis Pipeline:</span>**

Maintainer: Elvisa Mehinovic

The pipeline created takes unmasked genomes, presented by the Vertebrate Genomes Project, and an input FASTA  file to create outputs: Blast, Parse, and a final MUSCLE alignment. There is an added feature that allows the user to input any value to a threshold, to only parse out files if it meets the set threshold requirement. This allows the user to only MUSCLE align if the files are at, or below threshold requirement. The pipeline also has the ability to run files that are found on ensembl form their pub/release-103. The pipeline is currently set up to run all 510 files together, however user can edit the ghold.txt file to include and vaof their choosing.

**<span style="text-decoration:underline;">User Required Files For Pipeline Execution:</span>**

All required files will be available on github to be pulled on a desktop by using:

	- $ wget ADD GITHUB LINK WHEN PUSHED

Or can be pulled on RIS with command:

	- $ git clone ADD GITHUB LINK WHEN PUSHED

_<span style="text-decoration:underline;">FILES REQUIRED:</span>_



1. Snakefile.smk
2. Dockerfile
3. Config.json

<span style="text-decoration:underline;">SUB-FILES GIVEN:</span>



1. genomeshold.txt
2. threshold.txt
3. Parsed_Final.fa

<span style="text-decoration:underline;">USER MUST SUPPLY:</span>



1. {subject}: All VGP ‘*-unmasked.fa’ species files  
2. {query}: Any reference genome file that is a FASTA format.

**<span style="text-decoration:underline;">GETTING VGP SPECIES FILES:</span>**

Explanation of wgetfile.sh. Could run manually or execute files. Please see FILES GIVEN: _wgetfile.sh_ for more information.



*   VGP <span style="text-decoration:underline;">-unmasked</span> rapid release species files for {subject} in Blast
        *   [http://ftp.ensembl.org/pub/rapid-release/species/](http://ftp.ensembl.org/pub/rapid-release/species/)
    *   To download all required files at once, use the following command:	
        *   wget --recursive --no-parent -A '*-unmasked.fa.gz' ftp://[ftp.ensembl.org/pub/rapid-release/species/](ftp.ensembl.org/pub/rapid-release/species/)
    *   To move all *-unmasked.fa.gz files into a single directory, execute this command:
        *   find &lt;** INSERT A HOME DIRECTORY**> -iname '*-unmasked.fa.gz*' -exec mv '{}' &lt; **INSERT DESTINATION DIRECTORY**>  \;
            *   Example : find /storage1/  -iname '*-unmasked.fa.gz*' -exec mv '{}' /storage1/fs1/tychele/Active/projects/VGPGenomes/  \;
    *   To unzip any .gz zipped files use command:
        *   gunzip *.gz

        **** FILES UNZIPPED ARE ABOUT 300 GBS ***


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
    *   The rule generates a report for the user to allow a visual of what files have met the threshold requirement, or returned a hit, and those who have not. If file contains ** before its name, this indicates that there was no hit in the given species file. There is also a running count of how many files are seen in total, number of hit files, and number of no hit files. This report will also display the threshold value used.
*   Rule KeyDoc:
    *   KeyDoc will generate a file that holds the unique filenames used throught the pipeline. The RAXML funtion requires a unique naming schema with no more than ten charaters being used. The logic of the naming patterns follows one of two naming techniques. Those files produced by the VGP will have the first letter of the species, followed by the last five values of their id number, file number, and sequence place within the file. File who have been pulled from the Ensembl database willappear to have a '#' inside the produced document. These files have a naming pattern similar to those of the VGP files. The first letter indicates the letter the species name starts with. After the first letter, the last 7 unique consecutive charaters of thespecies name,followed by the equence splace within the file. This file will generate with the word "*NameKey.txt".
*   Rule qInput:
    *   qInput will geneate an empty file with the suffix as "Parsed_Final.fa". This file will be used in the rule ParsedOut to hold all sequences that meet the threshold requirement. 		
*   Rule ParsedOut:
    *   This rule combines all files created by rule ‘parse’ into the "Parsed_Final.fa" file created by the rule qInput. 
*   Rule muscle:
    *   MUSCLE is a multiple sequence alignment tool that takes in the user generated parsed file, and runs this command. 

**<span style="text-decoration:underline;">config.json</span>**

This will hold all pathways to files. Snakefile uses these pathways to generate files, input rules and more. All rule inputs must include a file path to directory. Example: /My/Path/To/This/File.txt



*   “genomesdb”
    *   This will be the pathway to the file in which you have named all genomes that will be used in the pipeline.
        *   genomes.txt 
            *   A pre-generated file with all species found in the VGP genomes archive 
*   “query”
    *   A file that includes the directory and file name of your input file, this will be used as the query of the blast
        *   Must be a FASTA file
*   “dbs”
    *   The file path in which all *-unmasked.fa files are located
*   “tH”
    *   Path to the user generated threshold.txt file. Users must generate this file before running the pipeline.
        *   threshold.txt 
            *   Blank, pre-generated file that can be used instead of user generated file.
*   “par”
    *   User generated file that will hold all parsed out files created from rule ParsedOut and parse. Users could name this file however they chose as long as the file name matches that of rule ‘muscle’ in Snakefile and the file ends with .fa extension.
        *   Parsed_Final.fa
            *   Pre-generated file to hold all parsed out files 
*   “trash” 
    *   Pathway for a directory in which all Blast outputs can be moved to. This allows for the decluttering of working directory and lets the user choose if they would rather keep blast outputs, or remove.
        *   To generate a directory use command:
            *   $ mkdir Your_Directory
        *   If wishing to remove **<span style="text-decoration:underline;">all</span>** files enter directory and use shell command:
            *   $ rm *_blast.txt"
        *   To remove certain files use rm and the given filename:
            *   $ Example: rm This_file.txt

**<span style="text-decoration:underline;">wgetfile.sh</span>**

This file contains the shell file that was used to pull all ‘*-unmasked.fa.gz’ files from the VGP rapid release archive. This shell file also contains the command used to extract the ‘*-unmasked.fa.gz’ files and move them into a working directory. Lastly, allowing for the files to then be unzipped through the gunzip *-unmasked.fa.gz. Modification to these commands are a must, and should occur before running. The command used could be written into a snake, written directly onto the command line , or by running a file on the command line with the codes below.



*   $ Chmod +x wget.sh 
*   $ ./wget.sh

***After execution, there should be 198 species files in the given directory.***

**_<span style="text-decoration:underline;">SUBFILES GUIDE:</span>_**

Guide that explained files generated by the maintainer and their purpose. These files could be used as a reference if the user wishes to  create their own. 

**_genomeshold.txt _**

Pregenerated file created by maintainer that has a list of every species corresponding *-unmasked.fa file. Can be modified or ignored. Users may generate their own file, but must change the path file in config to adapt to change.

**_Parsed_Final.fa_**

Maintainer generated, default file that is empty, but could be used for rule ‘ParsedOut’. This file does not need to be used, users are encouraged to change file name and create more files with changing requirements of threshold. When changing file name, user**<span style="text-decoration:underline;"> MUST</span>** change input filename in rule ‘muscle’ before execution of snake. File is set to result filename : **_Parsed_Final.fa. _**Users may generate their own file, but must change the path file in config to adapt to change.

**_threshold.txt_**

Empty file that user may or may not use when inputting threshold value. Users may generate their own file, but must change the path file in config to adapt to change.

**<span style="text-decoration:underline;">HOW TO RUN</span>**

Have all files downloaded and ready to run before moving onto this step. See FILES GUIDE and SUB-FILES GUIDE for more information before moving on.



1. Have all VGP species ‘*-unmasked.fa’ files in a single directory, and unzipped.
    1. See file **_wgetfile.sh_** for command line codes that will help achieve this.
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

**<span style="text-decoration:underline;">Output Files Generated:</span>**

When ran successfully these output files should be generated or filled with information:

View FILES GUIDE: for more information.



1. Multi_Seq_Align.fa
    1. Generated results to rule ‘muscle’.
2. SPECIESNAME_blast_results.txt
    2. Should be generated and moved to archived directory
3. Files_Generated_Report.txt
    3. Report of all files created from rule ‘BLAST’ and if their hits were significant or not.
4. Parsed_Final.fa or User Equivalent Name:
    4. Should contain all parsed files that were generated by rule ‘parsed’ and moved into this file by rule ‘ParsedOut’ because the files meet the threshold requirement from rule ‘findThresh’.
5. Done.log.out and Done2.log.out
    5. Flags used to indicate job progress
