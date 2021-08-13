# A plan for benchmarking decentTree
Compare the running time, memory usage and accuracy of different neighbor-joining software with different input alignments and threads.

## Requirments
  **Script required**
  - timeout (https://github.com/pshved/timeout, for the CPU time and memory usage limitation)
  - seqtk v1.3-r116-dirty (https://github.com/lh3/seqtk, for subsampling the alignments)
  - IQ-TREE2 (https://github.com/iqtree/iqtree2, for converting the .newick format to distance matrix)
  - cmpMatrix (https://github.com/thomaskf/cmpMatrix, for calculating the root-mean-square difference between distance matrixs)

  **Software to compare** (can add or remove any software)
  - Decenttree
  - RapidNJ v2.3.2
  - FastME v2.1.6.2
  - Quicktree v2.5 (single threads)
  - BioNJ (single threads)



##  Input format

The supported input format of each software

|  Software | MSA | Distance matrix | Multi-threads
| ------------- | ------------- | ------------- | ------------- |
| Decenttree  | .fasta(.gz)  | Yes | Yes |
| RapidNJ  | .fasta, .sth  | Yes | Yes in fasta to distance matrix step |
| FastME  | ?  | Yes | Yes in fasta to distance matrix step |
| BioNJ  | No  | Yes | No |
| Quicktree  | .sth  | Yes | No |

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

  - SSU: 2,224,740 sequences, 50,000 bp, `SILVA_138.1_SSURef_tax_silva_full_align_trunc.fasta.gz`
```
  aligned 16S/18S ribosomal RNA sequences with a minimum length of 1200 bases for Bacteria and Eukarya and 900 bases for Archaea.
```



  - LSU NR99 (large ribosomal subunit): 95,286 sequences, 149,999 bp, `SILVA_138.1_LSURef_NR99_tax_silva_full_align_trunc.fasta.gz`
 ```
  It is based on the Ref dataset with a 99% criterion applied to remove redundant sequences using the Opens external link in new windowvsearch tool. 
  Sequences from cultivated species have been preserved independent from prior filtering.
  ```
  - LSU: 227,331 sequences, 149,999 bp, `SILVA_138.1_LSURef_tax_silva_full_align_trunc.fasta.gz`
```
 Aligned 23S/28S ribosomal RNA sequences with a minimum length of 1900 bases.
```


## 2. Pre-process
### 2.1 subsample

Randomly selected 7 subsets (1000 2000 4000 8000 16000 32000 64000) from the five databases, respectively. Totally 35 subsets.

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

decentTree \
    -fasta $inputFile \
    -no-matrix \
    -dist-out $outputFile \
    -t NONE \
    -no-out \
    -no-banner \
    -nt $threads

```

## 3 Run each program

We used each subset as the input to run each program (Decenttree, FastME, RapidNJ, Quicktree, and BioNJ). If the program has more than one NJ related algorithms, we ran all of them. If the program supported multi-threads, we ran it with 6 different thread setting (1,2,4,8,16,32). This resulted in totally 2,800 runs.

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

for method in BIONJ BIONJ-R BIONJ-V NJ NJ-R NJ-R-D NJ-V RapidNJ UNJ
do
    for threads in 1 2 4 8 16 32
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
# threads is how many threads you want to use in this run
threads=$3

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
# threads is how many threads you want to use in this run
threads=$3

```





### 4 Comparison

### 4.1 Compare the log likelihood of each output tree

```
iqtree2 --epsilon 1 -s $dataset -te $treeFile -m JC --prefix $outputFile
```

### 4.2 Compare the root-mean-square of 
Firstly, we converted the tree to distance matrix 

Secondly, compared the original distance matrix and the tree distance matrix

