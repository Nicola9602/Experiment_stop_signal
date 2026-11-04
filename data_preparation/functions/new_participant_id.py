def new_participant_id(row):
    # For "IG" condition, assign odd numbers: 1,3,5,...
    # For "Poem" condition, assign even numbers: 2,4,6,...
    base_id = (row["participant"] - 1) * 2
    if row["condition"] == "IG":
        return base_id + 1
    else:  # condition == "Poem"
        return base_id + 2
