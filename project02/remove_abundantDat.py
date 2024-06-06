import pandas as pd

# Read the original CSV file
data = pd.read_csv("arxiv05_v2.csv")

# Convert the 'date' column to datetime format
data['time'] = pd.to_datetime(data['time'])

# Filter rows with dates in the first month
data_filtered = data[data['time'].dt.month == 1]

# Keep only the 'summary' column
data_filtered = data_filtered[['title', 'id']]

# Write the filtered data to a new CSV file
data_filtered.to_csv("filtered_data_1_title.csv", index=False)