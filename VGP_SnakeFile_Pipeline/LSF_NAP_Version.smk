#!/bin/bash
import sys
import os
import math

#~~~~~~~~~~~~~~~~~~~~~~~~~~VARIABLES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#Configfile named
if config == {}:
    configfile: "config.json"

#Variables in config file
query = config['query']
dbs = config['dbs']
 
############################################
queryName = config['query']
queryName = str(queryName)
queryN = os.path.basename(queryName)
queryN = str(queryN)
query1 = []
query1 = [queryN]
queryNa = os.path.splitext(queryN)[0]
############################################
dbp= dbs
dbsFind = dbp 
############################################
gfile = config['genomesdb']
genomefile = os.path.basename(gfile)
genomefile = str(genomefile)
############################################
rootpath = config['dbs']
outputpath = os.path.split(rootpath)[0]
############################################
end =  outputpath + '/Outputfiles_For_Genomes_' + genomefile +'_and_Query_' + queryNa +'_TH_'+ str(config['threshold']) + '/' + queryNa + '_'+ 'at_TH_'+ str(config['threshold']) + '_And_Length_'+ str(config['queryLengthPer'])

mid = outputpath + '/BLAST_Outputfiles_ARCHIVE_For_Genomes_' + genomefile +'_and_Query_' + queryNa +'_TH_'+ str(config['threshold'])  + '/' + queryNa + '_'+ 'at_TH_'+ str(config['threshold']) + '_And_Length_'+ str(config['queryLengthPer'])
############################################

#Getting each genome file GENOMESDB_FILE = config["genomesdb"]
GENOMESDB_FILE = config["genomesdb"]
GENOMESDB = []
with open(GENOMESDB_FILE) as f:
    for line in f:
        GENOMESDB.append(line.strip().split('\t')[0])

genomesdb=GENOMESDB

#~~~~~~~~~~~~~~~~~~~~~~~~~~RULE ALL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

rule all:
    input: expand("{param}/{genomesdb}", genomesdb=GENOMESDB, param= dbs),"%s" % query, "%s_Parsed_Final.fa" %end , "%s_Multi_Seq_Align.aln" %end , "%s_MSA2GFA.gfa" %end ,"%s_Phy_Align.phy" %end, "%s_Files_Generated_Report.txt" %end , "%s_NameKey.txt" %end, expand("%s_{genomesdb}_blast_results.txt" %mid, genomesdb=GENOMESDB), "%s_RAxML_bootstrap.phy" %end , "%s_RAxML_bestTree.phy" %end, "%s_RAxML_bipartitionsBranchLabels.phy" %end, "%s_RAxML_bipartition.phy" %end, "%s_RAxML_info.log" %end

#~~~~~~~~~~~~~~~~~~~~~~~~~~CREATE BLAST FILE~~~~~~~~~~~~~~~~~~~~~~~~~

rule BLAST: #Creates a blastn output
    input: "%s/{genomesdb}" %dbsFind, {query} 
    params: prefix="{genomesdb}"
    output: temp("{genomesdb}_blast_results.txt")
    shell: """ /opt/conda/bin/blastn -query {input[1]} -subject {input[0]}  > {output}  """

#~~~~~~~~~~~~~~~~~~~~~~~~~~THRESHOLD REQUIREMENT~~~~~~~~~~~~~~~~~~~~~  

rule findThresh: #Finds files that meets threshold requirement 
    input: expand(["{genomesdb}_parsed.fa"], genomesdb=GENOMESDB)
    output: "%s_Parsed_Final.fa" %end 
    run:
        def main():
            #Files and Variables
            a=0
            thresh=config['threshold']
            outputFile = output[0]
            Identities ='Identities'
            Evalue = 'Expect'
            id = ''
            nameF = ''
            exp = 0
            Threshkey = []
            keys = [0]
            num=0
            alt=['0','.','-','_','+']

            #Converts any value to Scientific "e" Notation - regardless of how value is presented
            ln = thresh
            ln = float(ln)
            ln = ('% e' % ln)
            
            keys = ln
            Threshkey=[keys] 
                
            #Opens input file for check
            with open(outputFile, 'w') as f:
                while a < len(input): 
                    file = input[a]
                    a+=1
                    
                    #Open the files
                    with open(file, 'r') as fp:
                
                        for line in fp:
                            ln = line
                            line = line
                            
                            #Converting evalues of file to check if its a hit file or not based on Y or N for meeting query length
                            if 'YExpect' in ln:
                            
                                line = line    
                                expect = ln.split('~',1)[0]
                                data=ln.split('~',2)[1]
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

                                        #if values are a hit, returning false    
                                        if evalue > var:
                                            pass                      

                                        #if values are not a hit return true
                                        else:
                                            data=data                                              
                                            f.write(data)                                                                     
                                       
        main()        
       
