# Independent questionnaire analysis, from the repository root:
# Rscript run_questionnaire_analysis.R
# No dependencies are installed during execution.
packages <- c("tidyverse", "readxl", "rstatix")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing R packages (install outside analysis): ", paste(missing, collapse = ", "))
invisible(lapply(packages, library, character.only = TRUE))
for (kind in c("models", "tables", "figures")) {
  dir.create(file.path("outputs", kind, "questionnaires"), recursive = TRUE, showWarnings = FALSE)
}
dir.create("reports", recursive = TRUE, showWarnings = FALSE)

source("scripts/questionnaires/00_prepare_questionnaire_data.R", echo = FALSE)
source("scripts/questionnaires/01_questionnaire_descriptives.R", echo = FALSE)
source("scripts/questionnaires/02_questionnaire_groups.R", echo = FALSE)

writeLines(capture.output(sessionInfo()), "reports/questionnaire_session_info.txt")
message("Questionnaire analysis finished. Review outputs/tables/questionnaires/ and outputs/figures/questionnaires/.")
