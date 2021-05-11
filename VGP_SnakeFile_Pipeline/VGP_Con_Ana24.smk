#!/bin/bash
import sys
import os

#~~~~~~~~~~~~~~~~~~~~~~~~~~VARIABLES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#Configfile named
if config == {}:
    configfile: "config.json"

#Varibles in config file
query = config['query']
dbs = config['dbs']
 
##########################
queryName = config['query']
queryName = str(queryName)
queryN = os.path.basename(queryName)
queryN= str(queryN)
query1=[]
query1= [queryN]
queryNa = os.path.splitext(queryN)[0]
######################
dbp= dbs
dbsFind = dbp 
#################

end =  str(config["Output"]) + '/Outputfiles_For_'+ queryNa +'_TH_'+ str(config['tH']) + '/' + queryNa + '_'+ 'at_TH_'+ str(config['tH'])

mid = str(config["Output"]) + '/BLAST_Outputfiles_For_'+ queryNa +'_TH_'+ str(config['tH'])  + '/' + queryNa + '_'+ 'at_TH_'+ str(config['tH'])

#Getting each genome file GENOMESDB_FILE = config["genomesdb"]
GENOMESDB_FILE = config["genomesdb"]
GENOMESDB = []
with open(GENOMESDB_FILE) as f:
    for line in f:
        GENOMESDB.append(line.strip().split('\t')[0])

genomesdb=GENOMESDB

#~~~~~~~~~~~~~~~~~~~~~~~~~~RULE ALL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

rule all:
    input: expand("{param}/{genomesdb}", genomesdb=GENOMESDB, param= dbs),"%s" % query, "%s_Parsed_Final.fa" %end , "%s_RAxML_bestTree.RAXML_output.phy" %end, "%s_RAxML_info.RAXML_output.phy" %end, "%s_RAxML_parsimonyTree.RAXML_output.phy" %end, "%s_RAxML_log.RAXML_output.phy" %end, "%s_Multi_Seq_Align.aln" %end , "%s_MSA2GFA.gfa" %end ,"%s_Phy_Align.phy" %end, "%s_Files_Generated_Report.txt" %end ,  "%s_NameKey.txt" %end, expand("%s_{genomesdb}_blast_results.txt" %mid, genomesdb=GENOMESDB)  

#~~~~~~~~~~~~~~~~~~~~~~~~~~CREATE BLAST FILE~~~~~~~~~~~~~~~~~~~~~~~~~

rule BLAST: #Creates a blastn output
    input: "%s/{genomesdb}" %dbsFind, {query} 
    params: prefix="{genomesdb}"
    output: temp("{genomesdb}_blast_results.txt")
    
    shell: """ /opt/conda/bin/blastn -query {input[1]} -subject {input[0]} > {output} """

#~~~~~~~~~~~~~~~~~~~~~~~~~~THRESHOLD REQUIREMENT~~~~~~~~~~~~~~~~~~~~~  

rule findThresh: #Finds files that meets threshold requiement 
    input:"{genomesdb}_parsed.fa"
    output: temp("{genomesdb}_results_test_2.txt")
    run:
        def main():
            #Files and Variables
            file = input[0]
            thresh=config['tH']
            outputFile = output[0]
            Identities='Identities'
            Evalue = 'Expect'
            id = ''
            nameF = ''
            exp = 0
            Threshkey = []
            keys = [0]

            #Converts any value to Scientific "e" Notation - regardless of how value is presented
            ln = thresh
            ln = float(ln)
            ln = ('% e' % ln)
            
            keys = ln
            Threshkey=[keys] 
                
            #Opens input file for check
            with open(file, 'r') as fp:
                with open(outputFile, 'w') as f:

                    for line in fp:
                        ln = line
                        line = line

                        #Converting evalues of file to check if its a hit file or not 
                        if 'Expect' in ln:
                        
                            line = line
                            print (ln)
                            expect = ln.split('~')[0]
                        
                            data=ln.split('~')[1]
                            valueOnly = expect.split('=')[1]
                            valOne = float(valueOnly)
                            evalue = ('%e' % valOne) 
                            
                            #Converting line to float value for comparison check 
                            if valueOnly in expect:

                                valOne = float(valueOnly)    
                                evalue = ('% e' % valOne)
                                

                                #Comparing values to see if hit or not

                                for var in  Threshkey:
                                    evalue= float(evalue)
                                    var= float(var)

                                    #if values are a hit, returning true    
                                    if evalue > var:
                                        pass                      

                                    #if values are not a hit return false
                                    else:
                                        
                                        f.write(data)  
                                        
                                                                                   
                                       
        main()        
       
