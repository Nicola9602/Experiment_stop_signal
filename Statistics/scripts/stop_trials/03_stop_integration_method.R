# Source: original/Analysis_stop_data_original.R. Statistical code retained.
#region 3. Integration Method 

#region 3.1 SSRT
# Plotting SSRT means
#--------------------------------------------------

summary_dataSSRT <- summarySE(dfi,
  measurevar = "ssrt",
  groupvars = c("content", "group")
) # qui becco CI between, differenza tra gruppi

#png("SSRT_integration.png", width = 1400, height = 700, res = 150)
plot_ssrt_integration <- ggplot(summary_dataSSRT, aes(x = content, y = ssrt, color = group, group = group)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = ssrt - se, ymax = ssrt + se),
                width = 0.2,
                position = position_dodge(width = 0.5)) +
  labs(x = 'Content', y = "SSRT (ms)", color = "Group") +
  theme_minimal()
#

plot_ssrt_density <- ggplot(dfi, aes(x = ssrt, color = group, fill= group)) +
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
#

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



plot_usrt_integration <- ggplot(summary_dataUSRT, aes(x = content, y = usrt, color = group, group = group)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = usrt - se, ymax = usrt + se),
                width = 0.2,
                position = position_dodge(width = 0.5)) +
  labs(x = 'Content', y = "usrt (ms)", color = "Group") +
  theme_minimal()


 


# Save existing visualizations and statistical estimates without modifying tests.
ggplot2::ggsave("outputs/figures/stop/ssrt_integration_means.png", plot_ssrt_integration, width = 9, height = 5, dpi = 160)
ggplot2::ggsave("outputs/figures/stop/ssrt_integration_density.png", plot_ssrt_density, width = 9, height = 5, dpi = 160)
ggplot2::ggsave("outputs/figures/stop/usrt_integration_means.png", plot_usrt_integration, width = 1400 / 150, height = 700 / 150, dpi = 150)
readr::write_csv(summary_dataSSRT, "outputs/tables/stop/ssrt_integration_plot_summary.csv")
readr::write_csv(summary_dataUSRT, "outputs/tables/stop/usrt_integration_plot_summary.csv")

