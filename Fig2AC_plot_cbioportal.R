
library(ggplot2)
library(ggpubr)
library(data.table)
library(tidyverse)

# obtain public datasets from cbioportal first
setwd("/path/to/Organoid_report_data/public_data/")

cnv_data = fread('Fraction_Genome_Altered.txt') %>% drop_na()

quant95 = quantile(cnv_data$`Fraction Genome Altered`, 0.05)
ggcnv = ggplot(cnv_data, aes(x=`Fraction Genome Altered`)) + 
  geom_histogram(aes(y = after_stat(count / sum(count))),binwidth=0.025, fill="lightgrey", col="grey") +
  theme_pubclean() +
  scale_y_continuous(labels = scales::percent) + labs(y = "Share of samples [%]") +
  geom_vline(xintercept = quant95, linetype = "dotted")
    
ggsave(plot = ggcnv, "fraction_genome_altered_histogram.pdf", width = 7, height = 5, units = "in", dpi = 900)






# mutated genes

mutgenes = fread('Mutated_Genes.txt')

#mutgenes$Freq = gsub("%", "", mutgenes$Freq) %>% as.numeric()
mutgenes$Frequency = mutgenes$`# Mut`/mutgenes$`Profiled Samples`

topmutgenes = mutgenes %>% filter(`Profiled Samples` > 500) %>% arrange(desc(Frequency)) %>% slice_head(n=10)

topmutgenes$Gene = topmutgenes$Gene %>% as.factor()
levels(topmutgenes$Gene)
topmutgenes$Gene = fct_reorder(topmutgenes$Gene, rev(topmutgenes$Frequency))
levels(topmutgenes$Gene)
ggmut = ggplot(topmutgenes, aes(x = Gene, y = Frequency*100)) + geom_col(fill="lightgrey", col="grey") + 
  theme_pubclean() +
  labs(y = "Mutation frequency [%]")
ggmut
ggsave("top_mutated_genes.pdf", width = 7, height = 5, units = "in", dpi = 900)
