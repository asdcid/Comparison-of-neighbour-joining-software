# A plan for benchmarking decentTree
Compare the running time, memory usage and accuracy of different neighbor-joining software with different input alignments and threads.

## Requirments
  **Script required**
  - timeout (https://github.com/pshved/timeout, for the CPU time and memory usage limitation)
  - seqtk v1.3-r116-dirty (for subsampling the alignments)
  - IQ-TREE2 (for converte)
  - cmpMatrix

  **Software to compare** (can add or remove any software)
  - Decenttree
  - RapidNJ v2.3.2
  - FastME v2.1.6.2
  - Quicktree v2.5 (single threads)
  - BioNJ (single threads)
  - Fasttree v2.1.11 (Using FasttreeMP for multiple threads) **Not use, because it does not support dist format**




##  Input format

The supported input format of each software

|  Software | MSA | Distance matrix |
| ------------- | ------------- | ------------- |
| Decenttree  | .fasta(.gz)  | Yes |
| Fasttree  | .fasta, .phylip  | No |
| RapidNJ  | .fasta, .sth  | Yes |
| FastME  | ?  | Yes |
| BioNJ  | No  | Yes |
| Quicktree  | .sth  | Yes |

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

Randomly selected 7 subsets (1000 2000 4000 8000 16000 32000 64000) from the five databases.

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

## 3 Run each programs

15 al, record by time out

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

### 4 Comparison

### 4.1 Compare the log likelihood of each output tree

```
iqtree2 --epsilon 1 -s $dataset -te $treeFile -m JC --prefix $outputFile
```

### 4.2 Compare the root-mean-square of 
Firstly, we converted the tree to distance matrix 

Secondly, compared the original distance matrix and the tree distance matrix

