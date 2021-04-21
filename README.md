# A plan for benchmarking decentTree
Compare different the running time, memory usage and accuracy of different neighbor-joining software with Snakemake.

1. subread < total reads, if subread > total reads, output all reads

3. the new software name must be the same as config file and rules
4. converted file format (.sth, dist)
5. set path system export PATH="":$PATH, including the timeout

## Requirments
  **Script required**
  - timeout (https://raw.githubusercontent.com/pshved/timeout/master/timeout, for the CPU time and memory usage limitation)
  - pigz
  - Snakemake v5.13.0
  - IQ-Tree (for Multiple sequence alignment conversion, from `.fasta` to `.dist`)
  
  **Software to compare**
  - decenttree
  - quicktree
  - RapidNJ
  - FastME
  - Fasttree
  - BioNJ 

## Usage
1. Download the pipeline
```
https://github.com/asdcid/Snakemake-of-neighbor-joining-software.git
```

2. Modify the configure file `config.yaml`

```
# The path of directory including the input alignments (support MSA in .fasta, .sth and distance matrix format)
INPUTDIR : '/path/of/input/directory'


# The path of output directory
OUTPUTDIR : '/path/of/output/directory'


# Memory limit, kb, 1,000,000,000 = 1 Tb
MEMLIMIT : 1000000000

# CPU limit, seconds, 43200s = 12 hours
TIMELIMIT : 43200


# How many threads you want to use to compare
THREADS : [64, 32, 16, 8, 4, 2, 1]


# The software you want to use to compare, but can only use single thread
SOFTWARE_SINGLE_THREAD : ['bionj', 'quicktree']

# The software you want to use to compare, but can use multiple threads.
SOFTWARE_MULTIPLE_THREADS : ['decenttree', 'rapidnj', 'fastme', 'fasttree']

```

3. Run
```
# $NUM is the threads you want to use, should not be less than the maximum THREADS in `config.yaml`.
snakemake --cores $NUM
```

4. Output files

5. Add new software


**NOTE**
1. All software should be in the environment variable, if not, do
```
export PATH="/place/with/the/file":$PATH
```
2. The name of input alignment file should not contain ':'

 


## 1. Original datasets
1.1. Public SARS-CoV-2 alignment: 364,834 sequences (https://github.com/bpt26/parsimony/blob/main/1_sample_selection/28000_samples_less_than_2_ambiguities.fa.xz, 01/04/2021)

1.2. Sliva rRNAs (138.1). https://www.arb-silva.de/download/arb-files/

 - SSU NR99 (small ribosomal subunit): 510,508 sequences, `SILVA_138.1_LSURef_NR99_tax_silva_full_align_trunc.fasta.gz`
 ```
  It is based on the Ref dataset with a 99% criterion applied to remove redundant sequences using the Opens external link in new windowvsearch tool. 
  Sequences from cultivated species have been preserved independent from prior filtering.
  ```

  - SSU: 2,224,740 sequences,  `SILVA_138.1_SSURef_tax_silva_full_align_trunc.fasta.gz`
```
  aligned 16S/18S ribosomal RNA sequences with a minimum length of 1200 bases for Bacteria and Eukarya and 900 bases for Archaea.
```



  - LSU NR99 (large ribosomal subunit): 95,286 sequences,  `SILVA_138.1_LSURef_NR99_tax_silva_full_align_trunc.fasta.gz`
 ```
  It is based on the Ref dataset with a 99% criterion applied to remove redundant sequences using the Opens external link in new windowvsearch tool. 
  Sequences from cultivated species have been preserved independent from prior filtering.
  ```
  - LSU: 227,331 sequences,  `SILVA_138.1_LSURef_tax_silva_full_align_trunc.fasta.gz`
```
 Aligned 23S/28S ribosomal RNA sequences with a minimum length of 1900 bases.
```

## 2. Parameters


 2.2 Subsample datasets (fasta alignments and IQ-TREE distance matrix)
 
  - decenttree (>5000 reads, run out the memory (1TB))
  - quicktree (1 threads, Stockholm format)
  - RapidNJ
  - FastME (although the manual said it allow , but it is not)
  - Fasttree ()
  - BioNJ (cannot install)
 