#~~~~~~~~~~~~~~~~~~~~~~~~~~PARSE OUT FILE ~~~~~~~~~~~~~~~~~~~~~~~~~~~  

rule parse: #Parses out wanted information and tags each sequence with expect # and Y or N 
    input: "{genomesdb}_blast_results.txt"
    output: temp("{genomesdb}_parsed.fa")
    run:
        def main():
            #Files and Varibles
            filename = input[0]
            outputName = output[0]
            qLength = 0
            sLength = 0
            hold = []
            percent = config['queryLengthPer']
            match = ''
            Identities ='Identities'
            Evalue = 'Expect'
            id = ''
            nameF = ''
            eval = ''
            comF = ''
            num = 1

            seqOrder =['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

            #Comands to parse out wanted information     
            with open(outputName,'w') as f:
            
                with open (filename,'r') as fp:
                    
                    for line in fp:
                        ln=line
                        #Sets evalue for line to help with idenification if threshold is met

                        if 'Length=' in line:
                            len = line.split('=')[1]
                            hold.append(len)
                            qlen = hold[0]
                            qlen = float(qlen)
                            qlenmin = float(qlen) * float(percent)  
                            qLength = qlenmin
                        
                        elif Evalue in line:
                            ln = line
                            expect = ln.split(',')[1]
                            eval = expect.strip()

                        #Parse out name of sequence
                        elif line.startswith('>'):
                            line = line.split('> ')
                            name = str(line[1].replace(' ','_'))
                            name = name
                            name = name.strip()
                        
                            nameF = name
                
                        #Parse out ID %
                        elif  Identities in line:
                            x = num
                            rand = str(seqOrder[x])
                            spNID = ''
                            spID = ''  

                            ##########################
                            id = line.split(',')[0]
                            id = str(id.replace(' ','_'))
                            id = id.strip()
                            id.replace(' ','_')
                            comment = '_;' + '_' + id
                            comF = comment

                            #########################
                            #Gaps holds total seq subject length as well, takes seqence legth and sees if it is greater than query length set, then tags sequence with Y or N
                            if 'Gaps' in line:
                                ln = line.split('/',2)[1]
                                ln = ln.split(' (')[0]
                                sLength = ln

                                if float(sLength) >= float(qLength):
                                    match = 'Y'
                                else:
                                    match ='N'
                            
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
                                
                        #If file is from ensemble naming
                            else:
                                species = f.name
                                species = species.split('.dna.')[0]
                                spName = species.split('_v1')[0]
                                spName = spName.split('na-1')[0]
                                spName = spName.split('_pig')[0]
                                spName = spName.split('irror.He')[0]
                                spName = spName.split('ed.Ger')[0]                 

                                spName = spName 
                                spNID= spName [:1]
                                
                                spI=spName.split('.',1)[1]
                                sp= spI[:1]
                                spID=str(spI)
                                spID2=spID[-6:]
                                spID= str(spID2)
                                spID = sp + spID

                            #Prints lines
                            #print (match + eval + '~'  + '>' +spNID + spID +  '.' + rand + ':' + nameF + '_' +'(' + spName + ')' + comF + '\n')
                            f.write( match + eval + '~'  + '>' +spNID + spID +  '.' + rand + ':' + nameF + '_' +'(' + spName + ')' + comF + '\n')
                            
                            num += 1

                        #Parse out sequence
                        elif line.startswith('Sbjct'):
                            lnsplit=line.split()[0:3]
                            seq=lnsplit[2]
                            seq=seq.replace('-','')
                            seq=seq.strip('\n')
                            #print (match + eval + '~'  +  seq + '\n')
                            f.write( match + eval + '~'  +  seq + '\n')

                        elif 'No hits' in line:
                            f.write('No hits')                              
                                
        main()

#~~~~~~~~~~~~~~~~~~~~~~~~~~GENERATEREPORT~~~~~~~~~~~~~~~~~~~~~~~~~~~~  

rule generateReport: #Generates a Report of all files seen, which files did or did not meet threshold requirement, and their counts
    input: expand(["{genomesdb}_parsed.fa"], genomesdb=GENOMESDB)
    output: "%s_Files_Generated_Report.txt" %end
    run:
        def main():
            #Files and Varibles
            a = 0 
            thresh = config['threshold']
            reportOut = output[0]
            ThreshHitCount = 0
            threshNOHitCnt = 0
            totalFileCount = 0
            totalfilesUsed = 0
            Threshkey = {}
            NoHitThresh = ['|Key|------------------ Rejected ----------------------||------------------------ Accepted ----------------------']
            HitThresh = ['|']
            
            #Opens Tresh.txt file to view user input        
            ln = thresh
            ln = float(ln)
            ln = ('% e' % ln)
            
            keys = ln
            Threshkey=[keys]

            #Open writable file (Report.txt)
            with open(reportOut, 'w') as rp:

                #Create varibles and print headder for file
                ln = ''
                NNL = 'N/L : Sequence Length Did Not Meet % Of Query Length Requirement'
                NNH = 'N/H : E-Value Did Not Meet Threshold Requirments'
                NNA = 'N/A : No Hits Were Found In This Genome'
                ENS = '@- : Sequence Is From Ensembl Database'
                sep = '--------------------------------------------------------------------------------------------------------------'

                header = ('Summary Of Sequences Against Applied Requirements:' + '\n' + sep) 
                rp.write(header)

                keycodes = ('\n' + 'Key:' + '\n' + '\t' + NNL + '\n' + '\t' + NNH + '\n' + '\t' + NNA + '\n' + ENS + '\n' + sep +'\n')
                rp.write(keycodes)

                #Loop through files in input 
                while a < len(input): 
                    file = input[a]
                    a+=1 
                    totalfilesUsed +=1
    
                    #Open our file
                    with open(file, 'r') as fp:
                        qLength = 0
                        for line in fp:
                            
                            #Converting evalues of file to check if its a hit file or not                             
                            if 'YExpect' in line and '>' in line:
                                qLength+=1
                            
                                expect1 = line.split('Y')[1]
                                expect = expect1.split('~')[0]
                                valueOnly = expect.split('= ')[1]
                                valOne = float(valueOnly)
                                evalue = ('%e' % valOne)
                                seqname=expect1.split('>')[1]
                                seqname = seqname[:9]
				fnam = str(fp.name)
                            
                                #Converting line to float value for comparison check 
                                if valueOnly in line:           
                                    valOne = float(valueOnly)
                                    evalue = ('% e' % valOne)
                                    
                                    #Comparing values to see if hit or not
                                    for var in Threshkey:

                                        evalue = float(evalue)
                                        var = float(var)
                                        
                                        #If the file does not meet threshold requirmen, strip name and add name to NO HITS list, + add 1 to counters
                                        if evalue > var:
                                            seqname=seqname
                                            fname = ''

                                            #If files are from VGP print file:
                                            if '-unmasked' in fp.name:
                                                fname = (str(fp.name).rsplit('-unmasked')[0])

                                            #If files are from ensemble print files with #:  
                                            else:
                                                fnam = (str(fp.name).rsplit('.dna.')[0])
                                                fname = '@-' + fnam

                                            #Increases count and stores filenames
                                            NoHitThresh.append('N/H | ' + seqname + str(qLength) + ': ' + fname)
                                            threshNOHitCnt +=1
                                            totalFileCount +=1

                                        #If the file meets threshold requirment, strip name and add name to HITS list, + add 1 to counters                                                                                                   
                                        else:
                                            fname = ''
                                            seqname = seqname

                                            #If files are from VGP print file:
                                            if '-unmasked' in fp.name:
                                                fname = (str(fp.name).rsplit('-unmasked')[0])

                                            #If files are from ensemble print files with #: 
                                            else:
                                                fnam = (str(fp.name).rsplit('.dna.')[0])
                                                fname='@-'+fnam
                                            
                                            #Increases count and stores filenames
                                            HitThresh.append(seqname +  str(qLength) + ': '  + fname )
                                            ThreshHitCount +=1
                                            totalFileCount  +=1

                            elif 'NExpect' in line and '>' in line:
                                qLength+=1
                                expect1 = line.split('N')[1]
                                seqname=expect1.split('>')[1]
                                seqname = seqname[:9]
				fnam = str(fp.name)

                                if '-unmasked' in fp.name:
                                    fname = (str(fp.name).rsplit('-unmasked')[0])

                                #If files are from ensemble print files with #:  
                                else:
                                    fnam = (str(fp.name).rsplit('.dna.')[0])
                                    fname = '@-' + fnam

                                #Increases count and stores filenames
                                NoHitThresh.append('N/L | ' + seqname + str(qLength) + ': '+  fname)
                                threshNOHitCnt +=1
                                totalFileCount +=1
                            
                            #If files have 0 possible hits, or 'No Hits', strip name, add '**' in front of filename, and add name to NO HITS list, + add 1 to counters 
                            elif 'No hits' in line:
                                   
                                #If files are from VGP print file:
                                if '-unmasked' in fp.name:
                                    fname = (str(fp.name).rsplit('-unmasked')[0])
                                    
                                #If files are from ensemble print files with #:     
                                else:
				    fnam= str(fp.name)
				    fnam = (str(fp.name).rsplit('.dna.')[0])
                                    fname ='@-' + fnam

                                #Adds ** to no hit files and increases count and stores filenames
                                fname = 'N/A | ' + fname
                                NoHitThresh.append(fname)
                                threshNOHitCnt +=1
                                totalFileCount +=1
                ###############################################################                     
                #Renaming varibles for printing
                tnhc = str(threshNOHitCnt) 
                thc = str(ThreshHitCount)
                tc = str(totalFileCount)
                tt = str(totalfilesUsed)
                
                ###############################################################
                #Naming and aligning files for printing            
                ln = ''
                space = '                                                  '
                Nohit = str(NoHitThresh[0]) + space
                Hit = str(HitThresh[0]) + space
                
                ###############################################################
                #Formmating ln for writing out to file
                a = '\t'+ str(Threshkey) + ': Threshold Value Used' + '\n'
                b = '\t' + tt + ': Total # of Files' + '\n'
                c = '\t' + tc + ': Total # Of Sequences Found' + '\n'
                d = '\t' + tnhc + ': Total # Of Rejected Sequences Found' + '\n'
                e = '\t' + thc + ': Total # Of Accepted Sequences Found' + '\n'
                
                ln = a + b + c + d + e
                rp.write(ln)
                ################################################################
                #Writes first element of lists in file
                printthis = Nohit + Hit + '\n'
                rp.write(printthis)

                ################################################################
                #New line For Hit Thresh    
                if len(HitThresh) > len(NoHitThresh) and len(HitThresh) > 1 :
                    x = 1

                    while x < len(HitThresh):
                        
                        #Formatting lines 
                        if x >= len(NoHitThresh):
                            #space = 'Odocoileus_virginianus_texanus-GCA_002102435.1' added to 50 charaters
                            ln = '' 
                            space = '                                                  '
                            Hit = str(HitThresh[x]) + space
                            Hit = Hit[:55]
                            #Final line for printing
                            ln = (space + '\t' + Hit + '\n')
                        
                        else:
                            ln = ''
                            space = '                                                  '
                            Nohit = str(NoHitThresh[x]) + space
                            Nohit = Nohit[:54] + '|'
                            Hit = str(HitThresh[x]) + space
                            Hit = Hit[:55]
                            #Final line for printing
                            ln =  (Nohit + '\t' + Hit + '\n')

                        #Illeterates and writes lines
                        x += 1 
                        rp.write(ln)      
                
                #New line For No Hit Thresh                
                if len(NoHitThresh) > len(HitThresh) and len(NoHitThresh) > 1 :
                    x = 1

                    while x < len(NoHitThresh):                   
                        #Formating lines
                        if x >= len(HitThresh):
                            ln = ' ' 
                            space = '                                                  '
                            Nohit = str(NoHitThresh[x]) + space
                            Nohit = Nohit[:54] + ' |'
                            #Final line for printing
                            ln = (Nohit + '\n' )
                                
                        else:                          
                            ln=''
                            space = '                                                  '
                            Nohit = str(NoHitThresh[x]) + space
                            Nohit = Nohit[:54] + ' |'
                            Hit = str(HitThresh[x]) + space
                            Hit = Hit[:55]
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
                            Nohit = Nohit[:54] + ' |'
                            Hit = str(HitThresh[x]) + space
                            Hit = Hit[:55]
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
                head = ('Name Key Doc:' + '\n'+ '@-' + ' = Genome is from Ensemble' + '\n')
                f.write(head +'ID' + '\t'+ '\t' + 'FileName')
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
                                    fname = fname.split('_parsed')[0]         
                                    f.write(id + '\t' + fname +'\n') 

                                #Adds # in front of all files from ensemble and strips ID                  
                                else:
                                    fnam = str(fp.name)
                                    fname = fname.split('_parsed')[0] 
                                    fname = '@-'+fnam                  
                                    f.write(id + '\t' + fname +'\n')

        main()    

#~~~~~~~~~~~~~~~~~~~~~~~~~~MULTI SEQ ALIGN~~~~~~~~~~~~~~~~~~~~~~~~~~~

rule muscle: # Runs a simple multi-sequence alignment on all parsed out files
    input:  "%s_Parsed_Final.fa" %end 
    output: "%s_Multi_Seq_Align.aln" %end 
    shell: """ /opt/conda/bin/muscle -in {input[0]} -fastaout {output[0]}  """

rule muscle2: # Runs a simple multi-sequence alignment on all parsed out files in PHYLIP formatting
    input: "%s_Multi_Seq_Align.aln" %end 
    output: "%s_Phy_Align.phy" %end
    shell: """ /opt/conda/bin/muscle -in {input[0]} -phyiout {output[0]}  """

#~~~~~~~~~~~~~~~~~~~~~~~~~~MSA2GFA~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rule MSA2GFA: # Converts the multi-sequence alignment into a FGA format
    input: "%s_Multi_Seq_Align.aln" %end 
    output:  "%s_MSA2GFA.gfa" %end 
    shell:""" python msa_to_gfa/msa_to_gfa/main.py -f {input[0]} -o {output[0]} --log MSA2GFA.log"""

#~~~~~~~~~~~~~~~~~~~~~~~~~~RAXML~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rule raxml: #Converts the Phylips file alignment to generate a RAXML phylogenic tree
    input: "%s_Phy_Align.phy" %end
    output:temp("RAxML_bootstrap.RAXML_output.phy"), temp("RAxML_bestTree.RAXML_output.phy"), temp("RAxML_bipartitionsBranchLabels.RAXML_output.phy"),temp("RAxML_bipartitions.RAXML_output.phy"), temp("RAxML_info.RAXML_output.phy")
    params: prefix= "RAXML_output.phy"
    threads: 4
    shell: """ /opt/conda/bin/raxmlHPC-PTHREADS-SSE3 -m GTRGAMMA -f a -x 100 -p 100 -s {input[0]} -# 100 -n {params.prefix} -T 4  """
rule cleanRAxML: #Renames RAXML output and moves it to output folder
    input:  "RAxML_bootstrap.RAXML_output.phy" , "RAxML_bestTree.RAXML_output.phy", "RAxML_bipartitionsBranchLabels.RAXML_output.phy", "RAxML_bipartitions.RAXML_output.phy", "RAxML_info.RAXML_output.phy"
    output:   "%s_RAxML_bootstrap.phy" %end , "%s_RAxML_bestTree.phy" %end, "%s_RAxML_bipartitionsBranchLabels.phy" %end, "%s_RAxML_bipartition.phy" %end, "%s_RAxML_info.log" %end
    shell: """ cat {input[0]} >> {output[0]} && cat {input[1]} >> {output[1]} && cat {input[2]} >> {output[2]} && cat {input[3]} >> {output[3]} && cat {input[4]} >> {output[4]} """

#~~~~~~~~~~~~~~~~~~~~~~~~~~END SCRIPT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
#-------------------------------------------------------------------#
############################DIRECTORY CLEAN UP#######################
rule Move: #Renames and moves all generated blast files
    input: "{genomesdb}_blast_results.txt"
    output: "%s_{genomesdb}_blast_results.txt" %mid
    shell: """ cat {input[0]} >> {output[0]} """

#####################################################################
rule Delete: #Deletes any miscellaneous files
    input:  expand(["{genomesdb}_parsed_Final.fa"], genomesdb=GENOMESDB)
    output: temp("DONE.txt")
    shell: """ rm *_blast_results.txt && rm *_parsed_Final.fa && rm *_results_test_2.txt && rm *_parsed.fa && touch {output[0]}"""
