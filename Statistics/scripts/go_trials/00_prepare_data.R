# Source: original/Analysis_go_data_original.R (original order preserved).
# Data Preparation ----
#region 1. Data Preparation ---

df <- read_csv("data/df_total.csv", show_col_types = FALSE)


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
df$addiction <- NA
df$impulsivity <- NA

for (i in seq_len(nrow(df))) {
  id <- df$participant[i]

  # Addiciton group
  if (id %in% addiction_high_ids) {
    df$addiction[i] <- "High"
  } else if (id %in% addiction_low_ids){
    df$addiction[i] <- "Low"
  }

  # Impulsivity Group 
  if (id %in% impulsivity_high_ids) {
    df$impulsivity[i] <- "High"
  } else if (id %in% impulsivity_low_ids){
    df$impulsivity[i] <- "Low"
  }

}

instagram_ids <- c(1, 2, 5, 6, 7, 11, 12, 23, 25, 26, 30, 31, 32, 33, 34, 36)
tiktok_ids    <- c(3, 4, 8, 13, 14, 16, 17, 21, 27, 28, 37, 38)
facebook_ids  <- c(24, 29)
twitter_ids   <- c(15, 20, 22, 35)


# Drop the 4 participants which are problematic 
#They are the 9, 10, 18 and 19. 

participants_to_drop <- c(9, 10, 18, 19)
df <- df[!df$participant %in% participants_to_drop, ]

# Drop also RT < 150 
# Drop SSRT < 150 ms
n_before <- nrow(df)
df %>% filter(rt<150) %>% distinct(participant)


df <- df %>% filter(rt >= 150)
n_after <- nrow(df)
cat("Number of participants excluded due to SSRT < 150ms:", n_before - n_after, "\n")


df$group <- as.factor(df$group)
df$condition <- as.factor(df$condition)
df$participant <- as.factor(df$participant)
df$trial_type <- as.factor(df$trial_type)


table(df$group, df$condition)

# Get demographics 
dfd <- df %>%
  dplyr::select(participant, gender,age) %>%
  dplyr::distinct()

dfd %>%
  dplyr::group_by(gender) %>%
  dplyr::summarise(
    n = n(),
    mean_age = mean(age, na.rm=TRUE), 
    sd_age = sd(age, na.rm=TRUE), 
  )

#endregion ---

# Saved aggregate demographics; individual participant records are not exported.
demographics_summary <- dfd %>%
  dplyr::group_by(gender) %>%
  dplyr::summarise(n = dplyr::n(), mean_age = mean(age, na.rm = TRUE),
                   sd_age = sd(age, na.rm = TRUE), .groups = "drop")
readr::write_csv(demographics_summary, "outputs/tables/go/demographics_by_gender.csv")
