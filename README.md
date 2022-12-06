# A plan for benchmarking decentTree
Compare the running time, memory usage and accuracy of different neighbour-joining software with different input alignments and threads.

## Requirments
  **Required**
  - timeout (https://github.com/pshved/timeout, for the CPU time and memory usage limitation)
  - seqtk v1.3-r116-dirty (https://github.com/lh3/seqtk, for subsampling the alignments)
  - IQ-TREE2 (https://github.com/iqtree/iqtree2, for converting the .newick format to distance matrix)
  - cmpMatrix (https://github.com/thomaskf/cmpMatrix, for calculating the root-mean-square difference between distance matrixs) (**not use in the manuscript**)

  **Programs to compare** 
  - Decenttree (https://github.com/iqtree/decenttree)
  - FastME v2.1.6.2 (http://www.atgc-montpellier.fr/fastme/)
  - RapidNJ v2.3.2 (https://birc.au.dk/software/rapidnj/)
  - Quicktree v2.5 (single threads) (https://github.com/khowe/quicktree)
  - BioNJ (single threads) (http://www.atgc-montpellier.fr/bionj/)
  - FastTree (http://www.microbesonline.org/fasttree/)


##  Input format

The supported input format of each software

|  Software | MSA | Distance matrix | Multi-threads
| ------------- | ------------- | ------------- | ------------- |
| Decenttree  | .fasta(.gz)  | Yes | Yes |
| RapidNJ  | .fasta, .sth  | Yes | Yes, in converting fasta to distance matrix step |
| FastME  | ?  | Yes | Yes, in converting fasta to distance matrix step |
| BioNJ  | No  | Yes | No |
| Quicktree  | .sth  | Yes | No |
| FastTree | .fasta(.gz) | Yes | Yes |

>MSA: Multiple sequence alignment; .sth: Stockholm format. 

>For FastME, altough their manual said it supports MSA input with sequence alignment, but the face seems to be not. 




## 1. Original datasets
1.1. Public SARS-CoV-2 alignment: 364,428 sequences, 29,903 bp (https://github.com/bpt26/parsimony/blob/main/1_sample_selection/publicMsa.2021-03-18.masked.retain_samples.save.minus_parsimony.samples.fasta.xz, 11/05/2021)

1.2. Sliva rRNAs (138.1). https://www.arb-silva.de/download/arb-files/

 - SSU NR99 (small ribosomal subunit): 510,508 sequences, 50,000 bp,`SILVA_138.1_LSURef_NR99_tax_silva_full_align_trunc.fasta.gz`
 ```
  It is based on the Ref dataset with a 99% criterion applied to remove redundant sequences using the Opens external link in new windowvsearch tool. 
  Sequences from cultivated species have been preserved independent from prior filtering.
  ```

  - LSU NR99 (large ribosomal subunit): 95,286 sequences, 149,999 bp, `SILVA_138.1_LSURef_NR99_tax_silva_full_align_trunc.fasta.gz`
 ```
  It is based on the Ref dataset with a 99% criterion applied to remove redundant sequences using the Opens external link in new windowvsearch tool. 
  Sequences from cultivated species have been preserved independent from prior filtering.
  ```



## 2. Pre-process
### 2.1 subsample

Randomly selected 7 subsets (1000 2000 4000 8000 16000 32000 64000) from the three databases, respectively. Totally 21 subsets.

```
# inputFile is original dataset
inputFile=$1
# number is the sequences number
number=$2
# outputFile is the sequences after randomly selected 
outputFile=$3

seqtk sample $inputFile $number | pigz > $outputFile

```

### 2.2 Get distance matrix

```
# inputFile is the subset generated in 2.1 subsample
inputFile=$1
# outputFile is the distance matrix of the subset
outputFile=$2
# threads is how many threads you want to use in this run
threads=$3

# -truncate-name-at " ": truncate the content after space (" ") of the fasta name. 
#                        Some fasta names contains space, which will disrupt the 
#                        distance matrix.

decentTree \
    -fasta $inputFile \
    -no-matrix \
    -dist-out $outputFile \
    -t NONE \
    -no-out \
    -truncate-name-at " " \
    -no-banner \
    -nt $threads

```

## 3 Run each program

We used each subset as the input to run each program (Decenttree, FastME, RapidNJ, Quicktree, and BioNJ). 
- If the program has more than one NJ related algorithms, we ran all of them. Decenttree has 4 NJ related algorithms (BIONJ-V, BIONJ-R, NJ-R, NJ-V), whereas FastME has two (BIONJ, NJ)
- If the program supported multi-threads, we ran it with 2 different thread setting (1,32). This resulted in totally 378 (9 implements x 2 thread counts x 21 subsets) combinations.

To save the computational resource, we limited the memory to 500 GB, and the running elapsed time to 12 hours with `timeout`.

We recorded the elapsed time and memory useage with `usr/bin/time`.

### 3.1 Decenttree
```
# 12 hours
timelimit=43200
# 500 GB
memlimit=400000000

# inputFile is the distance matrix of subset generated from 2.2 Get distance matrix
inputFile=$1
# outputFile is the output result (in .newick format)
outputFile=$2
# threads is how many threads you want to use in this run
threads=$3
# timelog is the log file of elapsed time and memory useage
timelog=$4

for method in BIONJ-R BIONJ-V NJ-R NJ-V
do
    for threads in 1 32
    do
       ((fix_time=$threads*$timelimit))

       /home/raymond/devel/timeout/timeout -t $fix_time -m $memlimit \
           /usr/bin/time -o $timelog -v \
               decentTree \
                   -in $inputFile \
                   -nt $threads \
                   -t $method \
                   -out $outputFile
    done
done

```


### 3.2 FastME
```
# 12 hours
timelimit=43200
# 500 GB
memlimit=500000000

# inputFile is the distance matrix of subset generated from 2.2 Get distance matrix
inputFile=$1
# outputFile is the output result (in .newick format)
outputFile=$2
# threads is how many threads you want to use in this run
threads=$3
# timelog is the log file of elapsed time and memory useage
timelog=$4


for method in BIONJ NJ
do
    for threads in 1 32
    do
       ((fix_time=$threads*$timelimit))

       /home/raymond/devel/timeout/timeout -t $fix_time -m $memlimit \
           /usr/bin/time -o $timelog -v \
               fastme \
                   -m $method \
                   -T $threads \
                   -i $inputFile\
                   -o $outputFile
    done
done

```

### 3.3 RapidNJ
```
# 12 hours
timelimit=43200
# 500 GB
memlimit=500000000

# inputFile is the distance matrix of subset generated from 2.2 Get distance matrix
inputFile=$1
# outputFile is the output result (in .newick format)
outputFile=$2
# threads is how many threads you want to use in this run
threads=$3
# timelog is the log file of elapsed time and memory useage
timelog=$4

# -i pd: the input is in distance matrix in phylip format
for threads in 1 32
do
    ((fix_time=$threads*$timelimit))
    
     /home/raymond/devel/timeout/timeout -t $fix_time -m $memlimit \
         /usr/bin/time -o $timelog -v \
             rapidnj \
                 $inputFile \
                 -i pd \
                 -c $threads \
                 -x $outputFile 
     
done
```

### 3.4 Quicktree
```
# 12 hours
timelimit=43200
# 500 GB
memlimit=500000000

# inputFile is the distance matrix of subset generated from 2.2 Get distance matrix
inputFile=$1
# outputFile is the output result (in .newick format)
outputFile=$2
# timelog is the log file of elapsed time and memory useage
timelog=$3

# -in m: inputFile is in distance matrix format
# -out t: output is a tree in New Hampshire format
timeout -t $timelimit -m $memlimit \
    /usr/bin/time -o $timelog -v \
        quicktree \
            -in m \
            -out t \
            $inputFile  1> $outputFile
```

### 3.5 BioNJ
```
# 12 hours
timelimit=43200
# 500 GB
memlimit=500000000

# inputFile is the distance matrix of subset generated from 2.2 Get distance matrix
inputFile=$1
# outputFile is the output result (in .newick format)
outputFile=$2
# timelog is the log file of elapsed time and memory useage
timelog=$3

timeout -t $timelimit -m $memlimit \
    /usr/bin/time -o $timelog -v \
        BIONJ \
            $inputFile \
            $outputFile
```

### 3.6 FastTree
```
# 12 hours
timelimit=43200
# 500 GB
memlimit=500000000

# inputFile is the multiple sequence alignment file
inputFile=$1
# outputFile is the output result (in .newick format)
outputFile=$2
# timelog is the log file of elapsed time and memory useage
timelog=$3
# threads is how many threads you want to use in this run
threads=$4


export OMP_NUM_THREADS=$threads
timeout -t $timelimit -m $memlimit \
    /usr/bin/time -o $timelog -v \
        FastTreeMP -nt -noml -out $outputFile $inputFile 

```

## 4 Comparison

### 4.1 Compare the log likelihood of each output tree

```
# AlignmentFile is the corresponding subset alignment file (in .fasta format) of each tree output
alignmentFile=$1
# treeFile is the tree output of each combination
treeFile=$2
# outputPrefix is the prefix of output results. The log likelihood is in ${outputPrefix}.iqtree
outputPrefix=$3

# -m JC: using JC mode (Equal substitution rates and equal base frequencies)
# --epsilon 1: IQ-TREE will optimise the branch lengths of the tree, 
               until the log-likelihood difference between two consecutive step is < epsilon.
               Larger epsilon makes it run faster, but lower epsilon make likelihood values more accurate.

iqtree2 --epsilon 1 -s $alignmentFile -te $treeFile -m JC --prefix $outputPrefix
```

### 4.2 Calculate the Robinson-Foulds (RF) distance between the different trees inferred on each dataset

```
# treeFile is the tree output of each combination
iqtree2 -rf $treeFile1 $treeFile2
```


### 4.3 Calculate the root-mean-square between original input and the distance matrix of output tree result of each combination (haven't used in the manuscript)
To compare the accuracy of different programs, we calculated the the root-mean-square between original input and the distance matrix of output tree result of each combination. 


Firstly, we converted the tree to distance matrix with `IQ-TREE`

```
# treeFile is the tree output of each combination
treeFile=$1
# outputFile is in distance matrix format
outputFile=$2

iqtree2 \
    -dist $outputFile \
    -t $treeFile
```

Secondly, compared the original distance matrix and the tree distance matrix
```
# oriFile is the corresponding distance matrix file generated from 2.2 Get distance matrix.
oriFile=$1
# inputFile is the file in distance matrix format generated from last IQ-TREE step.
inputFile=$2

 cmpMatrix \
     $oriFile \
     $inputFile
```
