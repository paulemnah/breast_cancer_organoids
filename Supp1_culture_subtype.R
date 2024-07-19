
subtype_df = data.frame('success' = c(19,7,3,14), 'fail' = c(10,3,5,10), row.names = c('HR+HER2-', 'HR+HER2+','HER2 enriched', 'TNBC'))

library(graphics)
pdf('/path/to/organoid_manuscript/figures/SFig_S1_subtype_take_rate.pdf', width = 5, height = 5)
mosaicplot(subtype_df, shade = TRUE, las=3,
           main = "culture take rate")
dev.off()

chisq <- chisq.test(subtype_df)
chisq
