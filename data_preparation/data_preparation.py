#!/usr/bin/env python3
"""Run the data preparation workflow from the original notebook."""

import argparse
import glob  # finds files that match a pattern
import os
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import statsmodels.api as sm
from scipy.stats import kstest, normaltest, shapiro

from functions.extract_metadata import extract_metadata
from functions.add_metadata import add_metadata
from functions.sorting import sorting
from functions.assign_condition import assign_condition
from functions.new_participant_id import new_participant_id
from functions.trial_sort_order import trial_sort_order


def main(
    data_dir="Data",
    estimation_file="stop_individual_data.csv",
    beest_file="stop_beest_data.csv",
    output_dir="output",
):
    """Run all original preparation sections and save datasets and plots."""
    data_dir = Path(data_dir)
    estimation_file = Path(estimation_file)
    beest_file = Path(beest_file)
    output_dir = Path(output_dir)
    # Check both external inputs before writing any results.
    for input_file in (estimation_file, beest_file):
        if not input_file.is_file():
            raise FileNotFoundError(f"Input file not found: {input_file}")
    output_dir.mkdir(parents=True, exist_ok=True)

    # **In this code**
    #
    # 1. Preprocessing and dataset creation for the mean method
    # 2. Preprocessing and dataset creation for the estimation method
    # 3. Attempt to preprocess and dataset creation for the BEEST method

    # **First Importing Steps and stuff to create the dataset with the mean Method**

    # Helpere functtion to extract metadata from file names

    # --- Extract metadata from filename ---

    # --- Add metadata to each df ---

    # --- Locate files ---
    folder_path = str(data_dir)
    # find all the csv files in the folder
    csv_files = glob.glob(os.path.join(folder_path, "SST*.csv"))
    if not csv_files:
        raise FileNotFoundError(f"No SST*.csv files found in {folder_path}")

    #Now sort the files so that the participant order is correct later on.

    # --- Sort files by participant ID ---

    # applt to all files the key parameter here can be a function very interesting
    csv_files = sorted(csv_files, key=sorting)

    # ***Alternatively***, you can use a lambda function directly in the sorted call
    #csv_files = sorted(csv_files, key=lambda x: int(re.search(r'SST_(\d+)_', os.path.basename(x)).group(1)))

    # --- Load all files and attach metadata -
    #------------------------------------

    all_dfs = []
    for file_path in csv_files:
        # read the csv
        df = pd.read_csv(file_path)
        # add metadata
        df = add_metadata(df, os.path.basename(file_path))
        all_dfs.append(df)

    # --- Combine all data ---
    dff = pd.concat(all_dfs, ignore_index=True)

    # --- Assign group based on first appearance ---
    first_order = dff[dff["order"] == "1"]
    group_map = first_order.set_index('participant')['condition'].apply(lambda c: f"{c}First").to_dict()
    dff['group'] = dff['participant'].map(group_map)

    # --- Fix the condition based on group + order ---

    dff['condition'] = dff.apply(assign_condition, axis=1)

    # #Stack them all together
    # dff = pd.concat(all_dfs, ignore_index=True)

    # first_order = dff[dff["order"] == "1"]

    # # Create a mapping from participant to group string.
    # # set_index('participant') sets the participant column as the index, this so it is easier to map it later on.
    # # then i just seltect the condition and I apply the lambda that trasforms Poem to PoemFirst.
    # #I then convert it to a dictionary so that I can later on map it to the dff dataframe.
    # group_map = first_order.set_index('participant')['condition'].apply(lambda c: f"{c}First").to_dict()

    # # map that logic to all rows
    # dff['group'] = dff['participant'].map(group_map)

    # print(dff)

    rt_outside_200_1250_counts = ((dff['rt'] < 200) | (dff['rt'] > 1250)).value_counts()

    # **Participants Exclusion**

    rt_below_150_counts = (dff['rt'] < 150).value_counts()

    # Should I Filter out participants that have a RT < 200ms or > 1500?

    dff['rt'] = pd.to_numeric(dff['rt'], errors='coerce')

    dff = dff[(dff['rt'] > 150) & (dff['rt'] < 1250) | (dff['rt'].isna())]

    # **Putting the dataset in shape for analyes and some plotting**

    # Data shaping
    # ===========================================

    # 1. Get only experimental blocks
    #-------------------------------------
    df = dff[dff['block_i'] > 0].reset_index(drop=True)

    # 2. Add a column with trial_type
    #-------------------------------------
    df['trial_type'] = np.where(df['signal'] == 'yes', 'stop', 'go')

    # 3. Rename columns
    #-------------------------------------
    df.rename(columns={
        'block_i': 'block',
        'trial_i': 'trial'
    }, inplace=True)

    # 4. Check if participants where always focusing and in case drop that column
    #-------------------------------------
    if(df['focus'] == 'focus').all():
        df = df.drop(columns=['focus'])

    # 4 . drop useless columns
    #-------------------------------------
    df = df.drop(columns=['participantID', 'browser_name', 'Fullscreen', 'browser_version', 'os_name', 'os_version', 'tablet', 'mobile', 'screen_resolution', 'window_resolution'])

    # 5. Add an inhibited column to say whether the stop response was succesfull
    #-------------------------------------
    df['inhibited'] = np.where((df['signal'] == 'yes') & (df['correct'] == True), 'yes', 'no' )

    # 6. Check race model assumptions
    #-------------------------------------

    # If the RT on unsuccessful stop trials is numerically longer
    # than RT on go trials the race model assumption is violated

    # Mean of unsuccesfull stop trials, the Nans that correspodn to the succesfull stops are ignored by default
    stop_mean = df[df['trial_type'] == 'stop'].groupby('participant')['rt'].mean()

    # Mean of go trials
    go_mean = df[df['trial_type'] == 'go'].groupby('participant')['rt'].mean()

    # Align them just to be sure

    stop_mean, go_mean = stop_mean.align(go_mean)

    race_assumption = np.where(stop_mean < go_mean, True, False)

    # Keep the participants ids

    race_assumption_ids = pd.Series(race_assumption, index= stop_mean.index)

    # Drop that participant from the df

    participant_id_to_drop = 24
    df = df[df['participant'] != participant_id_to_drop]

    # 7. Set the order column right
    #-------------------------------------
    # # np.select(conditions, choices, default=np.nan)

    conditions = [
        ((df['group'] == 'IGFirst') & (df['condition'] == 'IG')),
        ((df['group'] == 'IGFirst') & (df['condition'] == 'Poem')),
        ((df['group'] == 'PoemFirst') & (df['condition'] == 'Poem')),
        ((df['group'] == 'PoemFirst') & (df['condition'] == 'IG')),

    ]

    choices = ['IG_first', 'Poem_second', 'Poem_first', 'IG_second']

    df['condition_order'] = np.select(conditions, choices, default=None)

    # 7. Create the df_stop dataset and the df_go
    #-------------------------------------
    df_go = df[df['trial_type'] == 'go']
    df_stop =  df[df['trial_type'] == 'stop']

    # Download them datasets

    df.to_csv(output_dir / 'df_total.csv', index=False)
    df_stop.to_excel(output_dir / 'df_stop.xlsx', index=False)
    df_go.to_excel(output_dir / 'df_go.xlsx', index=False)

    go_response_crosstab = pd.crosstab(index = [df['condition'], df['group']],
                columns = df[df['trial_type'] == 'go']['response'],
                margins = True)

    stop_inhibition_crosstab = pd.crosstab(index = [df_stop['condition'], df_stop['group']],
                columns=df_stop['inhibited'],
                margins=True)

    stop_correct_counts = df_stop['correct'].value_counts()

    # Plot only stop trials, grouped by inhibition success, group, and condition
    g = sns.catplot(
        data=df[df['trial_type'] == 'stop'],
        kind="count",
        x='inhibited',
        hue="group",
        col="condition",  # Facet by condition (e.g., IGFirst, PoemFirst)
        palette="Set2",
        dodge=True,
        height=5,
        aspect=1
    )

    g.fig.suptitle('Inhibition Success on Stop Trials by Group and Condition', y=1.05)
    g.set_axis_labels("Inhibited Response", "Count")
    g._legend.set_loc('upper right')
    g._legend.set_bbox_to_anchor((1, 1))
    plt.tight_layout()

    plt.savefig(output_dir / "inhibition_success.png", dpi=150, bbox_inches="tight")
    plt.close()

    # Ensure correct types for plotting
    df['condition'] = df['condition'].astype('category')
    df['group'] = df['group'].astype('category')

    # Set up 2x2 subplot grid
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    sns.set(style="whitegrid")

    # Plot 1: RT by condition and group (Stop trials)
    sns.pointplot(
        ax=axes[0, 0],
        data=df[df['trial_type'] == 'stop'],
        x='condition', y='rt', hue='group',
        dodge=True, errorbar='ci', capsize=.1, join=True
    )
    axes[0, 0].set_title('RT (Stop Trials)')
    axes[0, 0].set_ylabel('Reaction Time (ms)')
    axes[0, 0].set_xlabel('Condition')

    # Plot 2: SSD by condition and group (Stop trials)
    sns.pointplot(
        ax=axes[0, 1],
        data=df[df['trial_type'] == 'stop'],
        x='condition', y='SSD', hue='group',
        dodge=True, errorbar='ci', capsize=.1, join=True
    )
    axes[0, 1].set_title('SSD (Stop Trials)')
    axes[0, 1].set_ylabel('Stop Signal Delay (ms)')
    axes[0, 1].set_xlabel('Condition')

    # Plot 3: RT by condition and group (Go trials)
    sns.pointplot(
        ax=axes[1, 0],
        data=df[df['trial_type'] == 'go'],
        x='condition', y='rt', hue='group',
        dodge=True, errorbar='ci', capsize=.1, join=True
    )
    axes[1, 0].set_title('RT (Go Trials)')
    axes[1, 0].set_ylabel('Reaction Time (ms)')
    axes[1, 0].set_xlabel('Condition')

    # Add legends only once
    axes[0, 0].legend(title='Group')
    axes[0, 1].legend_.remove()
    axes[1, 0].legend_.remove()

    plt.tight_layout()

    plt.savefig(output_dir / "trial_summary.png", dpi=150, bbox_inches="tight")
    plt.close()

    # **Difference in RT after a stop signal?**

    # Let's add a column to my dataset that is called after_stop_trial
    # this should take the value no if the trial before is not a stop or yes if it is a stop trial

    dff['after_stop_trial'] = dff['signal'].shift(1).apply(lambda x: 'yes' if x == 'yes' else 'no')

    ## another version would be
    ## np.where(condition, value_if_true, value_if_false) works element-wise on arrays/Series internally (in C, fast).
    #dff['after_stop_trial'] = np.where(dff['signa'].shift(1) == 'yes', 'yes', 'no')

    g = sns.catplot(
        data=dff,
        kind='point',
        x='after_stop_trial',
        y='rt',
        hue='group',
        col='condition',       # This makes small multiples (facets)
        errorbar='sd',
        dodge=True,
        capsize=0.1,
        height=5,
        aspect=1
    )

    g.set_axis_labels("After Stop Trial", "Reaction Time")
    g.set_titles("Condition: {col_name}")
    plt.tight_layout()
    plt.savefig(output_dir / "after_stop_trial.png", dpi=150, bbox_inches="tight")
    plt.close()

    # **Creating the dataset for the Mean Method**

    plt.hist(dff['rt'], bins=30)
    plt.savefig(output_dir / 'rt_histogram.png', dpi=150, bbox_inches='tight')
    plt.close()

    fig = sm.qqplot(dff['rt'].dropna(), line ='s')
    fig.savefig(output_dir / 'rt_qqplot.png', dpi=150, bbox_inches='tight')
    plt.close(fig)

    shapiro_result = shapiro(dff['rt'].dropna())

    kstest_result = kstest(dff['rt'].dropna(), 'norm')

    #First check whether rt are normal or not on the df_go dataset

    stat, p = normaltest(dff['rt'].dropna())

    mean_go_rt = (
        df_go
        .groupby(['participant', 'condition', 'group'])['rt']
        .mean()
        .reset_index()
        .rename(columns = {'rt': 'mean_go_rt'})
    )

    # Compute mean SSD per participant/condition/group
    mean_ssd = (
        df_stop
        .groupby(['participant', 'condition', 'group'])['SSD']
        .mean()
        .reset_index()
        .rename(columns={'SSD': 'mean_ssd'})
    )

    # Merge and calculate SSRT
    df_ssrt_mean_method = pd.merge(mean_go_rt, mean_ssd, on=['participant', 'condition', 'group'])
    df_ssrt_mean_method['ssrt'] = df_ssrt_mean_method['mean_go_rt'] - df_ssrt_mean_method['mean_ssd']

    # Add the block order

    df_ssrt_mean_method['block'] = np.where(
        ((df_ssrt_mean_method['group'] == 'IGFirst') & (df_ssrt_mean_method['condition'] == 'IG')) |
        ((df_ssrt_mean_method['group'] == 'PoemFirst') & (df_ssrt_mean_method['condition'] == 'Poem')),
        'first',
        'second'
    )

    # Download the SSRT dataframe with mean method estimation
    df_ssrt_mean_method.to_csv(output_dir / "df_ssrt_mean_method.csv", index = False)

    summary_stats = (
        df_ssrt_mean_method
        .groupby(['group', 'condition'])['ssrt']
        .agg(mean_ssrt='mean', sd_ssrt='std', count='count')
        .reset_index()
    )

    summary_stats.to_csv(output_dir / "summary_stats.csv", index=False)

    # **Creating the Dataset For the SSRT ESTIMATION Method**

    df = pd.read_csv(estimation_file)

    #Reassing the right names to participants because something went wrong
    #######################################################################

    #First split because I have each partiicpant twice
    num_participants = len(df['subject']) // 2

    # Create participants numbers repeated twice
    participant_nums = []
    for i in range(1, num_participants + 1):
        participant_nums.extend([i,i])

    # Create condition labels alternating per participant:
    # For odd participants: first row IG, second row Poem
    # For even participants: first row Poem, second row IG

    condition_labels = []
    for i in range(1, num_participants + 1):
        if i % 2 == 1:  # odd participant
            condition_labels.extend(['1IG', '2Poem'])
        else:  # even participant
            condition_labels.extend(['1Poem', '2IG'])

    # Combine participant number and condition label
    new_ids = [f"{num}_{cond}" for num, cond in zip(participant_nums, condition_labels)]

    # Assign to a new column or replace the 'subject' column
    df['subject'] = new_ids

    #Prepare the data ATTENTION FOR NOW ONLY THE df DATA ARE PRE-PROCESSED

    # Split the subject column and create a new condition column
    df['condition'] = df['subject'].str.split('_').str[1]
    df['subject'] = df['subject'].str.split('_').str[0]

    # Create a Group column for a betwee-participant comparison

    #first transofrms the second row with the first for each participant
    df['Group'] = df.groupby('subject')['condition'].transform('first')

    # Map 'Group' to ensure only 'IG' or 'Book' is assigned
    df['Group'] = df['Group'].apply(lambda x: 'IG_first' if 'IG' in str(x) else 'Poem_first')

    # Check condition of the independent race model. usRT < gotRT_all for each participant and for each condition

    df['race_model'] = df.apply(lambda x: x['usRT'] < x ['goRT_all'], axis=1)
    df = df[df['race_model']] # this drops the rows where race_model = False

    # Add a groupx condition column
    df['Group_Condition'] = df['Group'] + " x " + df['condition']

    # First, create a column that extracts 'Content' (IG vs Poem)
    df['Content'] = df['condition'].apply(lambda x: 'IG' if 'IG' in x else 'Poem')

    # Then, create a column for 'Order' (1 = first, 2 = second)
    df['Order'] = df['condition'].apply(lambda x: 'first' if '1' in x else 'second')

    # Display the updated DataFrame

    df.to_excel(output_dir / "df_stop_estimation_method.xlsx", index=False)

    # **Creating the dataset for BEEST**
    #
    # The "subj_idx" column contains the participant number.
    #
    # The "ss_presented" column contains the trialtype,where got rials are
    # coded with 0 and stop-signal trials are coded with 1.
    #
    # The "inhibited" column contains the inhibition data,where signal-respond trials are coded with 0 (i.e.,
    # unsuccessful inhibition),signal-inhibit trials are coded with 1 (i.e.,successful
    # inhibition), and go trials arecoded with −999.
    #
    # The "ssd" column contains the stop-signal delay in ms.,where go trials are coded with −999.
    #
    # The "rt" column contains the goRT for go trials and the signal-respond RT for signal-respond
    # trials in ms.,where signal-inhibit trials are coded with −999.

    ###############################
    # In this code we also learn how to use
    # np.where(condition, value_if_true, value_if_false)
    # np.select(condition, choice, default=np.nan)
    # LOVELY
    ################################

    # In this dataset I need to duplicate my participants numbers because they did the task twice and those must be accounted
    #as different scores

    #Creating the BEEST dataframe the order must be
    # "subj_idx", "ss_presented", "inhibited","ssd", and "rt".

    # The "subj_idx" column contains the participant number.

    df_BEEST = dff[["participant", "signal", "response", "correct", "SSD", "rt", "condition"]].copy()

    df_BEEST["participant_new"] = df_BEEST.apply(new_participant_id, axis=1)

    # The "ss_presented" column contains the trialtype,where go trials are
    # coded with 0 and stop-signal trials are coded with 1.

    df_BEEST["signal"] = np.where(df_BEEST["signal"] == "no", 0, 1)

    # The "inhibited" column contains the inhibition data,where signal-respond trials are coded with 0 (i.e.,
    # unsuccessful inhibition),signal-inhibit trials are coded with 1 (i.e.,successful
    # inhibition), and go trials arecoded with −999.

    # Amazin way of doing it, is np.where(condition, value_if_true, value_if_false) and for the true use lambda. LOVE IT.
    df_BEEST["inhibited"] = np.where(df_BEEST["signal"] == 1, df_BEEST["correct"].apply(lambda x: 1 if x == True else 0), -999)

    # The "ssd" column contains the stop-signal delay in ms.,where go trials are coded with −999.

    df_BEEST["SSD"] = np.where(df_BEEST["signal"] == 1, df_BEEST["SSD"], -999)

    # The "rt" column contains the goRT for go trials and the signal-respond RT for signal-respond
    # trials in ms.,where signal-inhibit trials are coded with −999, if succesfull stop otherwise with rt

    # We learning something new that is np.select(conditions, choices, default=None)

    conditions = [
        (df_BEEST["signal"] == 1) & (df_BEEST["inhibited"] == 0),  # Stop signal but not inhibited
        (df_BEEST["signal"] == 1) & (df_BEEST["inhibited"] == 1),  # Stop signal and inhibited
        (df_BEEST["signal"] == 0)                                   # Go-trials
    ]

    choices = [df_BEEST["rt"], -999, df_BEEST["rt"]]

    df_BEEST["rt"] = np.select(conditions, choices, default=np.nan)

    # df_BEEST["rt"] = np.where(df_BEEST["signal"] == 1, -999, df_BEEST["rt"])

    # Prepare it in the right order
    df_BEEST.drop(columns=["response", "correct"], inplace=True)

    df_BEEST.drop(columns="participant", inplace=True)
    df_BEEST = df_BEEST[["participant_new", "signal", "inhibited", "SSD", "rt"]]

    #Raname the columns to match the BEEST format
    #--------------------------------------------
    df_BEEST = df_BEEST.rename(columns={
        "participant_new": "subj_idx",
        "signal": "ss_presented",
        "SSD": "ssd",
        "rt": "rt"
    })

    df_BEEST = df_BEEST.dropna()

    df_BEEST["rt"] = df_BEEST["rt"].astype(int)

    df_BEEST = df_BEEST.sort_values(by="subj_idx").reset_index(drop=True)

    # Export it to load it into the program

    df_BEEST.to_csv(output_dir / "BEEST_data.csv", index=False)

    # Assuming df_BEEST is your DataFrame with columns:
    # 'subj_idx', 'ss_presented', 'inhibited', 'ssd', 'rt'

    # Apply the function to create the sort_key column
    df_BEEST['sort_key'] = df_BEEST.apply(trial_sort_order, axis=1)

    # Check for unexpected rows (sort_key == 3)
    unexpected_rows = df_BEEST[df_BEEST['sort_key'] == 3]

    if not unexpected_rows.empty:
        # Get unique participant IDs with unexpected rows
        bad_subjs = unexpected_rows['subj_idx'].unique()
        raise ValueError(f"Unexpected trial types found for participant(s): {bad_subjs}")

    # Sort the DataFrame by 'subj_idx' and 'sort_key'
    df_BEEST_sorted = df_BEEST.sort_values(by=['subj_idx', 'sort_key']).drop(columns=['sort_key'])

    df_BEEST_sorted.to_csv(output_dir / "BEEST_data_sorted.csv", index=False)

    # Condition 1: Go trials with missing RT
    cond1 = (
        (df_BEEST['ss_presented'] == 0) &
        (df_BEEST['inhibited'] == -999) &
        (df_BEEST['ssd'] == -999) &
        (df_BEEST['rt'] == -999)
    )

    # Condition 2: Signal-respond trials with missing RT
    cond2 = (
        (df_BEEST['ss_presented'] == 1) &
        (df_BEEST['inhibited'] == 0) &
        (df_BEEST['ssd'] != -999) &  # SSD should be a valid number here
        (df_BEEST['rt'] == -999)
    )

    # Combine conditions
    problematic_rows = df_BEEST[cond1 | cond2]

    # Report

    beest_dtypes = df_BEEST.dtypes

    beest_sorted_shape = df_BEEST_sorted.shape

    expected_subjects = set(range(1, 77))  # Adjust 51 to max expected + 1
    actual_subjects = set(df_BEEST['subj_idx'].unique())

    missing_subjects = expected_subjects - actual_subjects

    # **BEEST data downloaded from Verbuggen**

    stop_beest_data = pd.read_csv(beest_file)

    # Rename the participant if the name in the subj_idx is the same
    # using cat.codes

    stop_beest_data['subj_idx'] = stop_beest_data['subj_idx'].astype('category').cat.codes + 1

    # How many unique IDs?

    # List all unique IDs

    # If you want to see which IDs are duplicated or problematic:

    stop_beest_data['rt'] = stop_beest_data['rt'].fillna(-999)

    # Should I Filter out participants that have a RT < 200ms or > 1500?

    stop_beest_data = stop_beest_data[(stop_beest_data['rt'] > 150) & (stop_beest_data['rt'] < 1250)]

    # stop_beest_data.to_csv("stop_beest_data.csv", index=False)
    stop_beest_data.to_csv(output_dir / "stop_beest_data_cleaned.csv", index=False)

    return {
        "mean_method": df_ssrt_mean_method,
        "estimation_method": df,
        "beest": df_BEEST,
        "beest_sorted": df_BEEST_sorted,
        "external_beest": stop_beest_data,
        "summary_stats": summary_stats,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-dir", type=Path, default=Path("Data"))
    parser.add_argument(
        "--estimation-file", type=Path, default=Path("stop_individual_data.csv")
    )
    parser.add_argument(
        "--beest-file", type=Path, default=Path("stop_beest_data.csv")
    )
    parser.add_argument("--output-dir", type=Path, default=Path("output"))
    args = parser.parse_args()
    main(args.data_dir, args.estimation_file, args.beest_file, args.output_dir)
