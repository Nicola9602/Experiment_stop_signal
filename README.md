# Stop-signal task: data preparation, questionnaires, and statistical analyses

This repository documents the processing and analysis of a stop-signal task comparing Instagram-related (IG) and poem-related content, including experimental order/period, Go and Stop performance, and individual differences in impulsivity and problematic social-media use. Python scripts prepare the raw exports and questionnaire scores; R scripts conduct descriptive analyses, mixed-effects modelling, and a simulation-based power analysis.

**Research data are not included.** Raw task records, questionnaire answers, participant-level processed tables, and private logs must be obtained through authorized access. This README documents the existing code; it does not establish that all analytical sections run without errors or that the underlying scientific decisions have been independently validated.

## Workflow and files

| Stage | File | Purpose | Main input/output |
| --- | --- | --- | --- |
| 1. Task preparation | `data_preparation.py` | Consolidate individual SST records; prepare Go/Stop summaries, alternative SSRT datasets and BEEST inputs | `Data/SST*.csv`, `stop_individual_data.csv`, `stop_beest_data.csv` → multiple CSV/XLSX files |
| 2. Questionnaire preparation | `questionnaires_cleaning.py` | Rename and score impulsivity and Instagram-addiction questionnaire items | `questionnaire_stop_signal.xlsx` → `questionnaire_stop_signal_processed.csv` |
| 3. Questionnaire exploration | `Questionnaire_analysis.r` | Descriptives, median-split group definitions, and social-platform participant lists | Processed questionnaire CSV |
| 4. Trial-level behaviour | `Analysis_go_data(3).r` | Go omissions, accuracy, response time, stop-trial error exploration and SSD comparisons | `df_total.csv` |
| 5. Stop-signal estimates | `Analysis_stop_data(1).r` | SSRT, SSD, unsuccessful-stop RT, Go RT, error summaries and questionnaire associations | `df_stop_estimation_method.xlsx`, questionnaire CSV |
| 6. Power | `Power_ssrt_content_period_interaction.R` | Simulate power for a directional paired IG-minus-Poem SSRT difference | `df_stop_estimation_method.xlsx` → `power_analysis.png` |

**Naming note:** The power script's filename mentions a *content–period interaction*, but its implemented simulation tests a **one-sided paired content difference** (`IG - Poem`), not an interaction model. The distinction matters when interpreting the power curves.

## 1. Task-data preparation (`data_preparation.py`)

This is the repeatable Python conversion of `Data_preparation(3).ipynb`. The original notebook remains an exploratory record; the script contains the cleaning and export sequence. Six original helper functions are maintained in separate Python modules and imported by the main script.

### Input data and execution

- `Data/SST*.csv`: one or more original trial exports matching the expected filename pattern.
- `stop_individual_data.csv`: original input for the SSRT estimation-method branch.
- `stop_beest_data.csv`: input for the external BEEST-processing branch.

Requires **Python 3.10+** and the packages in the relevant Python `requirements.txt`:

```bash
python -m pip install -r requirements.txt
python data_preparation.py
```

To specify file locations:

```bash
python data_preparation.py --data-dir path/to/Data --estimation-file path/to/stop_individual_data.csv --beest-file path/to/stop_beest_data.csv --output-dir results
```

The script produces `df_total.csv`, `df_stop.xlsx`, `df_go.xlsx`, `df_ssrt_mean_method.csv`, `summary_stats.csv`, `df_stop_estimation_method.xlsx`, `BEEST_data.csv`, `BEEST_data_sorted.csv`, and `stop_beest_data_cleaned.csv`, plus plots for inhibition success, trial summaries, reaction time after a stop trial, the RT distribution, and a Q-Q diagnostic. By default outputs are placed in `output/`; files may be overwritten on rerun.

**Original processing decisions retained:** RT filtering of strictly >150 and <1250 ms; participant 24 excluded only in the mean-method branch; alternating-pair subject-ID reassignment in the estimation-method input; existing practice-trial handling and missing-value/sentinel rules in the BEEST branches, including the expected `range(1, 77)` subject range. These choices are carried over from the notebook, not newly justified by this README.

The conversion was previously checked for Python syntax and against synthetic test inputs, but **not** against the private original dataset. The original statsmodels Q-Q plotting branch was not fully exercised in that check.

## 2. Questionnaire preparation (`questionnaires_cleaning.py`)

This script is the reproducible Python version of `Questionnaires_cleaning.ipynb`. It keeps the original item mappings, scoring calculations, and outlier flags; notebook displays and diagnostic printing are excluded from the runnable pipeline.

```bash
python questionnaires_cleaning.py --input data/questionnaire_stop_signal.xlsx --output outputs/questionnaire_stop_signal_processed.csv
```

Without arguments, it expects `questionnaire_stop_signal.xlsx` in the working directory and writes `questionnaire_stop_signal_processed.csv`. The reusable `invert_scale()` function lives in `functions/invert_scale.py` and applies `max_val + min_val - score` to selected items.

