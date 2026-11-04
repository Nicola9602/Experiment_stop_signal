
# Load Libraries ----
pkg <- c(
  "glmmTMB", "brms", "bayesplot", "projpred", "loo", "BH", "rstan", "pkgbuild",
  "robustlmm", "afex", "dplyr", "readr", "compute.es", "car", "ggplot2",
  "multcomp", "pastecs", "WRS2", "tidyr", "readxl", "DescTools", "knitr",
  "writexl", "rcompanion", "lsr", "lme4", "lmerTest", "rstatix",
  "performance", "emmeans", "effectsize", "sjPlot", "bayesplot",
  "BayesFactor", "ggpubr", "ggsignif", "languageserver"
)

lapply(pkg, require, character.only = TRUE)

# Data Preparation ----
#region 1. Data Preparation ---

df <- read_csv("df_total.csv", show_col_types = FALSE)


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

# Go Omission Analysis ----
#region 2. Go Omission Analysis

# Create a go_omission column 

df_go <- df%>%
  filter(signal == "no")%>%
  mutate(go_omission = as.integer(!correct))


#Sum of go omission 
df_go %>%
    group_by(group, condition) %>%
    dplyr::summarise(total_omission = sum(go_omission, na.rm = TRUE))

go_omission_summary <- df_go %>%
    dplyr::group_by(group, condition) %>%
    dplyr::summarise(total_omission = sum(go_omission, na.rm = TRUE)) %>%
    ungroup()

go_omission_summary <- df_go %>%
  dplyr::group_by(group, condition) %>%
  dplyr::summarise(
    total_omission = sum(go_omission, na.rm = TRUE),
    total_trials   = dplyr::n()  # number of rows = number of trials
  ) %>%
  ungroup() %>%
  mutate(
    percent_omission = (total_omission / total_trials) * 100
  )

go_omission_summary$group <- as.factor(go_omission_summary$group)

ggplot(go_omission_summary, aes(x = group, y = total_omission, fill = condition)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8), width = 0.8) +
  labs(
    title = "Total Go Omissions by Group and Condition",
    x = "Group",
    y = "Total Go Omissions",
    fill = "condition"
  ) + 
  theme_minimal()


model_go_omissions <- glmer(go_omission ~ group + condition + (1 | participant), family = poisson, data = df_go)
summary(model_go_omissions)
anova(model_go_omissions)
confint(model_go_omissions, parm="beta_", method="Wald", level=0.95)
plot_model(model_go_omissions, type = "pred", terms = c("condition", "group")) +
  labs(
    x = "Priming",
    y = "Predicted go omissions",
    title = "Go omissions"
  )

# This is if you like the CI in ratio, that is not in log scale. iN ratio they do not 
# cross 0 but cross 1 and it might be useful for count data.
#go_omission_ci_log <- confint(model_go_omissions, parm="beta_", method="Wald", level=0.95)
#go_omission_ci_ratio <- exp(go_omission_ci_log)
#go_omission_ci_ratio

emmeans_go_omission <- emmeans(model_go_omissions, ~ group * condition)
pairs(emmeans_go_omission) 
confint(pairs(emmeans_go_omission), level=0.95)
pairs(emmeans_go_omission, by = "group", adjust = "tukey")
pairs(emmeans_go_omission, by = "group", adjust = "tukey") |> confint(type = "link")
pairs(emmeans_go_omission, by = "condition", adjust = "tukey")
pairs(emmeans_go_omission, by = "condition", adjust = "tukey") |> confint(type = "link")


model_go_omissions_addiction <- glmmTMB(go_omission ~ addiction * condition + (1 | participant), family = poisson, data = df)
summary(model_go_omissions_addiction)

model_go_omissions_impulsivity <- glmmTMB(go_omission ~ impulsivity * condition + (1 | participant), family = poisson, data = df)
summary(model_go_omissions_impulsivity)

# # Bayesian Statistics
emmeans_go_omissions_impulsivity <- emmeans(model_go_omissions_impulsivity, ~ impulsivity * condition)
pairs(emmeans_go_omissions_impulsivity)
pairs(emmeans_go_omissions_impulsivity, by = "condition", adjust = "tukey")
pairs(emmeans_go_omissions_impulsivity, by = "impulsivity", adjust = "tukey")

