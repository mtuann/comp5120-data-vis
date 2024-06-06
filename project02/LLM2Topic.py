import pandas as pd
import json
from pprint import pprint
import os
import time
import random
from mistralai.client import MistralClient
from mistralai.models.chat_completion import ChatMessage
mistraApi_key = os.environ["Mistral_API_KEY"]
mistralModel = "open-mixtral-8x7b"

client = MistralClient(api_key=mistraApi_key)
random.seed(1234)

# Read the original CSV file
data = pd.read_csv("filtered_data_1_title.csv")


safety_settings = [
    {
        "category": "HARM_CATEGORY_DANGEROUS",
        "threshold": "BLOCK_NONE",
    },
    {
        "category": "HARM_CATEGORY_HARASSMENT",
        "threshold": "BLOCK_NONE",
    },
    {
        "category": "HARM_CATEGORY_HATE_SPEECH",
        "threshold": "BLOCK_NONE",
    },
    {
        "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "threshold": "BLOCK_NONE",
    },
    {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "threshold": "BLOCK_NONE",
    },
]

res = []
file_path = "output_title_1.txt"
file =  open(file_path, "a") 

def zeroshotDang(summary):
    temp = '''
    You are working in topic modelling in computer science field. Provide the topics of the field in the title in a list [topic1, topic2, ...] without explaination. Here is an example:

    Title: "Semantically Consistent Video Inpainting with Conditional Diffusion Models".
    Answer you should provide: <<<"Video Inpainting", "Conditional Diffusion Models">>>

    Here is the title: {}

    Output:  PROVIDE the topics of the field WITHOUT ANY EXPLAINATION. List of topics is in format of string between <<< >>> as following: <<<  topic_1, topic_2, ...>>> 
    '''
    myprompt = temp.format(summary)
    # print(myprompt)
    messages = [
        ChatMessage(role="user", content=myprompt)
    ]
    # No streaming
    chat_response = client.chat(
        model=mistralModel,
        messages=messages,
        temperature = 0.0
    )

    predictions = chat_response.choices[0].message.content
    predictions = predictions.split('>>>')[0]
    predictions = predictions.split('<<<')[1]
    print(predictions)
    file.write(predictions + "\n")
    res.append(predictions)

try:
    for index, row in data.iterrows():
        print(index)        
        if (index < 1505):
            continue
        if (index > 3000):
            break
        zeroshotDang(row['title'])
except Exception as e:
    raise e



