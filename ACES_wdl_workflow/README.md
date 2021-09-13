# ACES wdl workflow

#### Developed by Jeffrey Ng, a modified version of the original ACES
#### Tychele Turner Lab, Washington University in St. Louis 

This is a directory for a modified version of the ACES pipeline, written in .wdl.  

The .wdl workflow can be run in the cloud using Terra or locally.



## To run the wdl locally

### Inital setup

To run the job locally, you’ll need to have Java, docker, and Cromwell installed. 


* To test if you have java installed, type `java –version` into the command line and it should return the version of java installed on your computer.   If not, please visit this [site](https://docs.oracle.com/en/java/javase/index.html) to download the jdk for your OS. 
* To download docker, go to this [site](https://docs.docker.com/get-docker/) and install Docker for your OS. 

* Please ensure that both java and docker are in your $PATH. 

To download the Cromwell .jar file, please go [site](https://github.com/broadinstitute/cromwell/releases)  and download the latest stable build of the Cromwell jar.  In the example below, we will be using Cromwell version 65. 

You’ll then need to obtain the genomes.  You can do this by downloading them from our Globus link, or from our Google bucket. See the wiki for help.

Lastly clone this repo.

It is recommended that ACES directory and the database directory are in the same root directory.

### Modify the config files

After obtaining the genomes and cloning this repo, you’ll need to modify the inputs.json file for the wdl and the local.conf files found within the ACES_wdl_workflow folder. 

inputs.json: 

* "aces.datadb": "/path/to/database_file"  
* "aces.samples_file": "/path/to/list_of_genomes.txt", 
* "aces.threshold": 0.3, #QL percentage 
* "aces.query": "/path/to/ZRS_from_Kvon_et_al_2016.fa", 
* "aces.max_num_seq": 1, #max number of entries to look for when running BLAST 
* "aces.pathToInput": "/path/to/database", 
* "aces.eval": 0.00001 #BLAST evalue threshold 

An example inputs.json file to run the Kvon_et_al_2016 genomes is provided. 

You’ll also need to modify the local.conf file so that, under “submit-docker” where you’ll need to add the path to the working directory using the –v command.   If the ACES and the database directory don't share the same root, you'll need to add both paths with -v.
```
submit-docker = """
        docker run \
          --rm -i \
          ${"--user " + docker_user} \
          --entrypoint ${job_shell} \
          -v /path/to/working/directory:/path/to/working/directory -v ${cwd}:${docker_cwd} \
          ${docker} ${docker_script}
        """
```

### Running the workflow

After setting all this up, you can run the workflow by running this command: 

```
java -Dconfig.file=local.conf  –jar /path/to/cromwell-<version_number>.jar run small.aces.wdl --inputs inputs.json 
```

After the workflow finished, you should see `[info] SingleWorkflowRunnerActor workflow finished with status 'Succeeded'.`  above the list of output. This will let you know that the workflow ran without issue.

Under the list of generated output, you'll see an id number:
```
"id": "<job_id>"
```
Cromwell also would have created two new directories:  `cromwell-executions` and `cromwell-workflow-logs`.  To find the output, follow this general path:

```
cromwell-executions/aces/<job id>/<task-name>/execution 
```
The BLAST output can be found in call-BLAST 

The MSA muscle alignment, and RAxML phylogenetic tree can be found in call-MSA 
 
##### Example Setup and run

Here is an example set up of inputs.json, local.conf, and command run: 

###### inputs.json: 
```
{ 
  "aces.datadb": "../Example/dbfile_KVON.txt", 
  "aces.samples_file": "../Example/Kvon_et_al_2016_species.txt", 
  "aces.threshold": 0.3, 
  "aces.query": "../Example/ZRS_from_Kvon_et_al_2016.fa", 
  "aces.max_num_seq": 1, 
  "aces.pathToInput": "/home/jeff/Desktop/run_aces/db_KV", 
  "aces.eval": 0.00001 
}
```

###### local.conf submit-docker change: 

```
submit-docker = """ 
docker run \ 
--rm -i \ 
${"--user " + docker_user} \ 
--entrypoint ${job_shell} \ 
-v /home/jeff/Desktop/run_aces : /home/jeff/Desktop/run_aces  -v ${cwd}:${docker_cwd} \ 
${docker} ${docker_script} 
""" 
```
 

###### Working directory setup: 
```
(base) jeff@jeff-OptiPlex-7060:~/Desktop/run_aces$ ls 
ACES  cromwell-65.jar  db_KV 
```
###### Running the code:

```
cd ACES/ACES_wdl_workflow 
java -Dconfig.file=local.conf -jar ../../cromwell-65.jar run small_aces.wdl --inputs inputs.json 
```
 
###### Checking the results:

```
(base) jeff@jeff-OptiPlex-7060:~/Desktop/run_aces/ACES/ACES_wdl_workflow$ cd cromwell-executions/b1a94f47-37ac-490a-bfc0-fa52ba49c22c/
(base) jeff@jeff-OptiPlex-7060:~/Desktop/run_aces/ACES/ACES_wdl_workflow/cromwell-executions/aces/b1a94f47-37ac-490a-bfc0-fa52ba49c22c$ ls
call-BLAST  call-findThresh  call-generateReport  call-grabinput  call-MSA
``` 
