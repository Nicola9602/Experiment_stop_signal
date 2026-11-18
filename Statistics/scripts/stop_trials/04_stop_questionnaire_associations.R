# Source: original/Analysis_stop_data_original.R. Statistical code retained.
 #region 4. Correlation with questionnaires 


dfq <- read_csv("data/questionnaire_stop_signal_processed.csv")
dfq <- dfq %>%
  dplyr::mutate(subject = row_number())
names(dfq) <- tolower(names(dfq))

# select only the columns i want 
dfq <- dfq %>%
  dplyr::select(c("subject", "impulsivity_total", "impulsivity_motor",
      "impulsivity_attentional", "impulsivity_nonplanning",            
  "addiction_total","iga_compulsivity_total", "iga_social_effect")) %>%
  dplyr::mutate(subject=as.character(subject))

hist(dfq$impulsivity_total)
hist(dfq$addiction_total)

#plot(dfq$impulsivity_total, dfi$ssrt)


## BEWARE: merging like this duplicates the scores in the questionnaire
# because I have double scores for each person. SO YOU CAN ONLY DO A LM 
# which keeps into account the priming. Othwrwise mean across subject, cancel
# priming effect but you see whether more impulsive is more ssrt etc. 

df <- left_join(dfi, dfq, by = c("subject" = "subject"))

ggplot(df, aes(x = impulsivity_total, y = ssrt)) +
  geom_point() +
  labs(
    x = "Impulsivity Total Score",
    y = "Stop-Signal Reaction Time (ms)",
    title = "Impulsivity and SSRT"
  ) +
  theme_classic()

# Now loop it over all of the impulsivity stuff I care about 

vars <- c(  "impulsivity_total",
  "impulsivity_motor",
  "impulsivity_attentional",
  "impulsivity_nonplanning",
  "addiction_total",
  "iga_compulsivity_total",
  "iga_social_effect"
)

model_results <- list()
for (v in vars) {
  model_result <- lmer(as.formula(paste0("ssrt ~", v, "* order + (1|subject)")), data=df)
  model_results[[v]] <- anova(model_result)
}




results <- map_dfr(vars, function(v){
  formula <- as.formula(paste0("ssrt ~", v, "* order + (1|subject)"))
  model <- lmer(formula, data = df)
  tidy(model,effects="fixed")%>%
  mutate(predictor=v)
})

model_questionnaire <- lmer(ssrt ~ impulsivity_total * order + (1 | subject), data = df )
summary(model_questionnaire)

# Persist existing model outputs; may contain participant-level information (Git ignored).
saveRDS(model_questionnaire, "outputs/models/stop/ssrt_questionnaire_impulsivity_model.rds")
saveRDS(model_results, "outputs/models/stop/ssrt_questionnaire_anova_results.rds")
readr::write_csv(results, "outputs/tables/stop/ssrt_questionnaire_fixed_effects.csv")

