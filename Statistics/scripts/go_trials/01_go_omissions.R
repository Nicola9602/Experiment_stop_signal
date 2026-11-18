# Source: original/Analysis_go_data_original.R (original order preserved).
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

plot_go_omission_counts <- ggplot(go_omission_summary, aes(x = group, y = total_omission, fill = condition)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8), width = 0.8) +
  labs(
    title = "Total Go Omissions by Group and Condition",
    x = "Group",
    y = "Total Go Omissions",
    fill = "condition"
  ) + 
  theme_minimal()
ggplot2::ggsave("outputs/figures/go/go_omission_counts.png", plot = plot_go_omission_counts, width = 9, height = 5, dpi = 160)


model_go_omissions <- glmer(go_omission ~ group + condition + (1 | participant), family = poisson, data = df_go)
summary(model_go_omissions)
anova(model_go_omissions)
confint(model_go_omissions, parm="beta_", method="Wald", level=0.95)
plot_go_omissions_predicted <- plot_model(model_go_omissions, type = "pred", terms = c("condition", "group")) +
  labs(
    x = "Priming",
    y = "Predicted go omissions",
    title = "Go omissions"
  )
ggplot2::ggsave("outputs/figures/go/go_omissions_predicted.png", plot = plot_go_omissions_predicted, width = 9, height = 5, dpi = 160)

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


model_go_omissions_addiction <- glmmTMB(go_omission ~ addiction * condition + (1 | participant), family = poisson, data = df_go)
summary(model_go_omissions_addiction)

model_go_omissions_impulsivity <- glmmTMB(go_omission ~ impulsivity * condition + (1 | participant), family = poisson, data = df_go)
summary(model_go_omissions_impulsivity)

# # Bayesian Statistics
emmeans_go_omissions_impulsivity <- emmeans(model_go_omissions_impulsivity, ~ impulsivity * condition)
pairs(emmeans_go_omissions_impulsivity)
pairs(emmeans_go_omissions_impulsivity, by = "condition", adjust = "tukey")
pairs(emmeans_go_omissions_impulsivity, by = "impulsivity", adjust = "tukey")

#endregion ---

readr::write_csv(go_omission_summary, "outputs/tables/go/go_omission_summary.csv")
saveRDS(model_go_omissions, "outputs/models/go/go_omissions_main.rds")
saveRDS(model_go_omissions_addiction, "outputs/models/go/go_omissions_addiction.rds")
saveRDS(model_go_omissions_impulsivity, "outputs/models/go/go_omissions_impulsivity.rds")
readr::write_csv(as.data.frame(emmeans_go_omission), "outputs/tables/go/go_omissions_emmeans.csv")
