#!/usr/bin/env python3
"""Clean stop-signal questionnaire data using the original notebook workflow."""

import argparse
from pathlib import Path

import pandas as pd

from functions.invert_scale import invert_scale


def main(input_file="questionnaire_stop_signal.xlsx",
         output_file="questionnaire_stop_signal_processed.csv"):
    """Rename items, reverse-score, calculate totals, flag outliers, and export."""
    output_file = Path(output_file)
    output_file.parent.mkdir(parents=True, exist_ok=True)

    df = pd.read_excel(input_file)

    rename_map = {
        # =========================
        # Q9 — BIS-15 IMPULSIVITY
        # =========================

        # Non-planning impulsivity — inverted
        "Q9_1":  "Impulsivity_nonplanning_1_inverted",
        "Q9_5":  "Impulsivity_nonplanning_5_inverted",
        "Q9_7":  "Impulsivity_nonplanning_7_inverted",
        "Q9_8":  "Impulsivity_nonplanning_8_inverted",
        "Q9_15": "Impulsivity_nonplanning_15_inverted",

        # Motor impulsivity
        "Q9_2":  "Impulsivity_motor_2",
        "Q9_9":  "Impulsivity_motor_9",
        "Q9_10": "Impulsivity_motor_10",
        "Q9_12": "Impulsivity_motor_12",
        "Q9_13": "Impulsivity_motor_13",

        # Attentional impulsivity
        "Q9_3":  "Impulsivity_attentional_3",
        "Q9_4":  "Impulsivity_attentional_4_inverted",
        "Q9_6":  "Impulsivity_attentional_6",
        "Q9_11": "Impulsivity_attentional_11",
        "Q9_14": "Impulsivity_attentional_14",

        # =========================
        # Q10 — INSTAGRAM ADDICTION
        # =========================

        # Social effect
        "Q10_1": "IG_addiction_social_effect_1",
        "Q10_2": "IG_addiction_social_effect_2",
        "Q10_3": "IG_addiction_social_effect_3",
        "Q10_4": "IG_addiction_social_effect_4",
        "Q10_5": "IG_addiction_social_effect_5",
        "Q10_6": "IG_addiction_social_effect_6",
        "Q10_7": "IG_addiction_social_effect_7",
        "Q10_8": "IG_addiction_social_effect_8",

        # Compulsivity
        "Q10_9":  "IG_addiction_compulsivity_9",
        "Q10_10": "IG_addiction_compulsivity_10",
        "Q10_11": "IG_addiction_compulsivity_11",
        "Q10_12": "IG_addiction_compulsivity_12",
        "Q10_13": "IG_addiction_compulsivity_13",
        "Q10_14": "IG_addiction_compulsivity_14",
        "Q10_15": "IG_addiction_compulsivity_15",
    }

    df = df.rename(columns=rename_map)

    questionnaire_cols = [
        col for col in df.columns
        if "Impulsivity" in col or "IG_addiction" in col
    ]

    df[questionnaire_cols] = df[questionnaire_cols].apply(
        pd.to_numeric,
        errors="coerce"
    )


    # Invert the scale for the items that need it first Impulsivity

    items_to_invert = [col for col in df.columns if "inverted" in col]


    df = invert_scale(df, items_to_invert, min_val=1 , max_val=4)

    # Calculate the total scores for impulsivity and addiction

    IG_addiction_impulsivity = [col for col in df.columns if "IG_addiction_compulsivity" in col]
    IG_addiction_social = [col for col in df.columns if "IG_addiction_social_effect" in col]


    impulsivity_cols = [col for col in df.columns if "Impulsivity" in col]

    addiction_cols = [col for col in df.columns if "addiction" in col]


    df.insert(4, 'impulsivity_total', df[impulsivity_cols].sum(axis=1))
    df.insert(5, 'addiction_total', df[addiction_cols].sum(axis=1))
    df.insert(6, 'IGA_compulsivity_total', df[IG_addiction_impulsivity].sum(axis=1))
    df.insert(7, 'IGA_social_effect', df[IG_addiction_social].sum(axis=1))

    # df['impulsivity_total'] = df[impulsivity_cols].sum(axis=1)
    # df['addiction_total'] = df[addiction_cols].sum(axis=1)

    # drop first useless row
    df = df.iloc[1:].reset_index(drop=True)

    # Check for outliers as mean of the total scores + 2 or 3 SD

    mean_impulsivity = df['impulsivity_total'].mean()
    sd_impulsivity = df['impulsivity_total'].std()

    threshold_2sd_impulsivity = mean_impulsivity + 2 * sd_impulsivity
    thrshold_3sd_impulsivity = mean_impulsivity + 3 * sd_impulsivity

    mean_addiction = df['addiction_total'].mean()
    sd_addiction = df['addiction_total'].std()

    threshold_2sd_addiction = mean_addiction + 2 * sd_addiction
    thrshold_3sd_addiction = mean_addiction + 3 * sd_addiction

    df['outlier_2sd_impulsivity'] = df['impulsivity_total'] > threshold_2sd_impulsivity
    df['outlier_3sd_impulsivity'] = df['impulsivity_total'] > thrshold_3sd_impulsivity

    df['outlier_2sd_addiction'] = df['addiction_total'] > threshold_2sd_addiction
    df['outlier_3sd_addiction'] = df['addiction_total'] > thrshold_3sd_addiction

    df.to_csv(output_file, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", default="questionnaire_stop_signal.xlsx",
                        help="Path to the original questionnaire Excel export.")
    parser.add_argument("--output", default="questionnaire_stop_signal_processed.csv",
                        help="Path for the processed CSV.")
    args = parser.parse_args()
    main(args.input, args.output)
