def gen_figure_by_year(title_list, year):
  import nltk
  nltk.download('stopwords')
  from nltk.corpus import stopwords
  from collections import Counter

  print(stopwords.words('english'))

  stopwords_deep_learning = ['learning', 'network', 'neural', 'networks', 'deep', 'via', 'using', 'convolutional', 'single']

  keyword_list = []

  for i, title in enumerate(title_list):
    
    # print(i, "th paper's title : ", title)
      
    word_list = title.split(" ")
    word_list = list(set(word_list))
      
    word_list_cleaned = [] 
    for word in word_list: 
      word = word.lower()
      if word not in stopwords.words('english') and word not in stopwords_deep_learning: #remove stopwords
            word_list_cleaned.append(word)  
      
    for k in range(len(word_list_cleaned)):
      keyword_list.append(word_list_cleaned[k])
    
  keyword_counter = Counter(keyword_list)
  print(keyword_counter)  

  print('{} different keywords before merging'.format(len(keyword_counter)))

  # Merge duplicates: CNNs and CNN
  duplicates = []
  for k in keyword_counter:
      if k+'s' in keyword_counter:
          duplicates.append(k)
  for k in duplicates:
      keyword_counter[k] += keyword_counter[k+'s']
      del keyword_counter[k+'s']
  print('{} different keywords after merging'.format(len(keyword_counter)))
  print(keyword_counter)  

  print("")

  # Show N most common keywords and their frequencies
  num_keyowrd = 75 #FIXME
  keywords_counter_vis = keyword_counter.most_common(num_keyowrd)

  plt.rcdefaults()
  fig, ax = plt.subplots(figsize=(8, 18))

  key = [k[0] for k in keywords_counter_vis] 
  value = [k[1] for k in keywords_counter_vis] 
  y_pos = np.arange(len(key))
  ax.barh(y_pos, value, align='center', color='green', ecolor='black', log=True)
  ax.set_yticks(y_pos)
  ax.set_yticklabels(key, rotation=0, fontsize=10)
  ax.invert_yaxis() 
  for i, v in enumerate(value):
      ax.text(v + 3, i + .25, str(v), color='black', fontsize=10)
  ax.set_xlabel('Frequency')
  ax.set_title(f'CVPR {year} Submission Top {num_keyowrd} Keywords')

  plt.show()

  # Show the word cloud forming by keywords
  from wordcloud import WordCloud
  wordcloud = WordCloud(max_font_size=64, max_words=160, 
                        width=1280, height=640,
                        background_color="black").generate(' '.join(keyword_list))
  plt.figure(figsize=(16, 8))
  plt.imshow(wordcloud, interpolation="bilinear")
  plt.axis("off")
  plt.show()



import requests
years = ['2021', '2022', '2023']

for idx, year in enumerate(years):
  url = 'https://openaccess.thecvf.com/CVPR' + year + '?day=all'
  print(idx, url)
  response = requests.get(url)
  title_list = []

  for line in response.content.decode().splitlines():
      if '<dt class="ptitle">' in line:
        title = line.split('.html">')[1].split('</a></dt>')[0]
        # print(line)
        # break
        if title not in title_list:
          title_list.append(title)

  gen_figure_by_year(title_list, year)
  # break