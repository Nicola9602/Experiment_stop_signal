# Source: original/Analysis_stop_data_original.R. Statistical code retained.
# Load Dataset and Data preparation ----
dfi <- read_excel("data/df_stop_estimation_method.xlsx")

# From the questionnaire analysis I now have created frou groups
# I have addiction high addiction low
# I have impulsivity high and impulsivity low 
# Addiction groups
addiction_high_ids <- c(1, 2, 4, 6, 8, 13, 17, 20, 21, 23, 24, 25, 28, 29, 30, 32, 34, 36, 38)
addiction_low_ids  <- c(3, 5, 7, 11, 12, 14, 15, 16, 22, 26, 27, 31, 33, 35, 37)

# Impulsivity groups
impulsivity_high_ids <- c(3, 4, 6, 7, 12, 14, 16, 17, 22, 23, 26, 28, 29, 30, 31, 32, 34, 35, 36, 38)
impulsivity_low_ids  <- c(1, 2, 5, 8, 11, 13, 15, 20, 21, 24, 25, 27, 33, 37)

# Now assign participants to groups in my dfmm
dfi$addiction <- NA
dfi$impulsivity <- NA

for (i in seq_len(nrow(dfi))) {
  id <- dfi$subject[i]

  # Addiciton group
  if (id %in% addiction_high_ids) {
    dfi$addiction[i] <- "High"
  } else if (id %in% addiction_low_ids){
    dfi$addiction[i] <- "Low"
  }

  # Impulsivity Group 
  if (id %in% impulsivity_high_ids) {
    dfi$impulsivity[i] <- "High"
  } else if (id %in% impulsivity_low_ids){
    dfi$impulsivity[i] <- "Low"
  }

}

instagram_ids <- c(1, 2, 5, 6, 7, 11, 12, 23, 25, 26, 30, 31, 32, 33, 34, 36)
tiktok_ids    <- c(3, 4, 8, 13, 14, 16, 17, 21, 27, 28, 37, 38)
facebook_ids  <- c(24, 29)
twitter_ids   <- c(15, 20, 22, 35)


names(dfi) <- tolower(names(dfi))

dfi$group <- as.factor(dfi$group)
dfi$content <- as.factor(dfi$content)
dfi$subject <- as.factor(dfi$subject)

# Drop participants ----

# This I drop them because they do not have the same amount of stop as the others 
# importantly thesere are not 4 paritcipants, but 2, with 2 conditions each
# Drop participants 
# This I drop them because they do not have the same amount of stop as the others 
# importantly these are not 4 participants, but 2, with 2 conditions each
participants_to_drop <- c(9, 10, 18, 19)
dfi <- dfi[!dfi$subject %in% participants_to_drop,]

# Drop SSRT < 150 ms

n_before <- nrow(dfi)
dfi %>% filter(ssrt<150) %>% distinct(subject)


dfi <- dfi %>% filter(ssrt >= 150)
n_after <- nrow(dfi)
cat("Number of participants excluded due to SSRT < 150ms:", n_before - n_after, "\n")

# Add a column for general IG vs Poem 
dfi <- dfi %>%
  mutate(
    condition_general = case_when(
      condition %in% c("1IG", "2IG") ~ "IG",
      condition %in% c("1Poem", "2Poem") ~ "Poem"
    )
  )


#endregion ----

