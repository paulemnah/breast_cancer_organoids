

# In this script, I want to read the lab book data table, and filter for those samples, 
# which were grown in both types of medium
# for revision of figure s1 C,D of the organoid manuscript. 

#Paul Schwerd-Kleine
# 22. Aug 2024

library(tidyverse)
library(data.table)

# read csv of lab book table containing info on type of medium and culture success
cogdf = fread("cognition_summary_table_semicol.csv")

# filter for those, where both media were used
df_bothmedia = cogdf %>% dplyr::filter(!cogdf$`Cond. 3 (Clevers)` == "" & !cogdf$`Cond. 5 (CSC+YN)` == "")

# filter last row, it is wrong
df_bothmedia = df_bothmedia[-51,]


# how many samples thereof grew well with clevers?
clev_pos =  sum(df_bothmedia$`Cond. 3 (Clevers)` %like% "\\+\\+" | df_bothmedia$`Cond. 3 (Clevers)` ==  "+")
print(paste0("The number of samples growing in Clevers medium is ", clev_pos, " out of ", nrow(df_bothmedia), " samples."))
csc_pos =  sum(df_bothmedia$`Cond. 5 (CSC+YN)` %like% "\\+\\+" | df_bothmedia$`Cond. 5 (CSC+YN)` ==  "+")
print(paste0("The number of samples growing in CSC medium is ", csc_pos, " out of ", nrow(df_bothmedia), " samples."))




library(tidyverse)
library(data.table)
media_df = data.frame('success' = c(32,35), 'fail' = c(18,15), row.names = c('clevers', 'CSC'))

library(graphics)
pdf('/Users/paulSK/Nextcloud/00_lab/organoid_manuscript/figures/SFig_S2-revised-media_take_rate.pdf', width = 5, height = 5)
mosaicplot(media_df, shade = TRUE, las=3,
           main = "culture take rate")
dev.off()
chisq <- chisq.test(media_df)
chisq




# plot a stacked column plot
# Convert row names to a column
media_df$condition <- rownames(media_df)

# Reshape the data for ggplot
library(tidyr)
media_df_long <- gather(media_df, key = "outcome", value = "value", success, fail)

# Plotting using ggplot
library(ggpubr)
ggplot(media_df_long, aes(x = condition, y = value, fill = outcome)) +
  geom_bar(stat = "identity") +
  labs(title = element_blank(),
       x = "medium", y = "count") +
  theme_pubclean() + theme(legend.title = element_blank()) + 
  scale_fill_manual(values = c('#AEABAB','#94A9D8')) + theme(legend.position = 'right')

ggsave('/Users/paulSK/Nextcloud/00_lab/organoid_manuscript/figures/FigS1-revised-success_by_medium.pdf', width = 3, height = 3)

