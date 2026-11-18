# Run once interactively after validating the package environment.
# This is intentionally separate from run_analysis.R.
if (!requireNamespace("renv", quietly = TRUE)) {
  stop("Install renv manually first: install.packages('renv')")
}
renv::init(bare = TRUE)
# Install all packages listed in run_analysis.R manually into this environment.
# Then run: renv::snapshot(prompt = FALSE)
# Commit the generated renv.lock and renv/activate.R.