Processing: rename Q9/Q10 items to their impulsivity/addiction variable labels; coerce item responses to numeric; reverse-code the specified items on the original **1–4** scale; calculate `impulsivity_total`, `addiction_total`, `IGA_compulsivity_total`, and `IGA_social_effect`; drop the first data row as in the original export; compute upper-tail flags for values more than 2 or 3 standard deviations above the sample mean; export the scored table. The script **flags but does not remove** outliers.

The first-row removal, column-name-based item selection, and pandas missing-value summation behaviour remain as originally coded. In particular, an all-missing set of questionnaire items may produce a zero sum. Confirm the scoring and missing-item rules against each scale's intended protocol before drawing conclusions.

## Notebook versus Python script

The `.ipynb` notebooks preserve the chronological exploration: inspections, intermediate tables, decisions, and visual checks. The `.py` files are intended to be the repeatable, ordered transformations for researchers with authorized access to the original data. Keeping both is reasonable, but **the Python scripts should be treated as the reference execution path** after their outputs have been checked against the original notebooks. Clear saved notebook outputs before publishing: an `.ipynb` can embed participant-level tables even when no private CSV or Excel file is committed.

## 3. Statistical analyses in R

Run the R scripts only after the relevant private Python outputs are available. The sections below follow the contents of the uploaded scripts; they are not presented as fully validated automated pipelines.

### `Questionnaire_analysis.r`: questionnaire descriptives and groups

This short exploratory script loads `questionnaire_stop_signal_processed.csv`, excludes the listed problematic IDs **9, 10, 18, and 19**, and inspects demographic variables (age, sex and main social platform) and distributions of questionnaire totals. It reshapes the four principal scores into long form (`impulsivity_total`, `addiction_total`, `iga_impulsivity_total`, `iga_social_effect`), calculates sample medians and assigns **High** or **Low** labels for each scale. It then extracts participant-ID lists for the median groups and platform-specific participant lists (Instagram, Facebook, TikTok, Twitter).

The median groups are **sample-dependent exploratory categorizations**, not clinical cutoffs. Participants exactly at a median enter the High group under the current `>=` rule; the separate `high_iga_impulsivity_participants` calculation uses a strict `>` comparison. Those are different selection rules and should not be conflated. No analysis model is fitted in this file.

### `Analysis_go_data.r`: trial-level Go/Stop outcomes

The largest trial-level analysis script reads `df_total.csv`, assigns addiction/impulsivity labels from hard-coded participant-ID lists, and removes the specified problematic participants. It also filters RTs below **150 ms**. Its main stages are:

1. **Data checks:** recode group, experimental condition and participant as factors; display condition balance and participant demographics.
2. **Go omissions:** select trials without a stop signal (`signal == "no"`), derive an omission indicator from `correct`, tabulate omission counts/percentages by group and condition, and fit a mixed model plus marginal-mean contrasts. Additional addiction/impulsivity models are attempted.
3. **Accuracy and errors:** inspect correctness by group, condition and trial type; compare an ANOVA approach with binomial mixed-effects models; plot observed correct/incorrect proportions.
4. **Reaction times:** inspect response codes, remove undefined responses, examine RT assumptions, and fit condition/group mixed-effects models. Calculate an illustrative standardized effect and a Bayes-factor comparison for a simpler condition effect.
5. **Correct Go trials:** isolate Go trials and intended correct responses; fit a mixed model for RT, estimate marginal contrasts and plot participant-aggregated RT summaries.
6. **Order-related change:** calculate participant-level changes across the first and second experimental periods, with group-specific IG/Poem ordering, and perform a robust comparison.
7. **Stop-signal delay (SSD):** calculate descriptives, fit SSD mixed-effects models and examine condition/group contrasts; calculate an order-based SSD change score and compare groups using frequentist and Bayesian tests.

The file includes exploratory and commented Bayesian/Stan code; this is not equivalent to an executed Bayesian analysis. It is long because it combines **different outcomes, subsets, model families, diagnostics and exploratory alternatives**, not because each line contributes to a single final model.

**Important checks before executing/interpreting:** `go_omission` is created in `df_go`, but later models use `data = df`, where that variable may not exist. The Poisson model is applied to a **trial-level binary omission indicator** rather than an aggregated count; check whether a binomial model, count aggregation, and/or exposure offset better matches the research question. The comment calling the RT <150-ms filter an "SSRT" filter is misleading; confirm which variable is intended. Several sections later work with `df` after previous recoding and filtering, so the actual subset must be verified at each step; do not assume a heading guarantees that only Go or only Stop trials are modelled. SSD plots/statistics should specifically filter valid stop trials when warranted.

### `Analysis_stop_data.r`: aggregated stop-signal outcomes

This script reads `df_stop_estimation_method.xlsx` and works primarily with subject/condition-level estimates. It assigns the same hard-coded addiction/impulsivity groups, excludes IDs **9, 10, 18, and 19**, and filters SSRT estimates below **150 ms**. It then:

1. Summarizes **SSRT** (stop-signal reaction time), **SSD** (stop-signal delay), **USRT** (unsuccessful-stop response time), correct Go RT, probability of responding (`presp`), Go omissions and Go errors by content and group.
2. Visualizes SSRT distributions and content/group means; inspects normality and homogeneity assumptions.
3. Reshapes IG and Poem SSRT to participant-matched columns and carries out paired, two-sided and directional t-tests on their difference.
4. Summarizes unsuccessful-stop reaction times and produces descriptive plots.
5. Loads `questionnaire_stop_signal_processed.csv`, joins questionnaire measures to SSRT estimates, and explores mixed-effects associations between SSRT, questionnaire scores and experimental order.

The questionnaire association section repeats each participant's questionnaire score across condition rows. This is acceptable only if within-subject dependence is addressed appropriately; the script uses participant random intercepts in its mixed models. **Check the join carefully**: the script creates questionnaire `subject` values using `row_number()`, which assumes file row order exactly matches task subject IDs. The code refers to `Order` in later model formulas; confirm that this variable exists with that exact capitalization after loading and cleaning. Additional `tidy()` usage requires an appropriate package (for example `broom.mixed`) to be installed and imported.

### `Power_ssrt_content_period_interaction.R`: SSRT sample-size simulation

This script estimates **conditional statistical power** for a directional paired IG-versus-Poem SSRT contrast. It does not load the Go trial data or fit the final group-by-content statistical model.

1. Load `df_stop_estimation_method.xlsx` and convert `subject` to numeric.
2. Restrict to `subject <= 20` and construct paired SSRT values by subject for **IG** and **Poem** content, excluding incomplete pairs.
3. Calculate the observed sample standard deviation of the within-person differences, `D = IG - Poem`. This SD supplies the assumed individual variability in simulated studies.
4. For each sample size **N = 10, 20, ..., 200** and assumed mean difference **10, 15, 20, 25 or 30 ms**, simulate **2,000** datasets of N normally distributed paired differences with the observed pilot SD.
5. For each simulated dataset, run a **one-sided** one-sample t-test on differences (`alternative = "greater"`) at **alpha = 0.05**. Estimated power is the fraction of simulated tests reaching significance.
6. Plot the resulting curves with an **80% power** reference line and export `power_analysis.png`. The script uses `set.seed(123)` for repeatability.

**Interpretation:** these curves address the probability of detecting a positive mean IG-minus-Poem difference of a specified size **under the assumed pilot variability and normal-difference model**. They do **not** directly estimate power for an interaction between content and period, between-group moderation, mixed-model effects, or a two-sided hypothesis. The `subject <= 20` pilot selection and the reliability of the estimated SD must be checked. The power script outputs a simulation, not an observed effect-size result or guaranteed participant requirement.

## 4. Setup and reproducibility

- **Python:** Python 3.10+, the respective scripts' `requirements.txt` dependencies, and permission to access the raw task/questionnaire exports. Run the task and questionnaire cleaners separately.
- **R:** install the packages actually used by the analysis scripts (notably `tidyverse`/`dplyr`, `readr`, `readxl`, `rstatix`, `lme4`, `lmerTest`, `glmmTMB`, `afex`, `emmeans`, `ggplot2`, `sjPlot`, `BayesFactor`, `WRS2`, `performance`, `Rmisc`, `purrr`, and `effectsize` where needed). For exact versions, a project-specific `renv.lock` is preferable. The extensive package lists in the current scripts include exploratory dependencies and have not been minimized.
- **Paths:** script paths currently assume the working directory contains the named input files. Run from the intended project directory or replace these with project-relative paths. Keep any machine-specific configuration out of Git.
- **Execution order:** task preparation + questionnaire scoring → questionnaire summary → trial-level and estimation-method R analyses → SSRT power simulation. The last stage uses an estimation-method file, not model objects from the preceding R scripts.
- **Privacy:** do not commit raw `.csv`/`.xlsx` participant records, private intermediate outputs, participant-level logs, or notebooks with saved sensitive outputs. Ignoring a file with `.gitignore` does not unpublish content already committed; check Git history before sharing.

A reasonable `.gitignore` is:

```gitignore
# Private inputs and derived participant-level data
data/
output/
outputs/
results/

# Local Python environments and caches
.venv/
__pycache__/
*.pyc
.ipynb_checkpoints/

# R session files
.Rhistory
.RData
.Rproj.user/
```

The exact filenames in the tables above are **inputs/outputs**, not evidence that the data can be downloaded from this repository. Publishing the code and documented criteria helps reproducibility, but replicating numerical results requires authorized access to the original data, matching software environments, and verification of the flagged analysis issues.

## 5. Checks before treating the repository as fully reproducible

- Compare both Python cleaners' outputs with the original notebook results using the authorized data; verify subject IDs, exclusions, trial counts, scales, and SSRT summaries.
- Replace hard-coded participant-ID grouping lists with a documented, verifiable link to the questionnaire scoring output when feasible; retain the original scientific inclusion decisions.
- Verify that every R model uses the intended **level of observation and data subset** (especially binary Go omissions, correct Go RT, SSD and stop-trial-only outcomes).
- Verify the questionnaire-to-SSRT join by real stable identifiers rather than row position.
- Distinguish the power analysis's directional paired difference from any hypothesis about **content × experimental period**.
- Retain historical scripts or a versioned analysis log when correcting a statistical model, so changes to scientific results are transparent.