#~~~~~~~~~~~~~~~~~~~~~~~~~~PARSE OUT FILE ~~~~~~~~~~~~~~~~~~~~~~~~~~~  

rule parse: #Parses out wanted information to a temp file for later use
    input: "{genomesdb}_blast_results.txt"
    output: temp("{genomesdb}_parsed.fa")
    run:
        def main():
            #Files and Varibles
            filename = input[0]
            outputName = output[0]
            Identities ='Identities'
            Evalue = 'Expect'
            id = ''
            nameF = ''
            eval = ''
            comF = ''
            num = 1

            #Comands to parse out wanted information     
            with open(outputName,'w') as f:
            
                with open (filename,'r') as fp:
                    
                    for line in fp:

                        #Sets evalue for line to help with idenification if threshold is met
                        if Evalue in line:
                            ln = line
                            expect = ln.split(',')[1]
                            eval = expect.strip()

                        #Parse out name of sequence
                        elif line.startswith('>'):
                            line = line.split('> ')
                            name = str(line[1].replace(' ','_'))
                            name= name
                            name = name.strip()
                           
                            nameF = name

                            
                        #Parse out ID %
                        elif  Identities in line:
                            rand=str(num)
                            spNID = ''
                            spID = ''                          

                            id = line.split(',')[0]
                            id = str(id.replace(' ','_'))
                            id = id.strip()
                            id.replace(' ','_')
                            comment = '_;' + '_' + id
                        
                            comF = comment
                            print (comment)

                            #If file is from VGP naming
                            #If file is from VGP naming
                            if '-GCA' in f.name:
                                species = f.name
                                spName = species.split('-GCA')[0]
                                spNID = spName [:1]
                                sp = species.split('_',1)[1]
                                sp = sp[:1]
                                spID = species.split('-GCA')[1]
                                spID = spID.split('-')[0]
                                spID = spID[5:]
                                spID = spID 

                            elif 'Cyprinus_carpio_hebao_red.Hebao_red_carp_1.0.dna.toplevel.fa' in f.name:

                                spNID = 'C'
                                spID = 'H_red'
                            
                            elif 'Cyprinus_carpio_german_mirror.German_Mirror_carp_1.0.dna.toplevel.fa' in f.name:

                                spNID = 'C'
                                spID = 'G_Mir'
                                
                        #If file is from ensemble naming
                            else:
                                species = f.name
                                species = species.split('.dna.')[0]
                                spName = species.split('_v1')[0]
                                spName = spName.split('na-1')[0]
                                spName = spName.split('_pig')[0]
                                
                                spName = spName 
                                spNID= spName [:1]
                                
                                spI=spName.split('.',1)[1]
                                sp= spI[:1]
                                spID=str(spI)
                                spID2=spID[-6:]
                                spID= str(spID2)
                                spID = sp + spID

                            #Prints lines
                            f.write( eval + '~' + '>' +spNID + spID +  '.' + rand + ':' + nameF + '_' +'(' + spName + ')' + comF + '\n')
                            
                            num += 1

                        #Parse out sequence
                        elif line.startswith('Sbjct'):
                            lnsplit=line.split()[0:3]
                            seq=lnsplit[2]
                            seq=seq.replace('-','')
                            seq=seq.strip('\n')
                            f.write(eval + '~' + seq + '\n')                              
                                    
        main()

#~~~~~~~~~~~~~~~~~~~~~~~~~~GENERATEREPORT~~~~~~~~~~~~~~~~~~~~~~~~~~~~  

