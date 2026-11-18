# Source: original/Analysis_go_data_original.R (original order preserved).
# ============================================================
#region Analsysis of the ALL GO trials 
# ============================================================

# Count how many undefined there are
table(df$response)
# Drop the no responses 
df <- df[df$response != 'undefined', ]
sum(is.na(df))


df$condition <- as.factor(df$condition)
df$order <- as.factor(df$order)
df$group <- as.factor(df$group)

model_rt = aov_ez(
    id = 'participant',
    dv = 'rt',
    data = df,
    between = 'group',
    within = 'condition',
    fun_aggregate = mean
)

# Check normality 
res <- residuals(model_rt$lm)
png("outputs/figures/go/all_trial_rt_residual_qq.png", width = 1000, height = 800)
qqnorm(res)
qqline(res)
dev.off()

leveneTest(rt ~ group, data = df)
#by(df$rt, df$group, shapiro.test)

summary(model_rt)

# Simple True Go trials ---
model_go_simple <- lmer(rt ~ condition + (1 | participant), data = df)
anova(model_go_simple)

plot_all_trial_rt_condition_predicted <- plot_model(model_go_simple, type = "pred", terms = c("condition")) +
  labs(
    x = "Priming",
    y = "Rt (ms)",
    title = "Go trials"
  )
ggplot2::ggsave("outputs/figures/go/all_trial_rt_condition_predicted.png", plot = plot_all_trial_rt_condition_predicted, width = 9, height = 5, dpi = 160)

# Calculate effect size # ----
fixef(model_go_simple)
beta <- fixef(model_go_simple)["conditionPoem"]
var_resid <- attr(VarCorr(model_go_simple), "sc")^2
var_subject <- as.numeric(VarCorr(model_go_simple)$participant)
denom <- sqrt(var_resid + var_subject)
d <- beta / denom
d

# Bayes factor ----

# Model without interaction
bf_null_go <- lmBF(
  formula = rt ~ 1 + participant,
  data = df,
  whichRandom = "participant"
)

# Model with interaction  
bf_full_go <- lmBF(
  formula = rt ~ condition,
  data = df,
  whichRandom = "participant"
)

# Bayes factor for interaction
bf <- bf_full_go / bf_null_go

bfnum_go = ifelse(round(as.vector(bf), 2) > 1000, "> 1000", paste0("=",as.character(round(as.vector(bf), 2))))

cat(paste("BF10",bfnum_go,"\n"))

# Normality is not respected therefore go with a mixed model 

model_lmm <- lmer(rt ~ group * condition + (1 | participant), data = df)
summary(model_lmm)
anova(model_lmm, type = 3)

rt_emm <- emmeans(model_lmm, ~ group * condition)
pairs(rt_emm) 
pairs(emmeans(rt_emm, ~ condition | group))
pairs(rt_emm, by = "condition")
pairs(rt_emm, by = "group")



model_lmm_addiction <- lmer(rt ~ addiction * condition * group + (1 | participant), data = df)
summary(model_lmm_addiction)
rt_emm_addiction <- emmeans(model_lmm_addiction , ~ addiction * condition * group, pbkrtest.limit = 14558)
pairs(rt_emm_addiction, by = c("group","addiction"))

model_lmm_impulsivity <- lmer(rt ~ impulsivity * condition * group + (1 | participant), data = df)
summary(model_lmm_impulsivity)

rt_emm_impulsivity <- emmeans(model_lmm_impulsivity , ~ impulsivity * condition * group, pbkrtest.limit = 14558)
pairs(rt_emm_impulsivity, by = c("group","impulsivity"))



saveRDS(model_rt, "outputs/models/go/all_trial_rt_anova.rds")
saveRDS(model_go_simple, "outputs/models/go/all_trial_rt_simple.rds")
saveRDS(model_lmm, "outputs/models/go/all_trial_rt_group_condition.rds")
saveRDS(model_lmm_addiction, "outputs/models/go/all_trial_rt_addiction.rds")
saveRDS(model_lmm_impulsivity, "outputs/models/go/all_trial_rt_impulsivity.rds")
saveRDS(bf, "outputs/models/go/all_trial_rt_bayes_factor.rds")
readr::write_csv(as.data.frame(rt_emm), "outputs/tables/go/all_trial_rt_emmeans.csv")
