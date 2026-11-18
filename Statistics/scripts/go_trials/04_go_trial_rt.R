# Source: original/Analysis_go_data_original.R (original order preserved).
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
    
# df %>%
#     group_by(condition, group) %>%
#     shapiro_test(rt)


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
png("outputs/figures/go/go_trial_rt_residual_qq.png", width = 1000, height = 800)
qqnorm(res_dfg)
qqline(res_dfg)
dev.off()

leveneTest(rt ~ group, data = dfg)
summary(model_rt_dfg)

# Normality is not respected therefore go with a mixed model 

model_lmm_dfg <- lmer(rt ~ group * condition + (1 | participant), data = dfg)
summary(model_lmm_dfg)
anova(model_lmm_dfg)
confint(model_lmm_dfg, parm="beta_", method="Wald", level=0.95)
plot_go_trial_rt_predicted <- plot_model(model_lmm_dfg, type = "pred", terms = c("condition", "group")) +
  labs(
    x = "Priming",
    y = "RT (ms)",
    title = "RT Go trials"
  )
ggplot2::ggsave("outputs/figures/go/go_trial_rt_predicted.png", plot = plot_go_trial_rt_predicted, width = 9, height = 5, dpi = 160)


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
plot_go_trial_rt_means <- ggplot(summary_dataRT, aes(x = condition, y = rt, color = group, group = group)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = rt - se, ymax = rt + se),
                width = 0.2,
                position = position_dodge(width = 0.5)) +
  labs(x = 'Content', y = "RT (ms)", color = "Group") +
  theme_minimal()
ggplot2::ggsave("outputs/figures/go/go_trial_rt_means.png", plot = plot_go_trial_rt_means, width = 9, height = 5, dpi = 160)
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

plot_go_trial_rt_change <- ggplot(df_change, aes(x = group, y = rt_change)) +
    geom_boxplot() +
    labs(title = "RT Change between conditions", x = "Group", y = "RT Change (ms)") +
    theme_minimal()
ggplot2::ggsave("outputs/figures/go/go_trial_rt_change.png", plot = plot_go_trial_rt_change, width = 9, height = 5, dpi = 160)



saveRDS(model_rt_dfg, "outputs/models/go/go_trial_rt_anova.rds")
saveRDS(model_lmm_dfg, "outputs/models/go/go_trial_rt_mixed.rds")
readr::write_csv(as.data.frame(rt_emm_dfg), "outputs/tables/go/go_trial_rt_emmeans.csv")
readr::write_csv(summary_dataRT, "outputs/tables/go/go_trial_rt_plot_summary.csv")
# Participant-level change scores deliberately remain local and are not exported.