rule generateReport: #Generates a Report of all files seen, which files did or did not meet threshold requirement, and their counts
    input: expand(["{genomesdb}_blast_results.txt"], genomesdb=GENOMESDB)
    output: "%s_Files_Generated_Report.txt" %end
    run:
        def main():
            #Files and Varibles
            a = 0 
            thresh = config['tH']
            reportOut = output[0]
            ThreshHitCount = 0
            threshNOHitCnt = 0
            totalFileCount = 0
            Threshkey = {}
            NoHitThresh = ['--------------------------------------------------']
            HitThresh = ['--------------------------------------------------']
            
            #Opens Tresh.txt file to view user input        
            ln = thresh
            ln = float(ln)
            ln = ('% e' % ln)
            
            keys = ln
            Threshkey=[keys]

            #Open writable file (Report.txt)
            with open(reportOut, 'w') as rp:

                #Create varibles and print headder for file
                ln=''
                space = '                                                  '

                NohitFile = 'No Hit Files' + space
                NohitFile=str(NohitFile)
                NohitFile= NohitFile[:50]
                
                hitFile = 'Hit Files' + space
                hitFile=str(hitFile)
                hitFile= hitFile[:50]
                
                tv = 'Threshold Value' 
                nhf= '# of No Hit Files'
                hf = 'Hit File'
                ts = 'Total Number Of Sequences Seen'+ '\t'
                
                header = (NohitFile + '\t' +  hitFile  + nhf + ' / ' + hf + ' | ' + tv + ' | ' +  ts + '\n')
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

                                        evalue= float(evalue)
                                        var= float(var)
                                        
                                        #If the file does not meet threshold requirmen, strip name and add name to NO HITS list, + add 1 to counters
                                        if evalue > var:
					    
                                            fname = ''
                                            #If files are from VGP print file:
                                            if '-unmasked' in fp.name:
                        
                                                fname = (str(fp.name).rsplit('-unmasked')[0])
                                            
                                            #If files are from ensemble print files with #:  
                                            else:

                                                fnam = (str(fp.name).rsplit('.dna.')[0])
                                                fname = '#' + fnam

                                            #Increases count and stores filenames
                                            
                                            NoHitThresh.append( fname )
                                            threshNOHitCnt +=1
                                            totalFileCount +=1
    
                                        #If the file meets threshold requirment, strip name and add name to HITS list, + add 1 to counters                                                                                                   
                                        else:
                                            
                                            fname = ''

                                            #If files are from VGP print file:
                                            if '-unmasked' in fp.name:

                                                fname = (str(fp.name).rsplit('-unmasked')[0])

                                            #If files are from ensemble print files with #: 
                                            else:

                                                fnam = (str(fp.name).rsplit('.dna.')[0])
                                                fname='#'+fnam
                               
                                            #Increases count and stores filenames
                                            HitThresh.append( fname )
                                            ThreshHitCount +=1
                                            totalFileCount  +=1

                            #If files have 0 possible hits, or 'No Hits', strip name, add '**' in front of filename, and add name to NO HITS list, + add 1 to counters 
                            elif 'No hits' in line:

                                #If files are from VGP print file:
                                if '-unmasked' in fp.name:

                                    fname = (str(fp.name).rsplit('-unmasked')[0])
                                    
                                #If files are from ensemble print files with #:     
                                else:

                                    fnam = (str(fp.name).rsplit('.dna.')[0])
                                    fname ='#' + fnam

                                #Adds ** to no hit files and increases count and stores filenames
                                fname = '**' + fname
                                NoHitThresh.append(fname)
                                threshNOHitCnt +=1
                                totalFileCount +=1
                                     
                #Renaming varibles for printing
                tnhc= str(threshNOHitCnt) 
                thc = str(ThreshHitCount)
                tc = str(totalFileCount)
                
                #Naming and aligning files for printing            
                ln = ''
                space = '                                                  '
                Nohit = str(NoHitThresh[0]) + space
                Nohit = Nohit[:50]
                Hit = str(HitThresh[0]) + space
                Hit = Hit[:50]
                
                ln =  space + '\t' + space + ' ' +  tnhc + ' / ' + thc+ '  |  ' + str(Threshkey) + '  |  ' + tc +'\n'

                rp.write(ln)

                printthis = Nohit + '\t' + Hit + '\n'
                rp.write(printthis)

                #New line For Hit Thresh    
                if len(HitThresh) > len(NoHitThresh) and len(HitThresh) > 0 :
                    x = 1
                    
                    while x < len(HitThresh):
                        
                        #Formatting lines 
                        if x >= len(NoHitThresh):

                            #space = 'Odocoileus_virginianus_texanus-GCA_002102435.1' added to 50 charaters
                            ln = '' 
                            space = '                                                  '
                            Hit = str(HitThresh[x]) + space
                            Hit = Hit[:50]
                            #Final line for printing
                            ln = (space + '\t' + Hit + '\n')
                        
                        else:

                            ln = ''
                            space = '                                                  '
                            Nohit = str(NoHitThresh[x]) + space
                            Nohit = Nohit[:50]
                            Hit = str(HitThresh[x]) + space
                            Hit = Hit[:50]
                            #Final line for printing
                            ln =  (Nohit + '\t' + Hit + '\n')

                        #Illeterates and writes lines
                        x += 1 
                        rp.write(ln)
                            
                #New line For No Hit Thresh                
                if len(NoHitThresh) > len(HitThresh) and len(NoHitThresh) > 0 :
                    x = 1

                    while x < len(NoHitThresh):
                        
                        #Formating lines
                        if x >= len(HitThresh):

                            ln = ' ' 
                            space = '                                                  '
                            Nohit = str(NoHitThresh[x]) + space
                            Nohit = Nohit[:50]
                            #Final line for printing
                            ln = (Nohit + '\n' )
                                
                        else:
                            
                            ln=''
                            space = '                                                  '
                            Nohit = str(NoHitThresh[x]) + space
                            Nohit = Nohit[:50]
                            Hit = str(HitThresh[x]) + space
                            Hit = Hit[:50]
                            #Final line for printing
                            ln =  (Nohit+ '\t' + Hit + '\n')

                        #Illeterates and writes lines
                        x += 1 
                        rp.write(ln) 

                if len(NoHitThresh) == len(HitThresh) and len(HitThresh) > 0 and len(NoHitThresh) > 0:
                    x = 1 

		    while x < len(NoHitThresh): 

                        if x <= len(HitThresh):
                            ln=''
                            space = '                                                  '
                            Nohit = str(NoHitThresh[x]) + space
                            Nohit = Nohit[:50]
                            Hit = str(HitThresh[x]) + space
                            Hit = Hit[:50]
                            #Final line for printing
                            ln =  (Nohit+ '\t' + Hit + '\n')
			

                        #Illeterates and writes lines
                        x += 1 
                        rp.write(ln) 
			  
                #Close the files
                fp.close()
                        
        main()
        
