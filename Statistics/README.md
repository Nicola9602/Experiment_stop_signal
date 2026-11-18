# Go-task behavioral analysis

A reproducible R project for analyzing behavioral Go/Stop trials, focusing on omissions, response accuracy, reaction times (RT), stop-signal delay (SSD), and condition/group comparisons. The workflow is a **structural reorganization** of the supplied research script, not a methodological revision. No numerical results are claimed without the private input dataset.

## Repository structure

```text
run_analysis.R                    # Go-trial and original SSD analysis
run_stop_analysis.R               # Independent Stop-estimation analysis
run_questionnaire_analysis.R      # Independent questionnaire analysis
scripts/
  go_trials/                     # Data preparation, omissions, accuracy, reaction times
    00_prepare_data.R
    01_go_omissions.R
    02_response_accuracy.R
    03_all_trial_rt.R
    04_go_trial_rt.R
  stop_trials/
    00_prepare_stop_data.R       # Stop-estimation dataset preparation
    01_stop_signal_delay.R      # Original SSD trial-level analysis (run_analysis.R)
    02_stop_descriptives.R      # Stop-estimation summaries
    03_stop_integration_method.R # SSRT integration-method analyses
    04_stop_questionnaire_associations.R # SSRT/questionnaire analyses
  questionnaires/                # Questionnaire scores, demographics, and median splits
    00_prepare_questionnaire_data.R
    01_questionnaire_descriptives.R
    02_questionnaire_groups.R
functions/                        # Shared functions for all three analyses
data/                             # Shared private input datasets (ignored by Git)
outputs/
  models/
    go/  stop/  questionnaires/  # Saved models; ignored by Git
  tables/
    go/  stop/  questionnaires/  # Aggregate CSVs
  figures/
    go/  stop/  questionnaires/  # PNG plots
results_review/                   # Review previously saved outputs
reports/                          # Review report and session metadata
original/                         # All three unmodified source scripts
setup_renv.R                      # One-time dependency setup
```

The **folder names** for source code are `go_trials`, `stop_trials`, and `questionnaires`; their corresponding **output folders** are `go`, `stop`, and `questionnaires`. `functions/` and `data/` remain shared. The questionnaire workflow is independent of the Go and Stop scripts and uses the shared private input file `data/questionnaire_stop_signal_processed.csv`.

Three entry points preserve the distinct analysis workflows. `run_analysis.R` executes Go-trial modules followed by `scripts/stop_trials/01_stop_signal_delay.R`, which depends on Go workflow objects. `run_stop_analysis.R` independently executes Stop-estimation modules `00`, `02`, `03`, and `04`. The existing SSD module is numbered `01` as requested but is deliberately **not sourced by** `run_stop_analysis.R`, because it uses a different input dataset and variable definitions.

## Methods retained

- Original participant exclusions (IDs 9, 10, 18, and 19), RT threshold (`rt >= 150`), and original addiction/impulsivity membership lists.
- Poisson mixed models for Go omissions; binomial mixed models for response accuracy; mixed ANOVA and linear mixed models for RT/SSD; Bayes-factor comparisons; estimated marginal means and post-hoc contrasts; robust and classical change-score tests.
- Model formulas, tests, trimming, interaction terms, contrast-adjustment choices, and original analysis stage ordering were not intentionally modified. Existing analytical inconsistencies are documented below rather than silently corrected.

## Setup and execution

1. Install R and required packages **outside** the analysis run. The original package lists are declared in the entry points; `Rmisc` has been included because the original calls `summarySE()`.
2. Put private input datasets in `data/` using the exact names specified in `data/README.md`.
3. From the repository root, run `Rscript run_analysis.R` for the Go + original SSD pipeline, or `Rscript run_stop_analysis.R` for the independent Stop-estimation and questionnaire-association analysis, or `Rscript run_questionnaire_analysis.R` for the questionnaire demographic summaries, score distributions, and original median-split groups. They do not need to be run together.
4. Run `Rscript results_review/review_saved_results.R` to inspect saved files without rerunning statistical fits. The script writes a readable Markdown report to `reports/saved_results_review.md`.

**Dependency reproducibility:** `setup_renv.R` provides the one-time renv setup. Because the source did not come with a package-version record and R is not available in the packaging environment, a *verified* `renv.lock` cannot be generated here. After installing and confirming packages locally, run `renv::snapshot(prompt = FALSE)` and commit the generated `renv.lock` and `renv/activate.R`. There is no automatic installation in `run_analysis.R`.

## Outputs and privacy

