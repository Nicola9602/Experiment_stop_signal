# Libraries ----

pkg <- c(
  "afex", "bayesplot", "BayesFactor", "brms", "car", "compute.es",
  "DescTools", "DHARMa", "dplyr", "emmeans", "ggplot2", "glmmTMB",
  "knitr", "lme4", "lmerTest", "lsr", "multcomp", "pastecs",
  "pkgbuild", "readr", "readxl", "rcompanion", "robustlmm",
  "rstatix", "sjPlot", "tidyr", "WRS2", "writexl", "Rmisc", "effectsize", "purrr"
)

# install.packages(pkg, dependencies = TRUE)
lapply(pkg, require, character.only = TRUE)

# Load Dataset and Data preparation ----
dfi <- read_excel('df_stop_estimation_method.xlsx')

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


# Descriptive statistics ----

#region 2. Descriptive statistics ----

# Summary statistics for SSRT 

dfi %>%
    group_by(group, content) %>%
    get_summary_stats(ssrt, type="mean_sd") %>%
    as.data.frame()

# Summary for SSD

dfi %>%
  group_by(group, content) %>%
  get_summary_stats(ssd, type = "mean_sd")

dfi %>% 
  group_by(group) %>%
  get_summary_stats(ssd, type="mean_sd")

# Summary statistics for rt in incorrect trials so failed stop responses

dfi %>%
  group_by(group, content) %>%
  get_summary_stats(usrt, type="mean_sd") %>%
  as.data.frame()

dfi %>%
  group_by(group) %>%
  get_summary_stats(usrt, type="mean_sd") %>%
  as.data.frame()

# Summary statistics for rt in go correct
dfi %>%
  group_by(group, content) %>%
  get_summary_stats(gort_correct, type="mean_sd") %>%
  as.data.frame()

dfi %>%
  group_by(group) %>%
  get_summary_stats(gort_correct, type="mean_sd") %>%
  as.data.frame()
  
# Summary statistics for p resp 

dfi %>%
  group_by(group, content) %>%
  get_summary_stats(presp, type = "mean_sd")

# Summary for go omission 

dfi %>%
  group_by(group, content) %>%
  get_summary_stats(go_omission, type ="mean_sd")

# Summary for go error
dfi %>%
  group_by(group, content) %>%
  get_summary_stats(go_error, type ="mean_sd")

#endregion ----



#region 3. Integration Method 







#region 3.1 SSRT
# Plotting SSRT means
#--------------------------------------------------

summary_dataSSRT <- summarySE(dfi,
  measurevar = "ssrt",
  groupvars = c("content", "group")
) # qui becco CI between, differenza tra gruppi

#png("SSRT_integration.png", width = 1400, height = 700, res = 150)
ggplot(summary_dataSSRT, aes(x = content, y = ssrt, color = group, group = group)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = ssrt - se, ymax = ssrt + se),
                width = 0.2,
                position = position_dodge(width = 0.5)) +
  labs(x = 'Content', y = "SSRT (ms)", color = "Group") +
  theme_minimal()
#dev.off()

ggplot(dfi, aes(x = ssrt, color = group, fill= group)) +
  geom_density(alpha = 0.3) +
  theme_minimal() +
  labs(title = "Integration Method Density plot of SSRT by Group", x = "SSRT (ms)", y = "Density") +
  xlim(100, 400)


# Check normality & homogeneity 
# ===============================================
# 2. Inspect QQ plots
# 3. Optionally run Shapiro-Wilk
# 4. Run Levene's test
# 5. Run Welch's t-test


# QQplots
#png("qqplots.png", width = 1400, height = 700, res = 150)
par(mfrow = c(1,2)) # Plot them side by side 

qqnorm(dfi$ssrt[dfi$condition_general == levels(factor(dfi$condition_general))[1]])
qqline(dfi$ssrt[dfi$condition_general == levels(factor(dfi$condition_general))[1]])

qqnorm(dfi$ssrt[dfi$condition_general == levels(factor(dfi$condition_general))[2]])
qqline(dfi$ssrt[dfi$condition_general == levels(factor(dfi$condition_general))[2]])
#dev.off()

# Shapiro for normality 
dfi %>%
  group_by(condition_general) %>%
  shapiro_test(ssrt)


# Levene for homogeneity 
leveneTest(ssrt ~ condition_general, data = dfi)

# Statistics ----

# Prepare it for a paired t-test
dfiw <- dfi %>%
  select(subject, condition_general, ssrt) %>%
  pivot_wider(
    names_from = condition_general,
    values_from = ssrt
  )

t.test(dfiw$IG, dfiw$Poem,
      paired = TRUE,
      alternative = "two.sided"
      )

t.test(dfiw$IG, dfiw$Poem,
      paired = TRUE,
      alternative = "greater"
      )



#region 3.2 Errors

summary_dataUSRT <- summarySE(dfi,
  measurevar = "usrt",
  groupvars = c("content", "group")
) # qui becco CI between, differenza tra gruppi

png("SSD_integration.png", width = 1400, height = 700, res = 150)

ggplot(summary_dataUSRT, aes(x = content, y = usrt, color = group, group = group)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = usrt - se, ymax = usrt + se),
                width = 0.2,
                position = position_dodge(width = 0.5)) +
  labs(x = 'Content', y = "usrt (ms)", color = "Group") +
  theme_minimal()

dev.off()
 


 #region 4. Correlation with questionnaires 


dfq <- read_csv("questionnaire_stop_signal_processed.csv")
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

plot(dfq$impulsivity_total, dfi$ssrt)


## BEWARE: merging like this duplicates the scores in the questionnaire
# because I have double scores for each person. SO YOU CAN ONLY DO A LM 
# which keeps into account the priming. Othwrwise mean across subject, cancel
# priming effect but you see whether more impulsive is more ssrt etc. 

df <- left_join(dfi, dfq, by = c("subject" = "subject"))

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
  model_result <- lmer(as.formula(paste0("ssrt ~", v, "* Order + (1|subject)")), data=df)
  model_results[[v]] <- anova(model_result)
}




results <- map_dfr(vars, function(v){
  formula <- as.formula(paste0("ssrt ~", v, "* Order + (1|subject)"))
  model <- lmer(formula, data = df)
  tidy(model,effects="fixed")%>%
  mutate(predictor=v)
})

model_questionnaire <- lmer(ssrt ~ impulsivity_total * Order + (1 | subject), data = df )
summary(model_questionnaire)