#~~~~~~~~~~~~~~~~~~~~~~~~~~Name Key Document~~~~~~~~~~~~~~~~~~~~~~~~~

rule KeyDoc: #Opens all files and creates a name key for user
    input: expand(["{genomesdb}_parsed.fa"], genomesdb=GENOMESDB)
    output: "%s_NameKey.txt" %end
    run: 
        def main():
            #Files and Varibles
            a = 0 
            outputName = output[0]
            idv = ''
            fname = ''
            idname = ''

            #Opens all files 
            with open(outputName,'w') as f:
                #Writes header for file
                f.write('ID' + '\t'+ '\t' + 'FileName')
                f.write('\n')

                #Illeterates through files
                while a < len(input): 
                    file = input[a]
                    a+=1
                    
                    #Open the files
                    with open(file, 'r') as fp:
                        
                        for line in fp:

                            #Fines Header in file and extracts generated name key
                            if '>' in line:
                                id = line.split('>')[1]
                                id = str(id.split(':', 1)[0])

                                #Strips id from header of VGP files
                                if '-unmasked' in fp.name:
                                    fname = str(fp.name)          
                                    f.write(id + '\t' + fname +'\n') 

                                #Adds # in front of all files from ensemble and strips ID                  
                                else:
                                    fnam = str(fp.name)
                                    fname ='#'+fnam                  
                                    f.write(id + '\t' + fname +'\n')

        main()    

#~~~~~~~~~~~~~~~~~~~~~~~~~~Make Parsed FIle~~~~~~~~~~~~~~~~~~~~~~~~~~       
rule qInput:
    input: "%s_Files_Generated_Report.txt" %end
    output:   "%s_Parsed_Final.fa" %end 
    shell: """ touch {output[0]} """               

