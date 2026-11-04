pkg <- c("tidyverse", "readxl", "rstatix")
sapply(pkg, require, character.only = TRUE)

dfq <- read_csv('questionnaire_stop_signal_processed.csv')

participants_to_drop <- c(9, 10, 18, 19)
dfq <- dfq[!dfq$ResponseId %in% participants_to_drop,]

glimpse(dfq)
summary(dfq)

dfq %>% get_summary_stats(Age, type = "mean_sd")

dfq %>% 
    group_by(Sex) %>%
    get_summary_stats(Age, type = "mean_sd")

table(dfq$Social)
    

data <- dfq %>% select(ResponseId, Age, Sex, Social, impulsivity_total, addiction_total, IGA_impulsivity_total, IGA_social_effect)

names(data) <- tolower(names(data))

dataLong <- data %>%
    pivot_longer(cols = c(impulsivity_total, addiction_total, iga_impulsivity_total, iga_social_effect),
    names_to = "variable", values_to = 'score')

dataLong %>%
  filter(variable == "addiction_total") %>%
  ggplot(aes(x = score)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "white") +
  labs(title = "Distribution of Addiction Total Scores",
       x = "Addiction Total Score",
       y = "Count")

ggplot(dataLong, aes(x = variable, y = score)) +
    geom_point()

m_impulsivity <- median(dataLong$score[dataLong$variable == "impulsivity_total"])
m_addiction <- median(dataLong$score[dataLong$variable == "addiction_total"])
m_impulsivity_IGA <- median(dataLong$score[dataLong$variable == "iga_impulsivity_total"])
m_socialaffect_IGA <- median(dataLong$score[dataLong$variable == "iga_social_effect"])

# Create a High and Low groups. Here I actually create them only for 
# Addiction and impulsivity total because in these I grouped all the addiction scores
# from the Addiction scale IG (Soraci) and in implusivity I grouped all the BIS scores

library(dplyr)

dataLong <- dataLong %>%
  mutate(
    addiction_group = case_when(
      variable == "addiction_total" & score <  m_addiction ~ "Low",
      variable == "addiction_total" & score >= m_addiction ~ "High",
      TRUE ~ NA_character_
    ),
    impulsivity_group = case_when(
      variable == "impulsivity_total" & score <  m_impulsivity ~ "Low",
      variable == "impulsivity_total" & score >= m_impulsivity ~ "High",
      TRUE ~ NA_character_
    ),
    Impulsivity_IGA_group = case_when(
      variable == "iga_impulsivity_total" & score <  m_impulsivity_IGA ~ "Low",
      variable == "iga_impulsivity_total" & score >= m_impulsivity_IGA ~ "High",
      TRUE ~ NA_character_
    ),
    SocialAffect_IGA_group = case_when(
      variable == "iga_social_effect" & score <  m_socialaffect_IGA ~ "Low",
      variable == "iga_social_effect" & score >= m_socialaffect_IGA ~ "High",
      TRUE ~ NA_character_
    )
  )

table(dataLong$addiction_group)
table(dataLong$impulsivity_group)


# So now I want to find which participants are high and which low in ADDICTION

# High group IDs
addiction_high_ids <- dataLong %>%
  filter(addiction_group == "High") %>%
  pull(responseid)

# Low group IDs
addiction_low_ids <- dataLong %>%
  filter(addiction_group == "Low") %>%
  pull(responseid)

addiction_high_ids
addiction_low_ids

#Same thing with IMPULSIVITY

impulsivity_high_ids <- dataLong %>%
  filter(impulsivity_group == "High") %>%
  pull(responseid)

# Low group IDs
impulsivity_low_ids <- dataLong %>%
  filter(impulsivity_group == "Low") %>%
  pull(responseid)

impulsivity_high_ids
impulsivity_low_ids


high_iga_impulsivity_participants <- dataLong %>%
    filter(variable == "iga_impulsivity_total") %>%
    filter(score > median(score, na.rm = TRUE))
    
ids <- high_iga_impulsivity_participants$responseid


# Pull social media ids ----
instagram_ids <- unique(dataLong$responseid[dataLong$social == "Instagram"])

facebook_ids <- unique(dataLong$responseid[dataLong$social == 'Facebook'])

tiktok_ids <- unique(dataLong$responseid[dataLong$social == 'TikTok'])

twitter_ids <- unique(dataLong$responseid[dataLong$social == 'Twitter'])



