# Source: original/Analysis_go_data_original.R (original order preserved).
# ===========================================================
#region Summary stat for SSD in stop trials
# ===========================================================


########## IMPORTANT RUN THIS TO ONLY SELECT THE TRIALS WITH A VALID SSD
df %>%
    filter(signal == "yes") %>%
    group_by(group, condition) %>%
    get_summary_stats(SSD, type = "mean_sd")

summary_data_ssd <- df %>%
    group_by(group, condition) %>%
    get_summary_stats(SSD, type = "mean_sd") %>%
    ungroup()

summary_data_ssd <- summary_data_ssd %>%
  mutate(
    se = sd / sqrt(n),
    ci_width = qt(0.975, df = n - 1) * se
  )


# Plots with SE
dfg_subject_SSD <- dfg %>%
  dplyr::group_by(participant, condition, group) %>%
  dplyr::summarise(
    SSD = mean(SSD, na.rm = TRUE),
    .groups = "drop"
  )

summary_dataSSD <- summarySE(dfg_subject_SSD,
  measurevar = "SSD",
  groupvars = c("condition", "group")
) # qui becco CI between, differenza tra gruppi

plot_ssd_means <- ggplot(summary_dataSSD, aes(x = condition, y = SSD, color = group, group = group)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = SSD - se, ymax = SSD + se),
                width = 0.2,
                position = position_dodge(width = 0.5)) +
  labs(x = 'Content', y = "SSD (ms)", color = "Group") +
  theme_minimal()
ggplot2::ggsave("outputs/figures/stop/ssd_means.png", plot = plot_ssd_means, width = 1400 / 150, height = 700 / 150, dpi = 150)

# Simple SSD ---
model_ssd_simple <- lmer(SSD ~ condition + (1 | participant), data = df)
anova(model_ssd_simple)

plot_ssd_simple_predicted <- plot_model(model_ssd_simple, type = "pred", terms = c("condition")) +
  labs(
    x = "Priming",
    y = "SSD (ms)",
    title = "SSD"
  )
ggplot2::ggsave("outputs/figures/stop/ssd_simple_predicted.png", plot = plot_ssd_simple_predicted, width = 9, height = 5, dpi = 160)

# Calculate effect size # ----
fixef(model_ssd_simple)
beta <- fixef(model_ssd_simple)["conditionPoem"]
var_resid <- attr(VarCorr(model_ssd_simple), "sc")^2
var_subject <- as.numeric(VarCorr(model_ssd_simple)$participant)
denom <- sqrt(var_resid + var_subject)
d <- beta / denom
d

# Bayes factor ----

# Model without interaction
bf_null_SSD <- lmBF(
  formula = SSD ~ 1 + participant,
  data = df,
  whichRandom = "participant"
)

# Model with interaction  
bf_full_SSD <- lmBF(
  formula = SSD ~ condition,
  data = df,
  whichRandom = "participant"
)

# Bayes factor for interaction
bf <- bf_full_SSD / bf_null_SSD

bfnum_SSD = ifelse(round(as.vector(bf), 2) > 1000, "> 1000", paste0("=",as.character(round(as.vector(bf), 2))))

cat(paste("BF10",bfnum_SSD,"\n"))


model_ssd <- lmer(SSD ~ group * condition + (1 | participant), data = df)
summary(model_ssd)
anova(model_ssd)
confint(model_ssd, parm="beta_", method="Wald", level=0.95)
plot_ssd_group_condition_predicted <- plot_model(model_ssd, type = "pred", terms = c("condition", "group")) +
  labs(
    x = "Priming",
    y = "SSD(ms)",
    title = "Stop Signal Delay"
  )
ggplot2::ggsave("outputs/figures/stop/ssd_group_condition_predicted.png", plot = plot_ssd_group_condition_predicted, width = 9, height = 5, dpi = 160) 

ssd_emm <- emmeans(model_ssd, ~ group * condition, pbkrtest.limit = 16887)
pairs(ssd_emm)
confint(pairs(ssd_emm), level=0.95)
pairs(ssd_emm, by = "group", adjust = "tukey")
pairs(ssd_emm, by = "condition", adjust = "tukey")


# Create a SSD change score per participant SSD_change

df_ssd_change <- df %>%
  filter(signal == "yes") %>%
  dplyr::group_by(participant, group, condition_order) %>%
  dplyr::summarise(mean_ssd = mean(SSD, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = condition_order, values_from = mean_ssd) %>%
  mutate(
    ssd_change = case_when(
      group == "IGFirst" ~ Poem_second - IG_first,
      group == "PoemFirst" ~ IG_second - Poem_first,
    )
  )

df_ssd_change$ssd_change <- as.numeric(df_ssd_change$ssd_change)
df_ssd_change$group <- as.factor(df_ssd_change$group)


shapiro.test(df_ssd_change$ssd_change)
leveneTest(ssd_change ~ group, data = df_ssd_change)


ssd_change_model <- lm(ssd_change ~ group, data = df_ssd_change)
summary(ssd_change_model)


t.test(ssd_change ~ group, data = df_ssd_change)
cohen_result <- cohens_d(data = df_ssd_change, ssd_change ~ group)
print(cohen_result)

bf <- ttestBF(x = df_ssd_change$ssd_change[df_ssd_change$group=='PoemFirst'], 
              y = df_ssd_change$ssd_change[df_ssd_change$group=='IGFirst'], 
              nullInterval = c(-Inf, 0))
print(bf)


saveRDS(model_ssd_simple, "outputs/models/stop/ssd_simple.rds")
saveRDS(model_ssd, "outputs/models/stop/ssd_group_condition.rds")
saveRDS(ssd_change_model, "outputs/models/stop/ssd_change_model.rds")
saveRDS(bf, "outputs/models/stop/ssd_change_bayes_factor.rds")
readr::write_csv(summary_data_ssd, "outputs/tables/stop/ssd_summary.csv")
readr::write_csv(summary_dataSSD, "outputs/tables/stop/ssd_plot_summary.csv")
readr::write_csv(as.data.frame(ssd_emm), "outputs/tables/stop/ssd_emmeans.csv")