#endregion ---

# # ============================================================
# df$correct <- as.numeric(df$correct) #Make correct numeric for Bayesian model

# # Create two datasets contianing only the correct and incorrect responses

# df_IG <- df%>%
#     filter(group=="IGFirst") %>%
#     pull(correct)

# df_P <- df%>%
#     filter(group=="PoemFirst") %>%
#     pull(correct)

# # Create the data for Stan

# data = list(y1 = df_IG, y2 = df_P, n = length(df_IG))

# fit = stan(file = 'my_model.stan', data = data) 
# print(fit)
# params <- rstan::extract(fit)
# plot(density(params$theta1))
# lines(density(params$theta2))
# plot(density(params$Delta_theta))

# df <- data.frame(
#   theta1 = params$theta1,
#   theta2 = params$theta2,
#   Delta_theta = params$Delta_theta
# )

# ggplot(df) +
#   geom_density(aes(x = theta1), fill = "blue", alpha = 0.4) +
#   geom_density(aes(x = theta2), fill = "red", alpha = 0.4) +
#   geom_density(aes(x = Delta_theta), fill = "green", alpha = 0.4) +
#   labs(title = "Posterior densities of parameters")

# bayes_model <- brm(
#     correct ~ group * condition * trial_type + (1 + condition | participant),
#     data = df,
#     family = bernoulli(link = "logit"),
#     prior = set_prior("normal(0, 1)", class = "b"),
#     chains = 4,
#     iter = 4000,
#     warmup = 1000,
#     control = list(adapt_delta = 0.95)
# )


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

table(dfs$group, df$condition, df$trial_type, df$correct)
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
qqnorm(model_error)
qqline(model_error)

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

ggplot(errors_summary, aes(x = condition, y = mean_correct, fill = trial_type)) +
  geom_bar(stat = 'identity', position = position_dodge()) +
  scale_fill_manual(name = "", values = c("stop" = "red", "go" = "blue")) +
  facet_wrap(~group)

ggplot(errors_summary, aes(x = condition, y = mean_incorrect, fill = trial_type)) +
  geom_bar(stat = 'identity', position = position_dodge()) +
  scale_fill_manual(name = "", values = c("stop" = "red", "go" = "blue")) +
  facet_wrap(~group)



model_glmmTMB_erro_addiction <- glmmTMB(correct ~ addiction * condition + (1 | participant), data = df, family = binomial)
summary(model_glmmTMB_erro_addiction)


model_glmmTMB_erro_impulsivity <- glmmTMB(correct ~ impulsivity * condition + (1 | participant), data = df, family = binomial)
summary(model_glmmTMB_erro_impulsivity)

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
qqnorm(res)
qqline(res)

leveneTest(rt ~ group, data = df)
by(df$rt, df$group, shapiro.test)

summary(model_rt)

# Simple True Go trials ---
model_go_simple <- lmer(rt ~ condition + (1 | participant), data = df)
anova(model_go_simple)

plot_model(model_go_simple, type = "pred", terms = c("condition")) +
  labs(
    x = "Priming",
    y = "Rt (ms)",
    title = "Go trials"
  )

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


# ============================================================
#region Analsysis of the true GO trials y


dfg <- df[df$trial_type == 'go', ]

# Dropping the ERRORS & No responses 
#--------------------------------------------------

#Count how many False there are
table(df$correct)

# Drop the False responses
dfg = dfg[dfg$correct != 'FALSE', ] 


dfg %>% 
    group_by(group, condition) %>%
    get_summary_stats(rt, type="mean_sd") %>%
    as.data.frame() 
    
df %>%
    group_by(condition, group) %>%
    shapiro_test(rt)


# Some checks 
table(df$group, df$condition)


# ANOVA 
# I want ass between conditions:
# 1. the whole group RT
# 3. Then the group + block, so basically the first block of the first group vs the first block of the second, and same about the second block
# 4. The same block between groups, so ig vs ig and poem vs poem

