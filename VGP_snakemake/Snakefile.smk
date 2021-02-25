#!/bin/bash
import sys
import os


#~~~~~~~~~~~~~~~~~~~~~~~~~~VARIABLES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#Configfile named
if config == {}:
     configfile: "config.json"

#Varibles in config file
query= config['query']
dbs=config['dbs']
thresh=config['tH']
parsedfile=config['par']
trash=config['trash']

#Getting each genome file GENOMESDB_FILE = config["genomesdb"]
GENOMESDB_FILE = config["genomesdb"]
GENOMESDB = []
with open(GENOMESDB_FILE) as f:
    for line in f:
        GENOMESDB.append(line.strip().split('\t')[0])
genomesdb=GENOMESDB

#~~~~~~~~~~~~~~~~~~~~~~~~~~RULE ALL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     
rule all:
    input: expand("{param}/{genomesdb}", genomesdb=GENOMESDB, param= dbs), "%s" % query, expand("{genomesdb}_blast_results.txt",genomesdb=GENOMESDB, param=query), expand("{genomesdb}_results_test_2.txt",genomesdb=GENOMESDB), expand("{genomesdb}_Parsed_Final.fa",genomesdb=GENOMESDB),"%s" % parsedfile,"Files_Generated_Report.txt", "Multi_Seq_Align.fa", "%s" % trash, expand("{genomesdb}_blast.txt", genomesdb=GENOMESDB)

   
#~~~~~~~~~~~~~~~~~~~~~~~~~~CREATE BLAST FILE~~~~~~~~~~~~~~~~~~~~~~~~~
rule BLAST: #Creates a blastn output
    input: "{genomesdb}" ,{query}
    output:temp("{genomesdb}_blast_results.txt")
    params: prefix="{genomesdb}"
    shell: """ /opt/conda/bin/blastn -query {input[1]} -subject {input[0]} > {output} """

#~~~~~~~~~~~~~~~~~~~~~~~~~~THRESHOLD REQUIREMENT~~~~~~~~~~~~~~~~~~~~~  
rule findThresh: #Finds files that meets threshold requiement 
    input:"{genomesdb}_blast_results.txt",thresh
    output: temp("{genomesdb}_results_test_2.txt")
    run:
        def main():
            #Files and Variables
            file = input[0]
            thresh = input[1]
            outputFile = output[0]
            Threshkey=[]
            keys =[0]

            #Opens Tresh.txt file to view user input 
            with open(thresh,'r') as tH:
                #Converts Threshold value and adds it to a directory
                for ln in tH:
                    #Converts any value to Scientific "e" Notation - regardless of how value is presented
                    ln = float(ln)
                    ln = ('% e' % ln)
                 
                    keys = ln
                    Threshkey=[keys] 
                        
                    #Opens input file for check
                    with open(file, 'r') as fp:

                        for line in fp:
                            ln = line
                            line = line

                            #Converting evalues of file to check if its a hit file or not 
                            if 'Expect' in ln:
                            
                                line = line
                                expect = ln.split(',')[1]
                                valueOnly = expect.split('=')[1]
                                valOne = float(valueOnly)
                                evalue = ('%e' % valOne) 
                                
                                #Converting line to float value for comparison check 
                                if valueOnly in ln:
                                    valOne = float(valueOnly)    
                                    evalue = ('% e' % valOne)
                                    
                                    #Comparing values to see if hit or not

                                    for var in  Threshkey:

                                        #if values are a hit, returning true    
                                        if evalue <= var:
                         
                                            return True

                                        #if values are not a hit return false
                                        else:
                                        
                                            return None                                               
                                       
        main()        

        #If the files contain a threshold that is smaller than or equal to given threshold
        if main() is True:

            #Creating output file 
            try:
                file = input[0]
                outputFile = output[0]
                with open(file, 'r') as fp:
                    with open(outputFile, 'w') as rp:
                        for line in fp:
                            rp.write(line)
            except:
                pass

