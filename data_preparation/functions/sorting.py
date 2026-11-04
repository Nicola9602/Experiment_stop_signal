import os
import re


def sorting(file_path):
    # get only the filename
    filename = os.path.basename(file_path)
    # use regex to find the participant number in the filename
    match = re.search(r'SST_(\d+)_', filename)
    return int(match.group(1)) # transform it into integer