`outputs/models/go/`, `outputs/models/stop/`, and `outputs/models/questionnaires/` store model or participant-level `.rds` objects locally and are ignored by Git, since fitted objects may embed participant-level data. `outputs/tables/{go,stop,questionnaires}/` contains aggregate CSV outputs and `outputs/figures/{go,stop,questionnaires}/` contains PNG figures; review both for small cells or disclosure risk before committing. `reports/` includes a saved-results inventory across output subfolders; `reports/session_info.txt` is ignored because it may reveal local paths or environment details.

## Issues already present in the original script (scientific review required)

These are **not corrected**, to avoid changing scientific choices without approval:

1. In Go omission subgroup models, `data = df` is used, although `go_omission` is created in `df_go` only. This likely stops the workflow at `scripts/go_trials/01_go_omissions.R`. Do not switch the data source without verifying the intended analytic sample.
2. In the accuracy stage, `table(dfs$group, df$condition, df$trial_type, df$correct)` combines a filtered vector with unfiltered vectors, which can error due to different lengths. The displayed section says stop-trial errors, but most models use all of `df`; the original selection was retained.
3. In Go-only RT, `correct` has already been cast to numeric; filtering `dfg$correct != 'FALSE'` may not have the intended effect. Also confirm the original numeric coding of `correct` before interpreting binomial models.
4. The script comments refer to filtering SSRT below 150 ms, but the actual code filters `rt`. The code (not the comment) is preserved.
5. The SSD summary and SSD models operate on `df` while an adjacent comment refers to stop-only trials. The model sample was not changed. The SSD descriptive plot also uses `dfg` (Go trials).
6. `summarySE()` requires `Rmisc`, absent from the original dependency list. `Rmisc` is now explicitly loaded, without changing the calls.
7. Model summaries and diagnostic printouts that were previously displayed interactively may be hidden when sourcing; saved objects can be reviewed using the review script. Group IDs and source code comments should undergo a privacy review prior to making the repository public.

The unchanged scripts are preserved in `original/Analysis_go_data_original.R` and `original/Analysis_stop_data_original.R`, including a commented-out Bayesian/Stan exploration which is not run by the main workflow.

## New Stop-estimation script: original methodology and open issues

The second uploaded script was split at its original section boundaries (data preparation, descriptive statistics, integration-method comparisons, and questionnaire associations). Its participant lists, filtering `ssrt >= 150`, pairing, `t.test()` alternatives, `lmer()` formulas, and original predictors were kept. Its plots and aggregate descriptions are saved under `outputs/figures/stop/` and `outputs/tables/stop/`; questionnaire-associated model objects remain private under `outputs/models/stop/`. The correlation code stays under `stop_trials/` because it is the supplied Stop-SSRT analysis, not a separate standalone questionnaire project.

**Pre-existing points to review before a full run:** The original questionnaire models use `Order` even though the data columns were lowercased using `names(dfi) <- tolower(names(dfi))` (potential missing variable). `tidy()` for `lmer` objects needs `broom.mixed` (explicitly loaded now). The original `plot(dfq$impulsivity_total, dfi$ssrt)` may have unequal vector lengths. `pivot_wider()` by subject/condition may create list columns if there are repeated values. The comment about omitted participants and the filter counts mix rows and participants. Questionnaire subject identifiers are generated by row number, requiring careful alignment with the Stop data. These are flagged, **not silently changed**. No model fits were tested because the private input files and a working R environment were not provided.

## Standalone questionnaire analysis

The third uploaded script is preserved verbatim as `original/Questionnaire_analysis_original.R`. Its analysis is organized into three stages: reading and excluding participants, descriptive summaries/figures, and median-split questionnaire group assignments plus social-platform ID lists. Run with `Rscript run_questionnaire_analysis.R` from the project root. The expected input is `data/questionnaire_stop_signal_processed.csv`. It is not necessary to run the Go or Stop analyses first.

Published-safe **candidate** summaries (age, age by sex, social-platform counts, score medians, median-split counts) are written to `outputs/tables/questionnaires/`, and the original two plot types to `outputs/figures/questionnaires/`. Check aggregate small-cell disclosure before publication. Participant-level questionnaire group assignments and platform/score group ID lists are saved only to ignored RDS files under `outputs/models/questionnaires/`; they must not be committed. The standalone questionnaire script fits no statistical models, so no new models were invented.

**Scientific review flags:** The original median calculations do not set `na.rm = TRUE`; missing scores can yield missing medians and group assignments. The script excludes IDs via `ResponseId`, which must be verified against the underlying questionnaire file's ID type/meaning and the ID conventions of the other pipelines. Median ties are assigned to High using `>=`, as in the source. The IGA high-ID selection uses `>` (not `>=`) in the original and is intentionally preserved. The script originally prints participant ID lists; only private RDS saves were added for the automated pipeline. The historic hardcoded Go/Stop subgroup lists are not recalculated using these questionnaire results, because that would modify their scientific definitions.
