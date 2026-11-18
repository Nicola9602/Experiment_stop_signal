# Run from project root: Rscript results_review/review_saved_results.R
# Does not read participant-level datasets or refit models.
for (dir in c("reports", "outputs/figures")) dir.create(dir, recursive = TRUE, showWarnings = FALSE)

summary_files <- list.files("outputs/tables", pattern = "[.]csv$", full.names = TRUE, recursive = TRUE)
model_files <- list.files("outputs/models", pattern = "[.]rds$", full.names = TRUE, recursive = TRUE)

report <- c("# Saved analysis results", "",
            "This report is built from previously saved aggregate CSVs and model RDS files.", "",
            "## Available model files", "")
report <- c(report, if (length(model_files)) paste0("- `", model_files, "`") else "No saved models found.", "",
            "## Aggregate tables", "")
for (f in summary_files) {
  x <- utils::read.csv(f, check.names = FALSE)
  report <- c(report, paste0("### ", basename(f)), "",
              paste0("Rows: ", nrow(x), "; columns: ", ncol(x)), "",
              "```", capture.output(print(utils::head(x, 10))), "```", "")
}
report <- c(report, "## Figures", "",
            if (length(list.files("outputs/figures", pattern = "[.]png$", recursive = TRUE)))
              paste0("- `", list.files("outputs/figures", pattern = "[.]png$", recursive = TRUE), "`")
            else "No saved figures found.")
writeLines(report, "reports/saved_results_review.md")
message("Wrote reports/saved_results_review.md")

# Example: load a fitted model without running the original analysis.
model_path <- "outputs/models/go/go_omissions_main.rds"
if (file.exists(model_path)) {
  model <- readRDS(model_path)
  writeLines(capture.output(summary(model)), "reports/go_omissions_model_summary.txt")
}
