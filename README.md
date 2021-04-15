# A plan for benchmarking decentTree


1. subread < total reads, if subread > total reads, output all reads

## Requirments
  **Script required**
  - timeout (https://raw.githubusercontent.com/pshved/timeout/master/timeout)
  - pigz

  **Software to compare**
  - decenttree
  - quicktree
  - RapidNJ
  - FastME
  - Fasttree
  - BioNJ (cannot install)

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
  - quicktree ()
  - RapidNJ
  - FastME (although the manual said it allow , but it is not)
  - Fasttree ()
  - BioNJ (cannot install)
 
