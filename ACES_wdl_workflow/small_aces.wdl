version 1.0

workflow aces {
    input {
    String pathToInput
    Int?  max_num_seq
    File query
    File samples_file
    Float eval
    Float threshold
    Int? msa_threads
    Int? msa_ram
    File datadb

    }
    Array[String] samples = read_lines(samples_file)
    #Runs the BLASTn in parallel
    scatter (sam in samples){
        call grabinput{
            input:
                pathToInput=pathToInput,
                sample=sam,
                datadb=datadb
                
        }
        
        Array[String] hello=read_lines(grabinput.databaseFile)
        Array[File] databaseFiles=hello
        
        call BLAST {
        input:
            pathToInput=pathToInput,
            max_num_seq=max_num_seq,
            query=query,
            eval=eval,
            sample=sam,
            databaseFiles=databaseFiles
        }
        
    }
    #Creates threshold document
    call findThresh
    {
        input:
        	query=query,
            parse_out=BLAST.parsed,
            threshold=threshold,
            eval=eval,
            numBLASTOut=max_num_seq
    }        
    #Creates report document
    call generateReport {
        input:
        	query=query,
            parse_out=BLAST.parsed,
            threshold=threshold,
            eval=eval
    }

    #Runs muscle alignment and then RAxML after
    call MSA {
        input:
            thresh_out=findThresh.out_small,
            thresh_query=findThresh.small_query,
            msa_ram=msa_ram,
            msa_threads=msa_threads

           
    }
}

task grabinput{
    input {
        String pathToInput
        String sample
        File datadb
    }
    
    command<<<
    
    grep ~{sample} ~{datadb} | awk '{printf "~{pathToInput}/%s\n",$1}' > ~{sample}.files.txt
    >>>
    output {
        File databaseFile="~{sample}.files.txt"
    }
    runtime {
        docker: "ncbi/blast:latest"
        memory: "1GB"
        cpu: 1
        disks: "local-disk 1 SSD"
    }
}
task BLAST {
    input {
        String pathToInput
        String sample
        Int? max_num_seq
        File query
        Float eval
        Array[File] databaseFiles
         
    }
	Int disk_size = ceil(size(databaseFiles,"GB")+5)
    String pathway=sub(pathToInput,'gs://','')+'/'+sample
    Int bout=select_first([max_num_seq, 1])
    command <<<
    echo ~{pathway}
    export PATH=/blast/bin:$PATH
    blastn -task dc-megablast -evalue ~{eval} -max_target_seqs ~{bout} -query ~{query} -db ~{pathway} -max_hsps ~{bout} -outfmt '6 sseqid sseq evalue' > ~{sample}_blast_results.txt
    cat ~{sample}_blast_results.txt | awk '{printf ">~{sample}_eval%s\n%s\n",$3,$2}' > ~{sample}_parsed.fa
    >>>
    output {
        File out="~{sample}_blast_results.txt"
        File parsed="~{sample}_parsed.fa"
    }
    runtime {
        docker: "ncbi/blast:latest"
        memory: "16GB"
        cpu: 1
        disks: "local-disk "+disk_size+" SSD"
    }

}
task findThresh {
    input {
        Array[File] parse_out
        Float threshold
        File query
        Float eval
        Int? numBLASTOut

    }
    Int bout=select_first([numBLASTOut, 1])
    Int disk_size = ceil(size(parse_out,"GB")+5)
    command <<<
    export PATH=/opt/conda/bin:$PATH
    python /scripts/find_thresh_and_key.py -f ~{sep=',' parse_out} -t ~{eval} -o Parsed_Final.fa -q ~{query} -l ~{threshold} -b ~{bout}
    >>>
    output {
        File out="Parsed_Final.fa"
        File out_small="Parsed_Final.fa_smallname.fa"
        File small_query="small_query.fa"
        File key="Keydoc.txt"
    }
    runtime {
        docker: "jng2/testme:aces"
        memory: "2GB"
        cpu: 1
        disks:  "local-disk "+disk_size+" SSD"
    }
}
task generateReport {
    input {
        Array[File] parse_out
        Float threshold
        File query
        Float eval
    }

   
    Int disk_size = ceil(size(parse_out,"GB")+5)
    command <<<
    export PATH=/opt/conda/bin:$PATH
    python /scripts/generateReport_blastparse.py -f ~{sep=',' parse_out} -t ~{eval} -o Files_Generated_Report.txt -q ~{query} -l ~{threshold}
    >>>
    output {
        File out="Files_Generated_Report.txt"
    }
    runtime {
        docker: "jng2/testme:aces"
        memory: "2GB"
        cpu: 1
        disks: "local-disk "+disk_size+" SSD"
    }

}

task MSA {
    input {
        File thresh_out
        File thresh_query

        Int? msa_threads
        Int? msa_ram
        
    }

    Int disk_size = ceil(size(thresh_out,"GB")+size(thresh_query,"GB")+10)
    Int num_t=select_first([msa_threads, 4])
    Int num_m=select_first([msa_ram,16])
    
    command <<<
    export PATH=/opt/conda/bin:$PATH
    
   

    muscle -in ~{thresh_out} -fastaout temp.aln 
    muscle -profile -in1 ~{thresh_query}  -in2 temp.aln  -out Multi_Seq_Align.aln
    muscle -in Multi_Seq_Align.aln -phyiout Phy_Align.phy
    python /ACES/ACES_Pipeline/msa_to_gfa/msa_to_gfa/main.py -f Multi_Seq_Align.aln -o MSA2GFA.gfa --log MSA2GFA.log
    
    raxmlHPC-PTHREADS-SSE3 -m GTRGAMMA -f a -x 100 -p 100 -s Phy_Align.phy -# 100 -n RAXML_output -T ~{num_t}  

    >>>
    output {
        File gfa="MSA2GFA.gfa"
        File phy="Phy_Align.phy"
        File msa="Multi_Seq_Align.aln"
        File tree="RAxML_bestTree.RAXML_output"
        File bipartitions="RAxML_bipartitions.RAXML_output"
        File bipartitionsBranchLabels="RAxML_bipartitionsBranchLabels.RAXML_output"
        File bootstrap="RAxML_bootstrap.RAXML_output"
        File info="RAxML_info.RAXML_output"
    }
    runtime {
        docker: "jng2/testme:aces"
        memory: num_m+"GB"
        cpu: num_t
        disks: "local-disk "+disk_size+" SSD"
    }

}
