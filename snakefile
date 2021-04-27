#!/usr/bin/env python
import os

configfile: "config.yaml"


inputDir    = config["INPUTDIR"]
outputDir   = config["OUTPUTDIR"]

inputFileFormat = config["INPUTFORMAT"]

oriTimeLimit    = config["TIMELIMIT"]
memLimit        = config["MEMLIMIT"]

software_singleT    = config["SOFTWARE_SINGLE_THREAD"]
software_mulT       = config["SOFTWARE_MULTIPLE_THREADS"]


alignmentNames  = {}
for root, dirs, names in os.walk(inputDir):
    for name in names:
        #if '28' in name:
        alignmentNames[name] = ''    


def get_input(wildcards):
    input_list  = []

    extensions    = ['newick', 'errorLog', 'timeLog']
    # Software with multiple threads
    if software_mulT:
        input_list.extend(expand(os.path.join(outputDir, "{software}:{threads}:{alignmentName}.{extension}"), software=config["SOFTWARE_MULTIPLE_THREADS"], threads=config["THREADS"], alignmentName=alignmentNames.keys(), extension=extensions))

    # Software with single threads
    if software_singleT:
        input_list.extend(expand(os.path.join(outputDir, "{software}:1:{alignmentName}.{extension}"), software=config["SOFTWARE_SINGLE_THREAD"], alignmentName=alignmentNames.keys(), extension=extensions))
    return input_list

def getWorldTime(times):
    worldTime   = int(times) * int(oriTimeLimit)
    return worldTime

rule all:
    input:
        get_input


rule decenttree:
    input:
        os.path.join(inputDir, "{alignmentName}")
    params:
        timeLimit = lambda wildcards : getWorldTime(wildcards.threads)
    message: 
        """
        Running Decentree
        Threads:        {wildcards.threads} 
        Input file:     {input} 
        Output file:    {output.tree} 
        """
    output:
        errorLog=os.path.join(outputDir, "decenttree:{threads}:{alignmentName}.errorLog"),
        timeLog=os.path.join(outputDir, "decenttree:{threads}:{alignmentName}.timeLog"),
        tree=os.path.join(outputDir, "decenttree:{threads}:{alignmentName}.newick"),
    run:
        if inputFileFormat == 'sth' or inputFileFormat == 'dist':
            if inputFileFormat == 'sth':
                formatParam = '-fasta'
            elif inputFileFormat == 'dist':
                formatParam = '-in'
            shell("""
                    timeout -t {params.timeLimit} -m {memLimit} \
                        /usr/bin/time -o {output.timeLog} -v \
                            decentTree \
                                {formatParam} {input} \
                                -nt {wildcards.threads} \
                                -t NJ \
                                -out {output.tree} 2> {output.errorLog}
                  """)
        else:
            print("ERROR: The input file format is `%s`, only supported 'sth' or 'dist'" % inputFileFormat)



rule fastme:
    input:
        os.path.join(inputDir, "{alignmentName}")
    params:
        timeLimit = lambda wildcards : getWorldTime(wildcards.threads)
    message: 
        """
        Running FastME
        Threads:        {wildcards.threads} 
        Input file:     {input} 
        Output file:    {output.tree} 
        """
    output:
        errorLog=os.path.join(outputDir, "fastme:{threads}:{alignmentName}.errorLog"),
        timeLog=os.path.join(outputDir, "fastme:{threads}:{alignmentName}.timeLog"),
        tree=os.path.join(outputDir, "fastme:{threads}:{alignmentName}.newick")


    run:
        if inputFileFormat == 'dist':
            shell("""
                timeout -t {params.timeLimit} -m {memLimit} \
                    /usr/bin/time -o {output.timeLog} -v \
                        fastme \
                            -m N \
                            -T {wildcards.threads} \
                            -i {input} \
                            -o {output.tree} 2> {output.errorLog} 
                
                  """)
        else:
            print("WARNING: The input file format is `%s`, FastME only supported 'dist'" % inputFileFormat)



