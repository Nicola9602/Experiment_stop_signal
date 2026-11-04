# Data preparation

A minimal Python conversion of `Data_preparation(3).ipynb`. The original six
functions live in separate Python modules and are imported by `data_preparation.py`.
The main script retains the notebook's section order, comments, filters,
calculations, participant exclusions, and BEEST preparation.

## Run

Requires Python 3.10 or newer. Install dependencies:

```bash
python -m pip install -r requirements.txt
```

Place these original inputs in the current working directory:

- `Data/SST*.csv`: individual trial files (original filename format).
- `stop_individual_data.csv`: estimation-method input.
- `stop_beest_data.csv`: external BEEST input.

Run all sections:

```bash
python data_preparation.py
```

To choose input and output paths:

```bash
python data_preparation.py --data-dir path/to/Data --estimation-file path/to/stop_individual_data.csv --beest-file path/to/stop_beest_data.csv --output-dir results
```

## Outputs

Results go to `output/` by default. Existing result files are overwritten.

- `df_total.csv`, `df_stop.xlsx`, `df_go.xlsx`
- `df_ssrt_mean_method.csv`, `summary_stats.csv`
- `df_stop_estimation_method.xlsx`
- `BEEST_data.csv`, `BEEST_data_sorted.csv`
- `stop_beest_data_cleaned.csv`
- Five PNG plots: inhibition success, trial summary, reaction times after a
  stop trial, reaction-time histogram, and Q-Q plot.

Print statements and notebook displays are removed. Plots are saved using a
noninteractive backend. Library warnings and errors may still appear.
Notebook diagnostic tables and normality checks are retained as calculations.
The notebook's commented dataset exports are enabled so a script run produces
usable files; the external BEEST export uses a new filename to protect its input.
Unused imports are removed. Importing the main module does not run the workflow.
`.gitignore` excludes raw data, results, caches, and the virtual environment.

## Original behavior retained

- The reaction-time filter remains strictly greater than 150 and less than
  1250, with the original handling of missing values in each section.
- Participant 24 is still excluded only from the original mean-method branch.
- The estimation input still has participant IDs reassigned in alternating
  pairs, as in the notebook.
- The BEEST section still uses `dff`, including its original treatment of
  practice trials, exclusions, missing values, and sentinel values.
- The expected BEEST subject range remains `range(1, 77)`.
- The external BEEST branch still fills missing RTs with -999 and then applies
  its original filter, which removes those rows.

These choices reproduce the notebook; they have not been corrected or
reinterpreted. Original input data was not attached.

## Validation

All Python files compile. The six extracted function bodies match the original.
On synthetic input, 19 dataframes/series and the computed normal-test values
match the notebook. Exports and four plots were checked. The original
statsmodels Q-Q plot remains in the script, but could not be executed here
because statsmodels was unavailable. No complete run on the original data
was possible.