# And then within I want
# Block vs block in each group.
dfg$condition <- as.factor(dfg$condition)
dfg$order <- as.factor(dfg$order)
dfg$group <- as.factor(dfg$group)



sum(is.na(dfg))
model_rt_dfg = aov_ez(
    id = 'participant',
    dv = 'rt',
    data = dfg,
    between = 'group',
    within = 'condition',
    fun_aggregate = mean
)

# Check normality 
res_dfg <- residuals(model_rt_dfg$lm)
qqnorm(res_dfg)
qqline(res_dfg)

leveneTest(rt ~ group, data = dfg)
summary(model_rt_dfg)

# Normality is not respected therefore go with a mixed model 

model_lmm_dfg <- lmer(rt ~ group * condition + (1 | participant), data = dfg)
summary(model_lmm_dfg)
anova(model_lmm_dfg)
confint(model_lmm_dfg, parm="beta_", method="Wald", level=0.95)
plot_model(model_lmm_dfg, type = "pred", terms = c("condition", "group")) +
  labs(
    x = "Priming",
    y = "RT (ms)",
    title = "RT Go trials"
  )


rt_emm_dfg <- emmeans(model_lmm_dfg, ~ group * condition, pbkrtest.limit = 12471, lmerTest.limit = 12471)
pairs(rt_emm_dfg) 
pairs(emmeans(rt_emm_dfg, ~ condition | group))
pairs(rt_emm_dfg, by = "condition", adjust = "tukey")
pairs(rt_emm_dfg, by = "group", adjust = "tukey")

# Plot with the means 

dfg_subject <- dfg %>%
  dplyr::group_by(participant, condition, group) %>%
  dplyr::summarise(
    rt = mean(rt, na.rm = TRUE),
    .groups = "drop"
  )

summary_dataRT <- summarySE(dfg_subject,
  measurevar = "rt",
  groupvars = c("condition", "group")
) # qui becco CI between, differenza tra gruppi

#png("RT_singletrials.png", width = 1400, height = 700, res = 150)
ggplot(summary_dataRT, aes(x = condition, y = rt, color = group, group = group)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = rt - se, ymax = rt + se),
                width = 0.2,
                position = position_dodge(width = 0.5)) +
  labs(x = 'Content', y = "RT (ms)", color = "Group") +
  theme_minimal()
#dev.off()



# Create a difference scoper per participant RT_change = RT_Block2 - RT_block1
# the check whether instagram boosts them or slows them 
# -------------------------------------------------------

df_change <- dfg %>%
    dplyr::group_by(participant, group, condition_order) %>%
    dplyr::summarise(mean_rt = mean(rt, na.rm = TRUE)) %>% 
    tidyr::pivot_wider(names_from = condition_order, values_from = mean_rt) %>%
    dplyr::mutate(
        rt_change = case_when(
            group == "IGFirst" ~ Poem_second - IG_first,
            group == "PoemFirst" ~ IG_second - Poem_first,
        )
    )
# Robust t-test
yuen(rt_change ~ group, data = df_change, tr= 0.1)

ggplot(df_change, aes(x = group, y = rt_change)) +
    geom_boxplot() +
    labs(title = "RT Change between conditions", x = "Group", y = "RT Change (ms)") +
    theme_minimal()


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

png("SSD_singletrials.png", width = 1400, height = 700, res = 150)
ggplot(summary_dataSSD, aes(x = condition, y = SSD, color = group, group = group)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = SSD - se, ymax = SSD + se),
                width = 0.2,
                position = position_dodge(width = 0.5)) +
  labs(x = 'Content', y = "SSD (ms)", color = "Group") +
  theme_minimal()
dev.off()

# Simple SSD ---
model_ssd_simple <- lmer(SSD ~ condition + (1 | participant), data = df)
anova(model_ssd_simple)

plot_model(model_ssd_simple, type = "pred", terms = c("condition")) +
  labs(
    x = "Priming",
    y = "SSD (ms)",
    title = "SSD"
  )

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
plot_model(model_ssd, type = "pred", terms = c("condition", "group")) +
  labs(
    x = "Priming",
    y = "SSD(ms)",
    title = "Stop Signal Delay"
  ) 

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

