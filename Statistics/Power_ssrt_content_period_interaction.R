library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)

# 1. Read data
df <- read_excel("df_stop_estimation_method.xlsx") %>%
  mutate(subject = as.numeric(subject))

# 2. Put IG and Poem in separate columns
paired <- df %>%
  filter(subject <= 20) %>%
  select(subject, Content, ssrt) %>%
  pivot_wider(
    names_from = Content,
    values_from = ssrt
  ) %>%
  filter(!is.na(IG), !is.na(Poem)) %>%
  mutate(D = IG - Poem)

# 3. Estimate variability of paired differences
sd_diff <- sd(paired$D)

# 4. Define simulation parameters
sample_sizes <- seq(10, 200, by = 10)
effect_sizes <- c(10, 15, 20, 25, 30) # Magnitude difference between groups 
n_sim <- 2000
alpha <- 0.05

set.seed(123)

# 5. Simulate paired t-test power
simulate_power <- function(N, effect_ms) {

  significant <- replicate(n_sim, {

    # Simulate participant-level differences
    # simulate hypothetical participants base on the amount of participants I want (N)
    # then we tell R the imagined difference between IG - Poem (effect_sizes). rnorm allows for variability in the drawing
    # so it won't be always 20 ;) 
    # We set how much individual differences should vary based on the real data (sd_diff), bascially giving it the standard dev 
    # from my participants. 
    D <- rnorm(
      n = N,
      mean = effect_ms,
      sd = sd_diff
    )

    # Perform the same directional t-test
    test <- t.test(
      D,
      mu = 0, # testing against a null HP of zero difference
      alternative = "greater"
    )

    test$p.value < alpha
  })

  mean(significant)
}

# 6. Evaluate all sample sizes and effects
# that is generate a table that contains every combination of N and effect_ms
results <- expand.grid(
  N = sample_sizes,
  effect_ms = effect_sizes
)

# mapply takes the simulate_power function and 'maps' it, that is applies it to each row ef the table
results$power <- mapply(
  simulate_power,
  results$N,
  results$effect_ms
)

# 7. Plot power curves
p <-ggplot(
  results,
  aes(
    x = N,
    y = power,
    color = factor(effect_ms)
  )
) +  # <-- This closes ggplot()
  scale_x_continuous(
    breaks = seq(10, 200, by = 10),
    limits = c(10, 200)
  ) +
  geom_line(linewidth = 1) +
  geom_point() +
  geom_hline(
    yintercept = 0.80,
    linetype = "dashed"
  ) +
  labs(
    x = "Number of participants",
    y = "Statistical power",
    color = "SSRT IG - Poem difference (ms)",
    title = "Power for one-tailed paired t-test"
  ) +
  theme_minimal()

print(p)

ggsave(filename = "power_analysis.png", plot = p, width= 10, height = 6, dpi = 300)