rule fasttree:
    input:
        os.path.join(inputDir, "{alignmentName}")
    params:
        timeLimit = lambda wildcards : getWorldTime(wildcards.threads)
    message: 
        """
        Running FasttreeMP
        Threads:        {wildcards.threads} 
        Input file:     {input} 
        Output file:    {output.tree} 
        """
    output:
        errorLog=os.path.join(outputDir, "fasttree:{threads}:{alignmentName}.errorLog"),
        timeLog=os.path.join(outputDir, "fasttree:{threads}:{alignmentName}.timeLog"),
        tree=os.path.join(outputDir, "fasttree:{threads}:{alignmentName}.newick")


    run:
        if inputFileFormat == 'fasta':
            shell("""
                export OMP_NUM_THREADS={wildcards.threads}
                timeout -t {params.timeLimit} -m {memLimit} \
                    /usr/bin/time -o {output.timeLog} -v \
                        zcat -f {input} | FastTreeMP \
                            -nt \
                            -out {output.tree} \
                            -noml 2> {output.errorLog}

                """)
        else:
            print("WARNING: The input file format is `%s`, Fasttree only supported 'fasta' (or phylip in MSA, but this pipeline does not support phylip)" % inputFileFormat)



rule rapidnj:
    input:
        os.path.join(inputDir, "{alignmentName}")
    params:
        timeLimit = lambda wildcards : getWorldTime(wildcards.threads)
    message: 
        """
        Running RapidNj
        Threads:        {wildcards.threads} 
        Input file:     {input} 
        Output file:    {output.tree} 
        """
    output:
        errorLog=os.path.join(outputDir, "rapidnj:{threads}:{alignmentName}.errorLog"),
        timeLog=os.path.join(outputDir, "rapidnj:{threads}:{alignmentName}.timeLog"),
        tree=os.path.join(outputDir, "rapidnj:{threads}:{alignmentName}.newick")

    run:
        if inputFileFormat == 'sth' or inputFileFormat == 'fasta' or inputFileFormat == 'dist':
            if inputFileFormat == 'sth':
                formatParam = 'sth'    
            elif inputFileFormat == 'fasta':
                formatParam = 'fa'    
            elif inputFileFormat == 'dist':
                formatParam = 'pd'    
            shell("""
                timeout -t {params.timeLimit} -m {memLimit} \
                    /usr/bin/time -o {output.timeLog} -v \
                        rapidnj \
                            {input} \
                            -i {formatParam} \
                            -c {wildcards.threads} \
                            -x {output.tree} 2> {output.errorLog}
                      """)
        else:
            print("ERROR: The input file format is `%s`, only supported 'sth', 'fasta' or 'dist'" % inputFileFormat)



rule bionj:
    input:
        os.path.join(inputDir, "{alignmentName}")
    params:
        timeLimit = lambda wildcards : getWorldTime(wildcards.threads)
    message: 
        """
        Running BioNJ 
        Threads:        1 
        Input file:     {input} 
        Output file:    {output.tree} 
        """
    output:
        errorLog=os.path.join(outputDir, "bionj:1:{alignmentName}.errorLog"),
        timeLog=os.path.join(outputDir, "bionj:1:{alignmentName}.timeLog"),
        tree=os.path.join(outputDir, "bionj:1:{alignmentName}.newick")

    run:
        if inputFileFormat == 'dist':
            shell("""
            timeout -t {params.timeLimit} -m {memLimit} \
                /usr/bin/time -o {output.timeLog} -v \
                    BIONJ_linux ${input} ${output.tree} 2> {output.errorLog} 
            """)
           
        else:
            print("WARNING: The input file format is `%s`, BioNJ only supported 'dist'" % inputFileFormat)



rule quicktree:
    input:
        os.path.join(inputDir, "{alignmentName}")
    params:
        timeLimit = lambda wildcards : getWorldTime(wildcards.threads)
    message: 
        """
        Running Quicktree
        Threads:        1
        Input file:     {input} 
        Output file:    {output.tree} 
        """
    output:
        errorLog=os.path.join(outputDir, "quicktree:1:{alignmentName}.errorLog"),
        timeLog=os.path.join(outputDir, "quicktree:1:{alignmentName}.timeLog"),
        tree=os.path.join(outputDir, "quicktree:1:{alignmentName}.newick")

    run:
        if inputFileFormat == 'sth' or inputFileFormat == 'dist':
            if inputFileFormat == 'sth':
                formatParam = 'a'    
            elif inputFileFormat == 'dist':
                formatParam = 't'    

            shell("""
                    timeout -t {params.timeLimit} -m {memLimit} \
                        /usr/bin/time -o {output.timeLog} -v \
                            quicktree \
                                -in {formatParam} \
                                -out t \
                                {input} 2> {output.errorLog} 1> {output.tree}
                  """)
        else:
            print("ERROR: The input file format is `%s`, only supported 'sth' or 'dist'" % inputFileFormat)

