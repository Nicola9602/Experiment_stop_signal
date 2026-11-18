# Original questionnaire descriptive statistics and plots.
age_summary <- dfq %>% get_summary_stats(Age, type = "mean_sd")
age_by_sex <- dfq %>%
    group_by(Sex) %>%
    get_summary_stats(Age, type = "mean_sd")
social_counts <- as.data.frame(table(dfq$Social))
names(social_counts) <- c("social", "n")

readr::write_csv(age_summary, "outputs/tables/questionnaires/age_summary.csv")
readr::write_csv(age_by_sex, "outputs/tables/questionnaires/age_by_sex.csv")
readr::write_csv(social_counts, "outputs/tables/questionnaires/social_platform_counts.csv")

p_addiction_distribution <- dataLong %>%
  filter(variable == "addiction_total") %>%
  ggplot(aes(x = score)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "white") +
  labs(title = "Distribution of Addiction Total Scores",
       x = "Addiction Total Score",
       y = "Count")

p_questionnaire_scores <- ggplot(dataLong, aes(x = variable, y = score)) +
    geom_point()

ggplot2::ggsave("outputs/figures/questionnaires/addiction_score_distribution.png", p_addiction_distribution, width = 8, height = 5)
ggplot2::ggsave("outputs/figures/questionnaires/questionnaire_scores.png", p_questionnaire_scores, width = 8, height = 5)
