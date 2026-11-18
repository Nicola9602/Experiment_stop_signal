# Source: original/Analysis_go_data_original.R (original order preserved).
# Sanity check 
table(df$participant, df$trial_type)

# ============================================================
#region Analsysis for the amount of ERRORS in STOP TRIALS
# ============================================================
# Get only stop trials 
dfs <- df %>%
  filter(signal == "yes")

#Visualize first
table(dfs$group, dfs$correct)

table(df$group, df$condition, df$trial_type, df$correct)
table(df$participant, df$trial_type, df$correct)


# Transform correct in numeri for further analysis
df$correct <- as.numeric(df$correct)



# Do a within between anova and check normality 
model_error <- aov_ez(
        id = 'participant',
        dv = 'correct',
        data = df,
        between = 'group',
        within = 'condition',
        fun_aggregate = mean
)
summary(model_error)

# Check normality 
model_error <- residuals(model_error$lm)
png("outputs/figures/go/accuracy_residual_qq.png", width = 1000, height = 800)
qqnorm(model_error)
qqline(model_error)
dev.off()

leveneTest(correct ~ group, data = df)

# Normality is not respected therefore go with a mixed model 
# Apparently lmer is problematic bc my output is binary 

model_glmm_error <- glmer(correct ~ group * condition + (1 | participant), data = df, family = binomial)
summary(model_glmm_error)
Anova(model_glmm_error, type = 3)

model_glmmTMB_error <- glmmTMB(correct ~ group * condition + (1 | participant), data = df, family = binomial)
summary(model_glmmTMB_error)



errors_summary <- df %>%
    dplyr::group_by(group, condition, trial_type) %>%
    dplyr::summarise(
        mean_correct = mean(correct, na.rm = TRUE),
        mean_incorrect = 1 - mean_correct)

plot_accuracy_correct <- ggplot(errors_summary, aes(x = condition, y = mean_correct, fill = trial_type)) +
  geom_bar(stat = 'identity', position = position_dodge()) +
  scale_fill_manual(name = "", values = c("stop" = "red", "go" = "blue")) +
  facet_wrap(~group)
ggplot2::ggsave("outputs/figures/go/accuracy_correct.png", plot = plot_accuracy_correct, width = 9, height = 5, dpi = 160)

plot_accuracy_incorrect <- ggplot(errors_summary, aes(x = condition, y = mean_incorrect, fill = trial_type)) +
  geom_bar(stat = 'identity', position = position_dodge()) +
  scale_fill_manual(name = "", values = c("stop" = "red", "go" = "blue")) +
  facet_wrap(~group)
ggplot2::ggsave("outputs/figures/go/accuracy_incorrect.png", plot = plot_accuracy_incorrect, width = 9, height = 5, dpi = 160)



model_glmmTMB_erro_addiction <- glmmTMB(correct ~ addiction * condition + (1 | participant), data = df, family = binomial)
summary(model_glmmTMB_erro_addiction)


model_glmmTMB_erro_impulsivity <- glmmTMB(correct ~ impulsivity * condition + (1 | participant), data = df, family = binomial)
summary(model_glmmTMB_erro_impulsivity)


readr::write_csv(errors_summary, "outputs/tables/go/accuracy_summary.csv")
saveRDS(model_glmm_error, "outputs/models/go/accuracy_glmer.rds")
saveRDS(model_glmmTMB_error, "outputs/models/go/accuracy_glmmtmb.rds")
saveRDS(model_glmmTMB_erro_addiction, "outputs/models/go/accuracy_addiction.rds")
saveRDS(model_glmmTMB_erro_impulsivity, "outputs/models/go/accuracy_impulsivity.rds")
