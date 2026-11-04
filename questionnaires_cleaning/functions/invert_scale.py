def invert_scale(df, items_to_invert, min_val=None, max_val=None):
    """Reverse selected scale items using the supplied scale bounds."""
    df = df.copy()
    df[items_to_invert] = df[items_to_invert].apply(lambda x: max_val + min_val - x)
    return df
