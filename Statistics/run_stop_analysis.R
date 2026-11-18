# Independent stop-estimation analysis, from the repository root:
# Rscript run_stop_analysis.R
# Does not install dependencies or run the Go-trial pipeline.
packages <- c(
  "afex", "bayesplot", "BayesFactor", "brms", "car", "compute.es",
  "DescTools", "DHARMa", "dplyr", "emmeans", "ggplot2", "glmmTMB",
  "knitr", "lme4", "lmerTest", "lsr", "multcomp", "pastecs",
  "pkgbuild", "readr", "readxl", "rcompanion", "robustlmm",
  "rstatix", "sjPlot", "tidyr", "WRS2", "writexl", "Rmisc",
  "effectsize", "purrr", "broom.mixed"
)
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing R packages (install outside analysis): ", paste(missing, collapse = ", "))
invisible(lapply(packages, library, character.only = TRUE))
for (kind in c("models", "tables", "figures")) {
  dir.create(file.path("outputs", kind, "stop"), recursive = TRUE, showWarnings = FALSE)
}
dir.create("reports", showWarnings = FALSE, recursive = TRUE)

source("scripts/stop_trials/00_prepare_stop_data.R", echo = FALSE)
source("scripts/stop_trials/02_stop_descriptives.R", echo = FALSE)
source("scripts/stop_trials/03_stop_integration_method.R", echo = FALSE)
source("scripts/stop_trials/04_stop_questionnaire_associations.R", echo = FALSE)

writeLines(capture.output(sessionInfo()), "reports/stop_session_info.txt")
message("Stop-estimation analysis finished. Review outputs/ and reports/.")
