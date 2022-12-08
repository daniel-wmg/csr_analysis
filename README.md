# CSR Analysis

Tool to analyse data that comes from counting codons in a bam file. Optionally,  supplementary information detailing what the expected mutants are at each position can be supplied.

## Outputs


This tool results in two tabular outputs:

- Table 1: contains summarised information on a per-position basis. 

- Table 2: Further summarises the metrics in table 1 across all positions in the amplicon

### Table 1

|experiment                          | position|status       |edit_dist | avg_codon_pct| min_codon_pct| max_codon_pct| num_codons|
|:-----------------------------------|--------:|:------------|:---------|-------------:|-------------:|-------------:|----------:|
|03d67b7d11ec488f8a88506ef65ba8c4-26 |        1|other_mutant |1         |     0.0252972|     0.0252972|     0.0252972|          2|
|03d67b7d11ec488f8a88506ef65ba8c4-26 |        3|other_mutant |1         |     0.0118483|     0.0118483|     0.0118483|          4|
|03d67b7d11ec488f8a88506ef65ba8c4-26 |        4|other_mutant |1         |     0.0501830|     0.0118078|     0.1298855|         17|
|03d67b7d11ec488f8a88506ef65ba8c4-26 |        5|other_mutant |1         |     0.0909624|     0.0117371|     0.2464789|         31|
|03d67b7d11ec488f8a88506ef65ba8c4-26 |        6|other_mutant |1         |     0.0290529|     0.0116212|     0.0813481|         10|
|03d67b7d11ec488f8a88506ef65ba8c4-26 |        7|other_mutant |1         |     0.0692521|     0.0115420|     0.1615882|         24|

### Table 2

|experiment                          |status       |edit_dist | avg_avg_codon_pct| max_max_codon_pct| avg_max_codon_pct|
|:-----------------------------------|:------------|:---------|-----------------:|-----------------:|-----------------:|
|03d67b7d11ec488f8a88506ef65ba8c4-26 |other_mutant |1         |         0.0439102|         5.0745853|         0.0982356|
|03d67b7d11ec488f8a88506ef65ba8c4-26 |other_mutant |2         |         0.0024510|         1.0813808|         0.0024510|
|03d67b7d11ec488f8a88506ef65ba8c4-26 |other_mutant |3         |         0.0002073|         0.0846024|         0.0002573|
|0e836d89a7ba4560bed234cdcc7c4043-19 |other_mutant |1         |         0.0427020|         5.2447552|         0.0905387|
|0e836d89a7ba4560bed234cdcc7c4043-19 |other_mutant |2         |         0.0018721|         0.3533049|         0.0018905|
|0e836d89a7ba4560bed234cdcc7c4043-19 |other_mutant |3         |         0.0001741|         0.0564732|         0.0001829|

### Columns

Here follows a brief description of the columns contained in each table:



experiment
: The uuid of the experiment

status
: Each codon gets assigned to a status. The possible statuses for a codon are described further down

edit_dist
: The Levenshtein distance between a codon and the wildtype codon. eg: `wt=ATG, mut=ATT, dist=1`

avg_codon_pct
: Given a position, this is the average percentage of codons at that position that match the filters applied. In table 1, row 1, this metric can be interpreted as _0.025% of the codons at position 1 



## Classification

Codons can be classified as having a specific type, or status. The possible statuses are described below:

- `other_mutant` A codon that has no insertions nor deletions, where all three bases pass quality but is neither a wildtype codon nor an expected mutant

- `expected_mutant` A codon which is not the wt codon, but that is to be expected at the given position

- `wt_codon` The wt codon for a position

- `poor_quality` A codon where 1, 2 or 3 of its bases did not pass quality eg `AG*, A**, ***`

- `contains_insert` A codon that contains an insertion

- `poor_quality_and_contains_ins` A codon that contains both an insertion and 1 to 2 bases that don't pass quality. eg: `A^*, *^*`

- `contains_del` A codon that contains a deletion: eg `A-T`

- `poor_quality_and_contains_del` A codon that contains a deletion and 1 to 2 bases of poor quality. eg: `A-*, *-*`