#~~~~~~~~~~~~~~~~~~~~~~~~~~Combined Parses~~~~~~~~~~~~~~~~~~~~~~~~~~~
rule ParsedOut: # Moves all files generated by rule 'parse' to user generated file. Removes any remaining temp files that have been genrated by snakemake
    input: "{genomesdb}_results_test_2.txt",  "%s_Parsed_Final.fa" %end , expand(["{genomesdb}_parsed.fa"], genomesdb=GENOMESDB)
    output: temp("{genomesdb}_parsed_Final.fa")
    params: prefix = "{genomesdb}"
    shell: """ touch {input[1]} && cat {input[0]} >> {output[0]} && cat {output[0]} >> {input[1]} """ 

#~~~~~~~~~~~~~~~~~~~~~~~~~~MULTI SEQ ALIGN~~~~~~~~~~~~~~~~~~~~~~~~~~~

rule muscle: # Runs a simple multi-sequence alignment on all parsed out files
    input:  "%s_Parsed_Final.fa" %end , expand(["{genomesdb}_parsed_Final.fa"], genomesdb=GENOMESDB)
    output: temp("Multi_Seq_Align.aln")
    shell: """ /opt/conda/bin/muscle -in {input[0]} -fastaout {output[0]}  """
rule cleanmuscle: # Runs a simple multi-sequence alignment on all parsed out files
    input: "Multi_Seq_Align.aln"
    output: "%s_Multi_Seq_Align.aln" %end 
    shell: """ touch {output[0]} && cat {input[0]} >> {output[0]}  """
rule muscle2: # Runs a simple multi-sequence alignment on all parsed out files
    input: "%s_Multi_Seq_Align.aln" %end 
    output: "%s_Phy_Align.phy" %end
    shell: """ /opt/conda/bin/muscle -in {input[0]} -phyiout {output[0]} """

#~~~~~~~~~~~~~~~~~~~~~~~~~~MSA2GFA~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rule MSA2GFA: # Converts the multi-sequence alignment into a FGA format
    input: "%s_Multi_Seq_Align.aln" %end 
    output:  "%s_MSA2GFA.gfa" %end 
    shell:""" python msa_to_gfa/msa_to_gfa/main.py -f {input[0]} -o {output[0]} --log test.log"""

#~~~~~~~~~~~~~~~~~~~~~~~~~~RAXML~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rule raxml: #Converts the Phylips file alignment to generate a RAXML phylogenic tree
    input: "%s_Phy_Align.phy" %end
    output: temp("RAxML_bestTree.RAXML_output.phy"), temp("RAxML_info.RAXML_output.phy"), temp("RAxML_parsimonyTree.RAXML_output.phy"), temp("RAxML_log.RAXML_output.phy")
    params: prefix= "RAXML_output.phy"
    shell: """ /opt/conda/bin/raxmlHPC -s {input[0]} -p 5 -m PROTGAMMAWAG -n {params.prefix} """
rule cleanRAxML:
    input:  "RAxML_bestTree.RAXML_output.phy", "RAxML_info.RAXML_output.phy", "RAxML_parsimonyTree.RAXML_output.phy", "RAxML_log.RAXML_output.phy"
    output:  "%s_RAxML_bestTree.RAXML_output.phy" %end, "%s_RAxML_info.RAXML_output.phy" %end, "%s_RAxML_parsimonyTree.RAXML_output.phy" %end, "%s_RAxML_log.RAXML_output.phy" %end
    shell: """ touch {output[0]} && cat {input[0]} >> {output[0]} && touch {output[1]} && cat {input[1]} >> {output[1]} && touch {output[2]} && cat {input[2]} >> {output[2]} && touch {output[3]} && cat {input[3]} >> {output[3]} """

#~~~~~~~~~~~~~~~~~~~~~~~~~~END SCRIPT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
#-------------------------------------------------------------------#
############################DIRECTORY CLEAN UP#######################

rule Move:
    input: "{genomesdb}_blast_results.txt"
    output: "%s_{genomesdb}_blast_results.txt" %mid
    shell: """ touch {output[0]} && cat {input[0]} >> {output[0]} """

#####################################################################
rule Delete:
    input:  expand(["{genomesdb}_parsed_Final.fa"], genomesdb=GENOMESDB)
    output: temp("DONE.txt")
    shell: """ rm *_blast_results.txt && rm *_parsed_Final.fa && rm *_results_test_2.txt && rm *_parsed.fa && touch {output[0]}"""
