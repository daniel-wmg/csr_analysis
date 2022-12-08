library(tidyverse)
library(readxl)
library(plotly)
library(widgetframe)
library(stringdist)
library(hash)

theme_set(theme_classic())



get_family_size <- function(filename){
  return(as.numeric(str_split(str_split(filename, "_", simplify = T)[3], "-", simplify = T)[2]))
}

is_mutant <- function(position, codon){
  return(codon %in% exp_mut[exp_mut$aa_position==position,]$MUT_codon)
}

lookup <- function(codes){
  out <- c()
  
  for(code in codes){
    out <- c(out, statuses[[code]])  
  }
  
  return(out)
}





experiments_model <- c(
  "20e3fdba10a947ad9bfc1e069afec0a7-0",
  "a5a481f406014d78b279cf0d2c0b2dc5-0",
  "d4d453f7e67e485faad441242f7e91a3-4",
  "d7cfb9d220334e50a954374024b3a447-0",
  "38b787b5e35849b6b824338ad75cc857-28",
  "7cf951f40cef4cd282d031508afd91df-42",
  "919bf0f1b76f49f3b1b4d9dbad00ab6d-34",
  "ccd298e3627442c4b265b6a52b77f635-39"
)



experiments <- experiments_model

ref_file <- "model_library.csv"
exp_mut <- read_csv(ref_file)%>%
  select(c(aa_position, MUT_codon))



statuses <- hash()
statuses[["000001"]] <- "other_mutant"
statuses[["000010"]] <- "expected_mutant"
statuses[["000100"]] <- "wt_codon"
statuses[["001001"]] <- "poor_quality"
statuses[["010001"]] <- "contains_insert"
statuses[["011001"]] <- "poor_quality_and_contains_ins"
statuses[["100001"]] <- "contains_del"
statuses[["101001"]] <- "poor_quality_and_contains_del"
statuses[["NANANA000"]] <- "ಠ_ಠ"


full_data <- read_csv("family_size_3.csv")

## TESTING ONLY

full_data%>%
  filter(experiment == "ccd298e3627442c4b265b6a52b77f635-39")%>%
  filter(position <3)%>%
  write_csv("test_data.csv")

full_data <- read.csv("test_data.csv")

## END 
  

data <- full_data %>%
  select(c(experiment, wt_codon, position, codon, count, freq, type))%>%
  mutate(experiment = as.factor(experiment))%>%
  filter((experiment %in% experiments))%>%
  mutate(type = as.factor(type), position = as.numeric(position))%>%
  mutate(edit_dist = as.factor(stringdist(codon, wt_codon, method="lv")))%>%
  mutate(contains_del = if_else(str_detect(codon, "-"), 1, 0))%>%
  mutate(contains_ins = if_else(str_detect(codon, "\\^"), 1, 0))%>%
  mutate(poor_qual = if_else(str_detect(codon, "\\*"), 1, 0))%>%
  rowwise()%>%
  mutate(mut = if_else(is_mutant(position, codon), 1, 0))%>%
  mutate(type = as.character(type))%>%
  ungroup()%>%
  mutate(type = if_else(mut == 1, "mut", type))%>%
  mutate(wt = if_else(type == "wt", 1, 0))%>%
  mutate(other = if_else(type == "other", 1, 0))%>%
  mutate(status = paste(contains_del, contains_ins, poor_qual, wt, mut, other, sep=""))%>%
  mutate(status = lookup(as.character(status)))%>%
  mutate(status = as.factor(status))


# TESTING ---------------------------------------
# Check that the pipeline looked at all positions
data %>%
  group_by(experiment, position)%>%
  summarise(numthings = n())%>%
  ungroup()%>%
  group_by(experiment)%>%
  summarise(numPos = n())%>%
  filter(numPos < 804)

# Look what positions made it through

pos_through <- data %>% 
  #filter(experiment == "90560b9c2b4c488aa4c0d0b72cf075b3-0")%>%
  filter(experiment == "aca68940de3a4b4ca79fbdcb3ec9590b-0")%>%
  pull(position)%>%
  as.factor()%>%
  levels()%>%
  as.numeric()%>%
  as.array()

expected_pos <- seq(1, 804)

setdiff(expected_pos, pos_through)

# --------------------------------------------------------------------------

# Global Variables

max_position <- 750

# NEW HAPPYNESS

table_1 <- data %>%
  # Filter out garbage codons, and positions we're not interested in
  filter(position <= max_position)%>%
  filter(poor_qual == 0)%>%
  filter(contains_ins == 0) %>%
  filter(contains_del == 0)%>%
  ungroup()%>%
  
  # Calculate the percentage that a codon at a site represents of all the 
  # codons at that site
  group_by(experiment, position)%>%
  mutate(pct_of_total_codons_at_site = count / sum(count)*100)%>%
  ungroup()%>%
  
  # Calculate avg, min and max of codon representation at each position for
  # each edit distance
  group_by(experiment, position, status, edit_dist)%>%
  summarise(avg_codon_pct = mean(pct_of_total_codons_at_site), 
            min_codon_pct=min(pct_of_total_codons_at_site), 
            max_codon_pct = max(pct_of_total_codons_at_site), 
            num_codons=sum(count))

table_1 %>%
  filter(status == "other_mutant")%>%
  clipr::write_clip()



# THIS IS WHAT LEO WANTS -- avg other freq at each pos avged over every other pos

table_2 <- table_1%>%
  ungroup()%>%
  mutate(edit_dist = as.factor(edit_dist))%>%
  group_by(experiment, status,edit_dist)%>%
  
  summarise(avg_avg_codon_pct = sum(avg_codon_pct)/max_position,
            max_max_codon_pct = max(max_codon_pct),
            avg_max_codon_pct = sum(max_codon_pct)/max_position)%>%
  filter(status == "other_mutant")


table_2%>%
  clipr::write_clip()





  
# General metrics about the experiment -- still need ???
data %>%
  filter(position <= 750)%>%
  group_by(experiment, status)%>%
  summarise(count = sum(count))%>%
  mutate(pct_of_total = count/sum(count)*100)%>%
  mutate(passes_quality = str_detect(status, "poor", negate = T))%>%
  arrange(experiment, -passes_quality, status)%>%
  clipr::write_clip()
  
  write_csv("codon_stats.csv")
  

