import pandas as pd
import string
import re

def remove_unexpected_chars(text):
  """
  Removes characters that are not alphanumeric or whitespace.

  Args:
      text: The text string to clean.

  Returns:
      The cleaned text string with only alphabets, numbers, and spaces.
  """
  # Regular expression to match only alphabets, numbers, and whitespace
  pattern = r"[^\s\w]"
  return re.sub(pattern, "", text)

with open("output_4.txt", "r") as file:
    # Read lines from the file and strip any leading/trailing whitespace
    lines = [line.strip() for line in file.readlines()]
res = []
for line in lines:
    for subline in line.split(','):
        clean_line = remove_unexpected_chars(subline).lower()
        clean_line = clean_line.lstrip()
        res.append(clean_line)
# print(len(res))

file_path = "list_4.txt"

# Open the file in write mode
with open(file_path, "w") as file:
    # Write each string in the list to the file
    for string in res:
        file.write(string + "\n")
