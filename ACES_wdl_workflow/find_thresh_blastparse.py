import argparse
from typing import Sequence


# def keyDoc(file,writer,smallname):
#     with open(file) as input:
#         fname = input.name.split('/')[-1]
#         fname = fname.split('_parsed')[0]         
        
#         for line in input:
#             if '>' in line:
               
#                 if '-unmasked' in input.name:
                    
#                     writer.write(smallname + '\t' + fname +'\n') 

                 
#                 else:
#                     fname = '@-'+fname                  
#                     writer.write(writer + '\t' + fname +'\n')

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
def findThresh(out,file,threshold,lthresh,holdname,out_small):
    #print(holdname[1][0])
    compareMe=[]
    with open(file, 'r') as fp:
        #print(file)
        for line in fp:
            #print(line)
            if line.startswith('>'):
                #print(line)
                name=findName(file)[0:10]
               # print(name,'name')
                #print(holdname)
                if name not in holdname:
                    smallname=name[0:10]
                    holdname.append(name)
                else:
                    smallname=str(holdname[1][0])+name
                    smallname=smallname[0:10]
                    holdname.append(smallname)
                    holdname[1][0]+=1
                #print(smallname,'smallname')
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
        for thing in compareMe:
           # print(thing[0],test,type(thing[0]))
            if thing[0]<test:
                #print(thing[0],test,type(thing[0]),'in the if')
                printMe=thing[1]
                file=thing[2]
                seqactual=thing[3]
                test=thing[0]
        out.write('>'+printMe+'_fullname_'+file+'\n')
        out.write(seqactual.replace('-',''))
        #print('>'+printMe)
        out_small.write('>'+printMe+'\n')
        out_small.write(seqactual.replace('-',''))
                        #keyDoc(file,keywriter,smallname)
                        #counter+=1
            #print('loop end')
        #return counter
        #Converting evalues of file to check if its a hit file or not based on Y or N for meeting query length
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
    args = parser.parse_args()
    files=args.files.split(',')
    with open(args.query) as q:
        for line in q:
            if not line.startswith('>'):
                qlength=len(line.strip())
    merp=qlength*float(args.length)
    holdname=[[],[0]]
    #counter=0

    threshold=float(('% e' % float(args.threshold)).strip())
    #with open("Keydoc.txt",'w') as keywriter:
    #head = ('Name Key Doc:' + '\n'+ '@-' + ' = Genome is from Ensemble' + '\n')
   # keywriter.write(head +'ID' + '\t'+ '\t' + 'FileName\n')
    with open(args.output_name+'_smallname.fa','w') as out_small:
        with open(args.output_name,'w') as out:
            for file in files:
                    
                    
                    findThresh(out,file,threshold,merp,holdname,out_small) 
    querycheck(args.query, holdname)
main()