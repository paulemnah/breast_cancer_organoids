


library(ggplot2)
library(ggpubr)
library(dplyr)
library(data.table)




biopsies = read.csv("../../clinical_data/230428_cognition_biopsies_tumour_cellularity.csv")

biopsies

# only retain T1 biopsies (= primary tumour before treatment), as that is the focus of the study
biopsies = biopsies %>% dplyr::filter(Biopsy %like% "T1")

biopsies$timepoint = "T1"

# plot a boxplot of the distribution of tumour cell content
gghist = biopsies %>% # filter(Biopsy %like% "T1") %>% 
  ggplot(aes(x = Tumor_content_.)) + geom_histogram(aes(y = after_stat(count / sum(count))),binwidth = 10) + 
  theme_pubclean() +
  xlab("Tumour cell content [%]") +
  ylab("Frequency [%]") +
  theme(legend.position = "none") +
  scale_y_continuous(labels = scales::percent)


ggsave(plot = gghist, "figures/supplementary/FigS3-tumour-cell-content-biopsies.pdf", width = 4, height = 4)



# get a table with only those of patients included in our study

PIDs = c('MXMQ6D', 'L789JK', '8C87CC', 'DHSY8V', '6EGL73', 'W31UQZ', 'T4G387',
         'HHJ937', '36XX2J', '7VA4EL', '6A6ZZH', 'FMGU95', 'KGBDTN', 'A3YEMT',
         '2J76CH', 'NDDF92', 'N9SB5N', 'B5VPJQ')

#filter df
organoid_biopsies = filter(biopsies, Sample_ID %in% PIDs)

# add column with PDO# to table
IDmatchingtab = fread('../../240614_PIDS-samplenummern.csv', header = F, col.names = c('PDO#', 'Sample_ID'))
organoid_biopsies = left_join(organoid_biopsies, IDmatchingtab, by = 'Sample_ID')
organoid_biopsies

# Replace Sample_ID with PDO#
organoid_biopsies$Sample_ID = organoid_biopsies$`PDO#`
organoid_biopsies$`PDO#` = NULL
organoid_biopsies$Patho_ID = NULL
organoid_biopsies$IBC = NULL

# sort table by sample ID
organoid_biopsies = organoid_biopsies[order(organoid_biopsies$Sample_ID),]

# correct column name
names(organoid_biopsies)[4] = 'Tumour Content [%]'

#plot
library(gt)
library(stringr)
footnote = paste0('Median = ', median(organoid_biopsies$`Tumour Content [%]`), ' %')
tabplot = organoid_biopsies |>
  gt() |> 
  tab_options(table.layout = 'auto') |>
  cols_label_with(fn = str_to_title) |> 
  fmt_number(decimals = 0) |> tab_footnote(
    footnote = footnote,
    locations = cells_column_labels(columns = `Tumour Content [%]`),
    placement = 'right'
  )
tabplot

gtsave(tabplot, filename = "../../figures/supplementary/FigS3.2-table-orgnd-tumour-cell-content-biopsies.rtf")