#~~~~~~~~~~~~~~~~~~~~~~~~~~PARSE OUT FILE ~~~~~~~~~~~~~~~~~~~~~~~~~~~  
rule parse: #Parses out wanted information to a temp file for later use
    input: "{genomesdb}_results_test_2.txt"
    output: temp("{genomesdb}_parsed.fa")
    run:
        def main():
            #Files and Varibles
            filename = input[0]
            outputName = output[0]
            Identities='Identities'
            id=''

            #Comands to parse out wanted information
              
            with open(outputName,'w') as f:
            
                with open (filename,'r') as fp:
                    
                    for line in fp:

                        #Parse out name of sequence
                        if line.startswith('>'):
                            name = line
                            name = name.strip() 
                            f.write(name)

                            
                         #Parse out ID %
                        elif  Identities in line:
                            species = f.name
                            species = species.split('-GCA')[0]
                            id=line.split(',')[0]
                            id = id.strip()
                            comment = ' ; ' + species + ' ' + id
                            
                            f.write(comment + '\n')
                  
                        
                        #Parse out sequence
                        elif line.startswith('Sbjct'):
                            lnsplit=line.split()[0:3]
                            seq=lnsplit[2]
                            seq=seq.replace('-','')
                            seq=seq.strip('\n')
                            f.write(seq + '\n')                
                                    
        main()

#~~~~~~~~~~~~~~~~~~~~~~~~~~GENERATEREPORT~~~~~~~~~~~~~~~~~~~~~~~~~~~~                       
rule generateReport: #Generates a Report of all files seen, which files did or did not meet threshold requirement, and their counts
    input: thresh, expand(["{genomesdb}_blast_results.txt"], genomesdb=GENOMESDB)
    output: "Files_Generated_Report.txt"
    run:
        def main():
            #Files and Varibles
            a = 1 
            thresh = input[0]
            reportOut = output[0]
            ThreshHitCount = 0
            threshNOHitCnt = 0
            totalFileCount = 0
            Threshkey = {}
            NoHitThresh = []
            HitThresh = []
            
            #Opens Tresh.txt file to view user input        
            with open(thresh,'r') as tH:
                #Converts Threshold value and adds it to a directory
                for ln in tH:
                    #Converts any value to Scientific "e" Notation - regardless of how value is presented
                    ln = float(ln)
                    ln = ('% e' % ln)

                    keys = ln
                    Threshkey=[keys] 

                #Open writable file (Report.txt)
                with open(reportOut, 'w') as rp:

                    #Write out header of Report.txt 
                    ln = (' ' + '\t' + ' ' + '\t' +' ' + '\t' +' ' + '\t' +' ' + '\t' +' ')
                    lln = ln.split('\t') 
                    lln[4] = '\t'+ 'Threshold Value' + '\t'
                    lln[0]= 'No Hit Files' + '\t' + '\t' + '\t'
                    lln[2]= '\t' + '\t' +'# of No Hit Files'
                    lln[1] =  '\t'+ 'Hit Files' + '\t'
                    lln[3] = '/' +'# of Hit File'+ '\t'
                    lln[5] = '\t' +'Total Number Of Files Seen'+ '\t'
                    header = (str( lln[0] ) + str(lln[1])  + str(lln[2]) + str(lln[3]) + str(lln[4]) + str(lln[5]) + '\n') 
                    rp.write(header)
                    
                    #Loop through files in input 
                    while a < len(input): 
                        file = input[a]
                        a+=1
                        
                        #Open our file
                        with open(file, 'r') as fp:
                            
                            for line in fp:

                                #Converting evalues of file to check if its a hit file or not                             
                                if 'Expect' in line:
                                    expect = line.split(',')[1]
                                    valueOnly = expect.split('=')[1]
                                    valOne = float(valueOnly)
                                    evalue = ('%e' % valOne)
                                  
                                    #Converting line to float value for comparison check 
                                    if valueOnly in line:
                                        
                                        valOne = float(valueOnly)
                                        evalue = ('% e' % valOne)
                                        
                                        #Comparing values to see if hit or not
                                        
                                        for var in  Threshkey:

                                            #If the file does not meet threshold requirmen, strip name and add name to NO HITS list, + add 1 to counters
                                            if evalue > var:
                                                
                                                fname = (str(fp.name).rsplit('-unmasked')[0])
                                                NoHitThresh.append(fname)
                                                threshNOHitCnt +=1
                                                totalFileCount +=1

                                            #If the file meets threshold requirment, strip name and add name to HITS list, + add 1 to counters                                                                                                   
                                            else:
                                                
                                                fname =  (str(fp.name).rsplit('-unmasked')[0])
                                                HitThresh.append(fname)
                                                ThreshHitCount +=1
                                                totalFileCount  +=1
                                #If files have 0 possible hits, or 'No Hits', strip name, add '**' in front of filename, and add name to NO HITS list, + add 1 to counters 
                                elif 'No hits' in line:
                                    fname = (str(fp.name).rsplit('-unmasked')[0])
                                    fname = '**' + fname
                                    NoHitThresh.append(fname)
                                    threshNOHitCnt +=1
                                    totalFileCount +=1
                                                
                                      
                    #Creating a line in rp                
                    ln = (' ' + '\t' + ' ' + '\t' +' ' + '\t' +' ' + '\t' +' ' + '\t' +' ')
                    lln = ln.split('\t') 
                    #Line breakdown for writing out information                
                    lln[4] = Threshkey
                    lln[0]= NoHitThresh[0]
                    lln[2]= threshNOHitCnt 
                    lln[1] =  HitThresh[0] 
                    lln[3] = ThreshHitCount
                    lln[5] = totalFileCount
                    lns = (str( lln[0] ) +'\t' +  str(lln[1]) + '\t' + '\t' + str(lln[2]) + '\t' + str(lln[3]) + '\t' + '\t' + str(lln[4]) + '\t' + '\t' + str(lln[5]) + '\n') 
                                   
                    rp.write(lns)
                    #New line For Hit Thresh    
                    if len(HitThresh) > len(NoHitThresh) and len(HitThresh) > 1 :
                        x = 1
                        while x < len(HitThresh):
                            
                            #Formatting lines 
                            if x >= len(NoHitThresh):
                                ln = (' ' + '\t' + ' ' + '\t' +' ' + '\t' + ' ')
                                lln = ln.split('\t') 
                                lln[1] = '\t'
                                lln[0] = '\t'
                                lln[3] =  HitThresh[x] 
                                ln = (str(lln[1]) + lln[0] + str(lln[3]) + '\n')
                            
                            else:
                                ln = (' ' + '\t' + ' ' + '\t' + ' '+ '\t' + ' ')
                                lln = ln.split('\t') 
                                lln[1] = '\t'
                                lln[0] = NoHitThresh[x]
                                lln[3] =  HitThresh[x] 
                                ln =  (str(lln[0]) + str(lln[1]) + str(lln[3]) + '\n')
                            x += 1 
                            rp.write(ln)
                             
                  
                    #New line For No Hit Thresh                
                    if len(NoHitThresh) > len(HitThresh) and len(NoHitThresh) > 1 :
                        x = 1
                        while x < len(NoHitThresh):
                            
                            #Formating lines
                            if x >= len(HitThresh):
                                ln = (' ' + '\t' + ' ' + '\t' +' '+ '\t' + ' ')
                                lln = ln.split('\t') 
                                lln[1] = NoHitThresh[x]
                                lln[0] = '\t'
                                ln = (str(lln[1]) + lln[0])
                                 
                            else:
                               lln = ln.split('\t') 
                               lln[1] = NoHitThresh[x]
                               lln[0] = '\t'
                               lln[3] =  HitThresh[x]
                               ln =  (str(lln[1]) + lln[0] + str(lln[3]) + '/n')
                            x += 1 
                            rp.write(ln)   
         
                    #Close the files
                    fp.close()
                        
        main()
