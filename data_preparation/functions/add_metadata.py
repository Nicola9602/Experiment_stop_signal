from extract_metadata import extract_metadata


def add_metadata(df, filename):
    #call the previsou function
    particinpant_id, order, condition = extract_metadata(filename)
    #Create the columns
    df['participant'] = particinpant_id
    df['order'] = order
    df['condition'] = condition
    #df['group'] = group
    return df
