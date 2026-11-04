import re


def extract_metadata(filename):
    # re.search tries to find a pattern match in the provided string, here the filename
    # in this case it splits the filename into 4 parts, SST, participant_id, order, and condition
    match = re.search(r"SST_(\d+)_(\d+)(IG|Poem)", filename)
    # the if then assigns all the paerts to the needed variables
    if match:
        participant_id = int(match.group(1))
        order = match.group(2)
        condition = match.group(3)
        return participant_id, order, condition
    return None, None, None #This if the filename does not match the expected pattern.
