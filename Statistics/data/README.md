# Private input data

Keep all inputs in this shared `data/` folder (ignored by Git):

- `df_total.csv`: original trial-level Go/SSD workflow (`run_analysis.R`).
- `df_stop_estimation_method.xlsx`: Stop-estimation workflow (`run_stop_analysis.R`), with fields used by the original script including `subject`, `group`, `content`, `condition`, `ssrt`, `ssd`, `usrt`, `gort_correct`, `presp`, `go_omission`, `go_error`, and `Order` (original code mixes case).
- `questionnaire_stop_signal_processed.csv`: input for the standalone questionnaire workflow (`run_questionnaire_analysis.R`) and scores joined to the Stop-estimation data. The original code assigns subject IDs from row order; preserving that choice requires the same row ordering as the source dataset.

Never commit participant-level records. Group membership lists in the source scripts should also be reviewed for disclosure risks.
