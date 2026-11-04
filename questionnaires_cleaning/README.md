# Stop Signal Questionnaire Cleaning

Executable Python conversion of `Questionnaires_cleaning.ipynb`, retaining the original cleaning order, item mappings, scoring formulas, and outlier flags.

## Run

Requires Python 3.10 or later. From this folder:

```bash
python -m pip install -r requirements.txt
python questionnaires_cleaning.py --input data/questionnaire_stop_signal.xlsx --output outputs/questionnaire_stop_signal_processed.csv
```

Without arguments, the script reads `questionnaire_stop_signal.xlsx` and writes `questionnaire_stop_signal_processed.csv` in the current working directory. Existing output files are overwritten. Importing the script does not run the workflow. Normal execution produces no diagnostic printouts.

## Files

| File | Purpose |
| --- | --- |
| `questionnaires_cleaning.py` | Main cleaning and export workflow. |
| `functions/invert_scale.py` | Original reverse-scoring function, imported by the main script. It copies the DataFrame and computes `max_val + min_val - score` for selected columns. |
| `requirements.txt` | Runtime dependencies. |
| `.gitignore` | Excludes local input/output folders and Python caches. |

## Workflow

1. Rename Q9 and Q10 items using the original impulsivity and Instagram-addiction mappings.
2. Convert questionnaire items to numeric values, coercing invalid entries to missing values.
3. Reverse-score columns containing `inverted` using the original 1–4 bounds.
4. Calculate `impulsivity_total`, `addiction_total`, `IGA_compulsivity_total`, and `IGA_social_effect` in the original column positions.
5. Drop the first data row and reset the index, as in the notebook.
6. Flag totals exceeding the sample mean by 2 or 3 sample standard deviations. These are upper-tail flags; flagged participants are retained.
7. Export all remaining data and flags to CSV.

## Conversion scope

The existing function is moved into its own module. The main script adds a `main()` entry point and optional file arguments. Notebook-only table displays and the outlier printout are removed. Unused NumPy, seaborn, and matplotlib imports are omitted; the notebook performs no plotting. Original comments and commented alternatives are retained.

The input must retain the expected export structure. The first data row is always dropped; this is not detected automatically. Item selection uses the same column-name substrings as the notebook, and sums retain pandas' original missing-value behavior, including a zero total when all selected items are missing. Missing required item columns are not newly validated. These research and data-handling decisions have not been changed.

The reverse-scoring function and full CSV output were checked against the original notebook on synthetic input, including missing/nonnumeric items and an upper-tail outlier. The private source workbook was not supplied, so results on the real dataset still require verification.