#~~~~~~~~~~~~~~~~~~~~~~~~~~Combined Parses~~~~~~~~~~~~~~~~~~~~~~~~~~~
rule ParsedOut: # Moves all files generated by rule 'parse' to user generated file. Removes any remaining temp files that have been genrated by snakemake
    input: "{genomesdb}_parsed.fa", {parsedfile}, "{genomesdb}_results_test_2.txt"
    output: temp("{genomesdb}_Parsed_Final.fa")
    params: prefix = "{genomesdb}"
    shell: """ cat {input[0]} >> {output[0]} && cat {output[0]} >> {input[1]} && rm {input[0]} && rm {input[2]}  && rm {output[0]}""" 

#~~~~~~~~~~~~~~~~~~~~~~~~~~MULTI SEQ ALIGN~~~~~~~~~~~~~~~~~~~~~~~~~~~
rule muscle: # Runs a simple multi-sequence alignment on all parsed out files
    input: "Parsed_Final.fa"
    output: "Multi_Seq_Align.fa"
    shell: """ /opt/conda/bin/muscle -in {input[0]} -out {output[0]}"""

#~~~~~~~~~~~~~~~~~~~~~~~~~~END SCRIPT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
#-------------------------------------------------------------------#
###########################DIRECTORY CLEAN UP########################
rule clean: # Moves blast outputs to a directory ment to act as an archive, and removes remaining temp files that have been generated by snakemake
    input: "{genomesdb}_blast_results.txt", {trash}, "Files_Generated_Report.txt"
    output: temp("{genomesdb}_blast.txt")
    params: prefix = "{genomesdb}"
    shell: """ cat {input[0]} >> {output[0]} && mv {output[0]}  {input[1]} && rm {input[0]} && rm {output}""" 

