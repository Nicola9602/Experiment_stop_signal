def trial_sort_order(row):
    if row['ss_presented'] == 0 and row['inhibited'] == -999:
        return 0
    elif row['ss_presented'] == 1 and row['inhibited'] == 0:
        return 1
    elif row['ss_presented'] == 1 and row['inhibited'] == 1:
        return 2
    else:
        return 3  # unexpected case
