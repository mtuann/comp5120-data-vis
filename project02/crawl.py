
ROOT_URL = "https://arxiv-sanity-lite.com/?page_number=%d"

def crawl_arxiv_sanity_lite():
    for i in range(1, 11):
        url = ROOT_URL % i
        print(url)
        # get html text from url using BeautifulSoup
        # parse the html text to get the information you need
        # save the information to a csv file
        req = requests.get(url)
        soup = BeautifulSoup(req.text, 'html.parser')
        papers = soup.find_all('li', class_='entry')
        for paper in papers:
            title = paper.find('a').text
            authors = paper.find('span', class_='authors').text
            abstract = paper.find('p', class_='abstract').text
            print(title, authors, abstract)
        # save to csv file
        with open('arxiv_sanity_lite.csv', 'a') as f:
            f.write(f'{title},{authors},{abstract}\n')

crawl_arxiv_sanity_lite()