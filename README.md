**<span style="text-decoration:underline;"><h1>ACES: Analysis of Conservation with an Extensive list of Species</h1></span>** 
  

**Maintainer:** Jeffrey Ng 

Laboratory of Dr. Tychele N. Turner, Ph.D.

Washington University in St. Louis 

## Publication
Please check out our publication describing ACES in Bioinformatics. See [link](https://pubmed.ncbi.nlm.nih.gov/34601580/).


## To run ACES in the cloud using Terra

#### Terra account setup

To first setup ACES in the cloud, you’ll need to have a [Terra account linked to GCP](https://github.com/TNTurnerLab/ACES/wiki/Setting-Up-Your-Terra-Cloud-Account) and have setup your [Workspace with ACES in it](https://github.com/TNTurnerLab/ACES/wiki/Setting-Up-Your-Workspace-with-ACES).  


Next you'll need to upload your query, database, and sample files into your Workspace.  To do so, go to the “DATA” tab, click on “Files” on the left, then on the bottom right click on the blue + symbol.  Select the files and upload them.  If you are running our example, your DATA folder should look like this:

![](https://github.com/TNTurnerLab/ACES/blob/master/images/terra_data_setup.png)

Now go to the "WORKFLOWS" tab and select those files for their corresponding variable tag.  An easy way to do this is to click on the folder icon and then click on the corresponding file.  Then fill in the rest of the options as necessary.  Here is a setup that runs with our example

![](https://github.com/TNTurnerLab/ACES/blob/master/images/terra_setup_actual.png)

After doing so, just fill in the necessary config values, a full list of which [can be found here.](https://github.com/TNTurnerLab/ACES/wiki/Config-File-Details) 

Make sure that the "Run workflow with inputs defined by file paths" option is selected, save your table, and then hit "RUN ANALYSIS"

You can view the progress of the job by clicking on “Job Manager”.  You’ll also see the Outputs from this screen as well, or you can go to the corresponding Google bucket for your job.

## To run ACES locally 

  
### Inital setup 

  
To run the job locally, you’ll need to have Java, Docker, and a Cromwell jar installed.  

* To test if you have Java installed, type `java –version` into the command line and it should return the version of java installed on your computer.   If not, please visit this [site](https://docs.oracle.com/en/java/javase/index.html) to download the jdk for your OS.  

* To download docker, go to this [site](https://docs.docker.com/get-docker/) and install Docker for your OS.  
  

* Please ensure that both java and docker are in your $PATH.  


To download the Cromwell .jar file, please go [site](https://github.com/broadinstitute/cromwell/releases) and download the latest stable build of the Cromwell jar.  In the example below, we will be using Cromwell version 65.  
   

When setting up your working directory, it is recommended that ACES directory and the database directory are in the same root directory. To download the the ACES workflow, please clone this repo:

```
git clone https://github.com/TNTurnerLab/ACES.git
```

   
You can obtain the reference genome data from either our Google bucket or Globus endpoint as described on our [wiki](https://github.com/TNTurnerLab/ACES/wiki/Retrieving-Reference-Genome-Data)

 


### Modify the config files 


After obtaining the genomes and cloning this repo, you’ll need to modify the inputs.json file for the wdl and the local.conf files found within the ACES_wdl_workflow folder.  


inputs.json:  

* "aces.datadb": "/path/to/database_file"   
* "aces.samples_file": "/path/to/list_of_genomes.txt",  
* "aces.threshold": 0.3, #Query Length Percentage  
* "aces.query": "/path/to/query.fasta",  
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
  "aces.pathToInput": "/home/jeff/Desktop/run_aces/Kvon_et_al_Genomes_db",  
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
ACES  cromwell-65.jar  Kvon_et_al_Genomes_db  
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
