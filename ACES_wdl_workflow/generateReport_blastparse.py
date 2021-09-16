import argparse
import os
def makePrint(t,NohitT,HitT,x):
    space = '                                                  '
    if t==0: 
        Hit = str(HitT[x]) + space
        Hit = Hit[:55]
        return space + '\t' + Hit + '\n'
    elif t==1:
        Nohit = str(NohitT[x]) + space
        Nohit = Nohit[:54] + ' |'
        return Nohit + '\n' 
    else:
        Nohit = str(NohitT[x]) + space
        Nohit = Nohit[:54] + ' |'
        Hit = str(HitT[x]) + space
        Hit = Hit[:55]
        return  Nohit+ '\t' + Hit + '\n'
def generateReport(out,files,threshold,lthresh,threshHitCount,threshNOHitCnt,totalFileCount,totalfilesUsed,NoHitThresh,HitThresh):
    a = 0 
    for file in files:
        totalfilesUsed +=1
        if '-unmasked' in file:
            fname = (file.split('/')[-1].rsplit('-unmasked')[0])                
        else:
            fnam = (file.split('/')[-1].rsplit('.dna.')[0])
            fname = '@-' + fnam
        print(fname)    
        if os.path.getsize(file)==0:
            fname = 'N/A | ' + fname
            NoHitThresh.append(fname)
            threshNOHitCnt +=1
            totalFileCount +=1  
        else:  
            with open(file, 'r') as fp:
                qLength = 0 
                for line in fp:
                    if line.startswith('>'):
                        seqname=line.strip().split('_eval')[0]
                        eval=float(line.strip().split('_eval')[1])
                        seq=fp.readline()
                        length=len(seq)
                        print(file,length,lthresh)
                        if lthresh<=length:
                            qLength+=1
                            
                            if eval > threshold:   
                            #Increases count and stores filenames
                                NoHitThresh.append('N/H | ' + seqname + str(qLength) + ': ' + fname)
                                threshNOHitCnt +=1
                                totalFileCount +=1
                        #If the file meets threshold requirment, strip name and add name to HITS list, + add 1 to counters                                                                                                   
                            else:
                                #Increases count and stores filenames
                                HitThresh.append(seqname +  str(qLength) + ': '  + fname )
                                threshHitCount +=1
                                totalFileCount  +=1
                    
                        elif lthresh>length:
                            qLength+=1
                            #Increases count and stores filenames
                            NoHitThresh.append('N/L | ' + seqname + str(qLength) + ': '+  fname)
                            threshNOHitCnt +=1
                            totalFileCount +=1                
                    #If files have 0 possible hits, or 'No Hits', strip name, add '**' in front of filename, and add name to NO HITS list, + add 1 to counters 
              
        ###############################################################
        #Formmating ln for writing out to file
    a = '\t'+ str(threshold) + ': Threshold Value Used' + '\n'
    b = '\t' + str(totalfilesUsed) + ': Total # of Files' + '\n'
    c = '\t' + str(totalFileCount) + ': Total # Of Sequences Found' + '\n'
    d = '\t' + str(threshNOHitCnt)  + ': Total # Of Rejected Sequences Found' + '\n'
    e = '\t' + str(threshHitCount) + ': Total # Of Accepted Sequences Found' + '\n'   
    ln = a + b + c + d + e
    out.write(ln)
    #New line For Hit Thresh    
    if len(HitThresh) > len(NoHitThresh) and len(HitThresh) > 1 :
        
        x = 1
        while x < len(HitThresh):            
            #Formatting lines 
            if x >= len(NoHitThresh):
                #space = 'Odocoileus_virginianus_texanus-GCA_002102435.1' added to 50 charaters
                out.write(makePrint(0,NoHitThresh,HitThresh,x))            
            else:
                out.write(makePrint(2,NoHitThresh,HitThresh,x))
            #Illeterates and writes lines
            x += 1   
    #New line For No Hit Thresh                
    if len(NoHitThresh) > len(HitThresh) and len(NoHitThresh) > 1 :
        x = 1
        while x < len(NoHitThresh):                   
            #Formating lines
            if x >= len(HitThresh):
                #print(x,NoHitThresh,HitThresh)
                out.write(makePrint(1,NoHitThresh,HitThresh,x))                    
            else:                          
                out.write(makePrint(2,NoHitThresh,HitThresh,x))
            #Illeterates and writes lines
            x += 1     
    if len(NoHitThresh) == len(HitThresh) and len(HitThresh) > 0 and len(NoHitThresh) > 0:
        x = 1 

        while x < len(NoHitThresh): 

            if x <= len(HitThresh):

                out.write(makePrint(2,NoHitThresh,HitThresh,x))

            #Illeterates and writes lines
            x += 1 
    #Close the files     
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f','--files',help='Comma delimited list of files from blast',type=str)
    parser.add_argument('-t','--threshold', help='Threshold value')
    parser.add_argument('-o','--output_name',help='Output name')
    parser.add_argument('-l','--length',help='Minimum sequence length')
    parser.add_argument('-q','--query',help='Query file')
    args = parser.parse_args()
    files=args.files.split(',')
    #print(files)
    threshold=float(('% e' % float(args.threshold)).strip())
    threshHitCount = 0
    threshNOHitCnt = 0
    totalFileCount = 0
    totalfilesUsed = 0
    with open(args.query) as q:
        for line in q:
            if not line.startswith('>'):
                qlength=len(line.strip())
    print(qlength)
    merp=qlength*float(args.length)
    with open(args.output_name,'w') as out:
        NoHitThresh = ['|Key|------------------ Rejected ----------------------||------------------------ Accepted ----------------------']
        HitThresh = ['|'] 
        NNL = 'N/L : Sequence Length Did Not Meet % Of Query Length Requirement'
        NNH = 'N/H : E-Value Did Not Meet Threshold Requirements'
        NNA = 'N/A : No Hits Were Found In This Genome'
        ENS = '@- : Sequence Is NOT From VGP Database'
        sep = '--------------------------------------------------------------------------------------------------------------'
        out.write('Summary Of Sequences Against Applied Requirements:' + '\n' + sep) 
        keycodes = ('\n' + 'Key:' + '\n' + '\t' + NNL + '\n' + '\t' + NNH + '\n' + '\t' + NNA + '\n' + ENS + '\n' + sep +'\n')
        out.write(keycodes)
        out.write(str(NoHitThresh[0]) + '                                                  ' + str(HitThresh[0]) + '                                                  ' + '\n')

        #for file in files:
        generateReport(out,files,threshold,merp,threshHitCount,threshNOHitCnt,totalFileCount,totalfilesUsed,NoHitThresh,HitThresh) 
main()