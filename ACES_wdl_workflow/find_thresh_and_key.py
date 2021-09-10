import argparse

#Writes out what file the small names corresponds to
def keyDoc(file,writer,smallname):
    
    fname = file.split('/')[-1]
    fname = fname.split('_parsed')[0]                 
    if '-unmasked' in fname:
        writer.write(smallname + '\t' + fname +'\n')         
    else:
        fname = '@-'+fname                  
        writer.write(smallname + '\t' + fname +'\n')


#Split name of file
def findName(file):
    file=file.strip().split('/')[-1]
    if file.find('-GCA') and file.find('.dna.'):
        if file.find('-GCA') > file.find('.dna.'):
            return(file.strip().split('.dna')[0])
        else:
            return(file.strip().split('-GCA')[0])
    elif file.find('-GCA'):
        return(file.strip().split('-GCA')[0])
    elif file.find('.dna.'):
        return(file.strip().split('.dna')[0])

#Checks the input from BLAST and determines if it passes the threshold check.  Will write out files for MSA step of the wdl
def findThresh(out,file,threshold,lthresh,holdname,out_small,keywriter,blastlimit):
    compareMe=[]
    with open(file, 'r') as fp:
        for line in fp:
            if line.startswith('>'):
                name=findName(file)[0:10]
                if name not in holdname:
                    smallname=name[0:10]
                    holdname.append(name)
                else:
                    smallname=str(holdname[1][0])+name
                    smallname=smallname[0:10]
                    holdname.append(smallname)
                    holdname[1][0]+=1
                eval=float(line.strip().split('_eval')[1])
                seq=fp.readline()
                length=len(seq)
                if lthresh<=length:
                    if eval > threshold:
                        pass
                    else:
                        compareMe.append([eval,smallname,file,seq])
    test=10000000
    if compareMe!=[]:
        outputMe=[]
        for thing in compareMe:
            if blastlimit > len(outputMe) or test>thing[0]:
                outputMe.append(thing)
                test=thing[0]
            elif blastlimit==len(outputMe):
                i=0
                while i < len(outputMe):
                    if outputMe[i][0] > thing[0]:
                        outputMe[i]=thing
                    i+=1

        for thing in outputMe:
                 
            out.write('>'+thing[1]+'_fullname_'+thing[2].split('/')[-1]+'\n')
            out.write(thing[3].replace('-',''))
            print('>'+thing[1])
            out_small.write('>'+thing[1]+'\n')
            out_small.write(thing[3].replace('-',''))
            keyDoc(thing[2].split('/')[-1],keywriter,thing[1])
#Determines in the name of the query is less than 10 characters, and if not, makes it so.                   
def querycheck(query,holdname):
    
    with open('small_query.fa','w') as out:
        with open(query) as input:
            for line in input:
                if line.startswith('>'):
                    name=line.strip().split('>')[1]
                    if len(name)>10:
                        if name not in holdname:
                            out.write('>'+name[0:10]+'\n')
                        else:
                            small=str(holdname[1][0])+name

                            out.write('>'+small[0:10]+'\n')
                            holdname[1][0]+=1
                            holdname.append(small[0:10])
                    else:
                        out.write(line)
                else:
                    out.write(line)
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f','--files',help='Comma delimited list of files from blast',type=str)
    parser.add_argument('-t','--threshold', help='Threshold value')
    parser.add_argument('-o','--output_name',help='Output name')
    parser.add_argument('-l','--length',help='Minimum sequence length')
    parser.add_argument('-q','--query',help='Query file')
    parser.add_argument('-b','--blast_output',help='Number of BLAST output')
    args = parser.parse_args()
    files=args.files.split(',')
    with open(args.query) as q:
        for line in q:
            if not line.startswith('>'):
                qlength=len(line.strip())
    merp=qlength*float(args.length)
    holdname=[[],[0]]
    threshold=float(('% e' % float(args.threshold)).strip())
    with open("Keydoc.txt",'w') as keywriter:
        head = ('Name Key Doc:' + '\n'+ '@-' + ' = Genome is from Ensemble' + '\n')
        keywriter.write(head +'ID' + '\t'+ '\t' + 'FileName\n')
        with open(args.output_name+'_smallname.fa','w') as out_small:
            with open(args.output_name,'w') as out:
                for file in files:
                    
                    
                   findThresh(out,file,threshold,merp,holdname,out_small,keywriter,int(args.blast_output)) 
    querycheck(args.query, holdname)
main()