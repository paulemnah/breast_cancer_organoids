library(tidyverse)
library(data.table)
media_df = data.frame('success' = c(43,36,75), 'fail' = c(63,70,31), row.names = c('clevers', 'CSC', 'overall'))

library(graphics)
pdf('/path/to/organoid_manuscript/figures/SFig_S2_media_take_rate.pdf', width = 5, height = 5)
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
       x = "media", y = "count") +
  theme_pubclean() + theme(legend.title = element_blank()) + 
  scale_fill_manual(values = c('#AEABAB','#94A9D8')) + theme(legend.position = 'right')

ggsave('/path/to/organoid_manuscript/figures/Fig1_success_by_medium.pdf')

