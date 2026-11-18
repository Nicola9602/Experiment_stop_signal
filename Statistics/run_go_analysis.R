# Run from the repository root: Rscript run_analysis.R
# No packages are installed automatically. Restore renv first if a lockfile exists.
packages <- c(
  "glmmTMB", "brms", "bayesplot", "projpred", "loo", "BH", "rstan", "pkgbuild",
  "robustlmm", "afex", "dplyr", "readr", "compute.es", "car", "ggplot2",
  "multcomp", "pastecs", "WRS2", "tidyr", "readxl", "DescTools", "knitr",
  "writexl", "rcompanion", "lsr", "lme4", "lmerTest", "rstatix",
  "performance", "emmeans", "effectsize", "sjPlot", "BayesFactor",
  "ggpubr", "ggsignif", "languageserver", "Rmisc"
)

missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing R packages (install outside the analysis run): ", paste(missing, collapse = ", "))
}
invisible(lapply(packages, library, character.only = TRUE))

for (dir in c(file.path("outputs", c("models", "tables", "figures"), rep("go", 3)),
              file.path("outputs", c("models", "tables", "figures"), rep("stop", 3)),
              file.path("outputs", c("models", "tables", "figures"), rep("questionnaires", 3)),
              "reports")) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
}

# Each stage uses objects left by earlier stages, matching the original script.
# SSD trial-level module (01) depends on objects prepared in the Go pipeline.
# The independent Stop-estimation dataset is run with run_stop_analysis.R.
# Questionnaire scripts can be added separately once available.
source("scripts/go_trials/00_prepare_data.R", echo = FALSE)
source("scripts/go_trials/01_go_omissions.R", echo = FALSE)
source("scripts/go_trials/02_response_accuracy.R", echo = FALSE)
source("scripts/go_trials/03_all_trial_rt.R", echo = FALSE)
source("scripts/go_trials/04_go_trial_rt.R", echo = FALSE)
source("scripts/stop_trials/01_stop_signal_delay.R", echo = FALSE)

writeLines(capture.output(sessionInfo()), "reports/session_info.txt")
message("Analysis finished; review outputs/ and reports/.")
