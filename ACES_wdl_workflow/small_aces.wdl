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
    String? query_loc
    Int? culling_limit
    Float? best_hit_overhang
    Float? best_hit_score_edge
    Int? dbsize
    Int? searchsp
    Array[File]? filtering_db
    String? filtering_db_path
    File? import_search_strategy
    String? export_search_strategy
    String? parse_deflines
    Int? num_threads_blast
    Int? mt_mode
    String? show_gis
    Int? max_hsps
    Int? blast_ram
    Int? word_size
    Int? gapopen
    Int? gapextend
    Int? reward
    Int? penalty
    String? strand
    String? dust
    String? soft_masking
    String? lcase_masking
    Int? perc_identity
    String? template_type
    Int? template_length
    Int? xdrop_ungap
    Int? xdrop_gap
    Int? xdrop_gap_final
    Int? min_raw_gapped_score
    String? ungapped 
    Int? window_size
    String? raxmlHPC_model_type
    Int? num_bootstraps
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
            databaseFiles=databaseFiles,
            query_loc= query_loc,
            show_gis=show_gis,
            culling_limit= culling_limit,
            best_hit_overhang = best_hit_overhang,
            best_hit_score_edge= best_hit_score_edge,
            dbsize= dbsize,
            searchsp= searchsp,
            filtering_db=filtering_db,
            filtering_db_path=filtering_db_path,
            import_search_strategy = import_search_strategy,
            export_search_strategy = export_search_strategy,
            parse_deflines = parse_deflines,
            num_threads_blast = num_threads_blast,
            mt_mode = mt_mode,
            max_hsps=max_hsps,
            blast_ram=blast_ram,
            word_size= word_size,
            gapopen= gapopen,
            gapextend =gapextend,
            reward= reward,
            penalty= penalty,
            strand= strand,
            dust= dust,
            soft_masking= soft_masking,
            lcase_masking= lcase_masking,
            perc_identity= perc_identity,
            template_type= template_type,
            template_length= template_length,
            xdrop_ungap= xdrop_ungap,
            xdrop_gap= xdrop_gap,
            xdrop_gap_final= xdrop_gap_final,
            min_raw_gapped_score= min_raw_gapped_score,
            ungapped= ungapped,
            window_size= window_size


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
            msa_threads=msa_threads,
            num_bootstraps=num_bootstraps,
            raxmlHPC_model_type=raxmlHPC_model_type

           
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
        docker: "tnturnerlab/vgp_ens_pipeline:wdl"
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
        String? query_loc
        Int? culling_limit
        Float? best_hit_overhang
        Float? best_hit_score_edge
        Int? dbsize
        Int? searchsp
        File? import_search_strategy
        String? export_search_strategy
        String? parse_deflines
        Int? num_threads_blast
        Int? mt_mode
        String? show_gis
        Int? max_hsps
        Int? blast_ram 
        Int? word_size
        Int? gapopen
        Int? gapextend
        Int? reward
        Int? penalty
        String? strand
        String? dust
        String? soft_masking
        String? lcase_masking
        Int? perc_identity
        String? template_type
        Int? template_length
        Int? xdrop_ungap
        Int? xdrop_gap
        Int? xdrop_gap_final
        Int? min_raw_gapped_score
        String? ungapped 
        Int? window_size    
        Array[File]? filtering_db
        String? filtering_db_path

         
    }
	Int disk_size = ceil(size(databaseFiles,"GB")+5)
    String pathway=sub(pathToInput,'gs://','')+'/'+sample
    Int bout=select_first([max_num_seq, 1])
    Int num_t=select_first([num_threads_blast, 1])
    Int num_m=select_first([blast_ram,16])
    command <<<
    echo ~{pathway}
    export PATH=/blast/bin:$PATH
    blastn -task dc-megablast -evalue ~{eval} -max_target_seqs ~{bout} -query ~{query} -db ~{pathway} ~{"-max_hsps "+max_hsps} ~{"-"+show_gis} ~{"-query_loc "+query_loc}  ~{"-culling_limit "+culling_limit} ~{"-best_hit_overhang "+best_hit_overhang} ~{"-best_hit_score_edge "+best_hit_score_edge} ~{"-dbsize "+dbsize} ~{"-import_search_strategy "+import_search_strategy}  ~{"-searchsp "+ searchsp} ~{"-"+ parse_deflines} ~{"-export_search_strategy "+export_search_strategy} ~{"-num_threads "+num_threads_blast} ~{"-mt_mode "+mt_mode} ~{"-word_size "+word_size}  ~{"-gapopen "+gapopen} ~{"-gapextend "+gapextend} ~{"-reward "+reward} ~{"-penalty "+penalty} ~{"-strand "+strand} ~{"-dust '"+dust+"'"}  ~{"-soft_masking "+soft_masking} ~{"-"+lcase_masking} ~{"-perc_identity "+perc_identity} ~{"-template_type "+template_type} ~{"-template_length "+template_length} ~{"-xdrop_ungap "+xdrop_ungap} ~{"-xdrop_gap_final "+xdrop_gap_final}    ~{"-min_raw_gapped_score "+min_raw_gapped_score}  ~{"-"+ungapped} ~{"-window_size "+window_size} ~{"-xdrop_gap "+xdrop_gap} ~{"-filtering_db "+filtering_db_path} -outfmt '6 sseqid sseq evalue' > ~{sample}_blast_results.txt
    cat ~{sample}_blast_results.txt | awk '{printf ">~{sample}_eval%s\n%s\n",$3,$2}' > ~{sample}_parsed.fa
    >>>
    output {
        File out="~{sample}_blast_results.txt"
        File parsed="~{sample}_parsed.fa"
        Array[File] export=glob("{~{export_search_strategy}")
    
    }
    runtime {
        docker: "ncbi/blast:latest"
        memory: num_m+"GB"
        cpu: num_t
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
        docker: "tnturnerlab/vgp_ens_pipeline:wdl"
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
        docker: "tnturnerlab/vgp_ens_pipeline:wdl"
        memory: "2GB"
        cpu: 1
        disks: "local-disk "+disk_size+" SSD"
    }

}

task MSA {
    input {
        File thresh_out
        File thresh_query
        String? raxmlHPC_model_type
        Int? num_bootstraps
        Int? msa_threads
        Int? msa_ram
        
    }

    Int disk_size = ceil(size(thresh_out,"GB")+size(thresh_query,"GB")+10)
    Int num_t=select_first([msa_threads, 4])
    Int num_m=select_first([msa_ram,16])
    String model=select_first([raxmlHPC_model_type,'GTRGAMMA'])
    Int num_boot=select_first([num_bootstraps,100])
    
    command <<<
    export PATH=/opt/conda/bin:$PATH
    
   

    muscle -in ~{thresh_out} -fastaout temp.aln 
    muscle -profile -in1 ~{thresh_query}  -in2 temp.aln  -out Multi_Seq_Align.aln
    muscle -in Multi_Seq_Align.aln -phyiout Phy_Align.phy
    python /ACES/ACES_Pipeline/msa_to_gfa/msa_to_gfa/main.py -f Multi_Seq_Align.aln -o MSA2GFA.gfa --log MSA2GFA.log
    
    raxmlHPC-PTHREADS-SSE3 -m ~{model} -f a -x 100 -p 100 -s Phy_Align.phy -# ~{num_boot} -n RAXML_output -T ~{num_t}  

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
        docker: "tnturnerlab/vgp_ens_pipeline:wdl"
        memory: num_m+"GB"
        cpu: num_t
        disks: "local-disk "+disk_size+" SSD"
    }

}
