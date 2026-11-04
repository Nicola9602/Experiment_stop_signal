def assign_condition(row):
    if row['group'] == "IGFirst" and row['order'] == "1":
        return "IG"
    elif row['group'] == "IGFirst" and row['order'] == "2":
        return "Poem"
    elif row['group'] == "PoemFirst" and row['order'] == "1":
        return "Poem"
    elif row['group'] == "PoemFirst" and row['order'] == "2":
        return "IG"
    else:
        return None
