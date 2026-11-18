# Original median splits, participant ID lists, and social-media groups.
m_impulsivity <- median(dataLong$score[dataLong$variable == "impulsivity_total"])
m_addiction <- median(dataLong$score[dataLong$variable == "addiction_total"])
m_impulsivity_IGA <- median(dataLong$score[dataLong$variable == "iga_impulsivity_total"])
m_socialaffect_IGA <- median(dataLong$score[dataLong$variable == "iga_social_effect"])

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

addiction_high_ids <- dataLong %>%
  filter(addiction_group == "High") %>%
  pull(responseid)
addiction_low_ids <- dataLong %>%
  filter(addiction_group == "Low") %>%
  pull(responseid)
impulsivity_high_ids <- dataLong %>%
  filter(impulsivity_group == "High") %>%
  pull(responseid)
impulsivity_low_ids <- dataLong %>%
  filter(impulsivity_group == "Low") %>%
  pull(responseid)

high_iga_impulsivity_participants <- dataLong %>%
    filter(variable == "iga_impulsivity_total") %>%
    filter(score > median(score, na.rm = TRUE))
ids <- high_iga_impulsivity_participants$responseid

instagram_ids <- unique(dataLong$responseid[dataLong$social == "Instagram"])
facebook_ids <- unique(dataLong$responseid[dataLong$social == 'Facebook'])
tiktok_ids <- unique(dataLong$responseid[dataLong$social == 'TikTok'])
twitter_ids <- unique(dataLong$responseid[dataLong$social == 'Twitter'])

# Save participant-level results privately, never in published summary tables.
saveRDS(dataLong, "outputs/models/questionnaires/questionnaire_group_assignments_private.rds")
saveRDS(list(
  addiction_high_ids = addiction_high_ids,
  addiction_low_ids = addiction_low_ids,
  impulsivity_high_ids = impulsivity_high_ids,
  impulsivity_low_ids = impulsivity_low_ids,
  high_iga_impulsivity_ids = ids,
  instagram_ids = instagram_ids,
  facebook_ids = facebook_ids,
  tiktok_ids = tiktok_ids,
  twitter_ids = twitter_ids
), "outputs/models/questionnaires/questionnaire_participant_ids_private.rds")

medians <- data.frame(
  variable = c("impulsivity_total", "addiction_total", "iga_impulsivity_total", "iga_social_effect"),
  median = c(m_impulsivity, m_addiction, m_impulsivity_IGA, m_socialaffect_IGA)
)
readr::write_csv(medians, "outputs/tables/questionnaires/score_medians.csv")

group_counts <- dataLong %>%
  group_by(variable) %>%
  summarise(high = sum(addiction_group == "High", na.rm = TRUE) +
                    sum(impulsivity_group == "High", na.rm = TRUE) +
                    sum(Impulsivity_IGA_group == "High", na.rm = TRUE) +
                    sum(SocialAffect_IGA_group == "High", na.rm = TRUE),
            low = sum(addiction_group == "Low", na.rm = TRUE) +
                   sum(impulsivity_group == "Low", na.rm = TRUE) +
                   sum(Impulsivity_IGA_group == "Low", na.rm = TRUE) +
                   sum(SocialAffect_IGA_group == "Low", na.rm = TRUE),
            .groups = "drop")
readr::write_csv(group_counts, "outputs/tables/questionnaires/median_split_group_counts.csv")
