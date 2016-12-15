from selenium import webdriver
import selenium.webdriver.support.ui as ui
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException
from time import sleep
import time

# ==========================================================
## Load URL

extractItems = []
print 'Loading script'
browser = webdriver.Chrome("C:\Users\y_vb\Downloads\chromedriver_win32\chromedriver")
browser.get('http://www.wsj.com/')
print 'Starting..'

# ==========================================================
## Search for articles

xpath = '//*[@id="Home"]/header/div/div[2]/div[1]'
elem = browser.find_element_by_xpath(xpath)                             # navidate to search box 
elem.click()
search_box = browser.find_element_by_id("wsjSearchInput")
search_box.send_keys('the')                                             # searches keyword "the"
search_button = browser.find_element_by_class_name('searchButton')
search_button.click()
print 'Searching for articles'
toggleMenu = browser.find_element_by_link_text("ADVANCED SEARCH")       # advanced search
toggleMenu.click()
uncheck_blogs = browser.find_element_by_link_text("WSJ Blogs")          # do not search blogs
uncheck_blogs.click()
uncheck_videos = browser.find_element_by_link_text("WSJ Videos")        # do not search videos
uncheck_videos.click()
uncheck_site = browser.find_element_by_link_text("WSJ Site Search")     # do not search the full site
uncheck_site.click()
browser.execute_script("window.scrollTo(0, 0)")
searchArchive = browser.find_element_by_class_name('keywordSearchBar')
searchArchive.find_element_by_class_name("searchButton").click()
print 'Refining search'

# ==========================================================
## Log in for access to full articles

login = browser.find_element_by_link_text("Sign In").click()
loginID = browser.find_element_by_id("username").send_keys('yosefvb@gmail.com')     # Input username
loginPass = browser.find_element_by_id("password").send_keys('yvb123')              # Input password
loginReady = browser.find_element_by_class_name("login_submit")
loginReady.submit()
print 'login successful'

# ==========================================================
## Save article links from search results

def getPageUrl(elementLinks):
    extractLinks = []
    for element in elementLinks:
        links = element.get_attribute('href')
        f = open("WSJ_links", "a")
        f.write(links+'\n')
        f.close()
        extractLinks.append(links)
    return(extractLinks)
    print 'extracting and saving search page links'


def extractElements(url):
    main_window = browser.current_window_handle
    for extracted_url in elementLinks:
        extracted_url.send_keys(Keys.CONTROL + Keys.SHIFT + Keys.RETURN)
        # browser.switch_to_window(main_window)
        windows = browser.window_handles
        browser.switch_to.window(windows[1])
        time.sleep(1)

        try:
            article_url = browser.current_url
            print article_url
        except Exception as e:
            print e
        try: 
            title = browser.find_element_by_xpath('//h1[@class="wsj-article-headline"]').text
        except Exception as e:
            print e
        try:
            sections = browser.find_elements_by_xpath('//a[contains(@itemprop, "item")]').text
            #not working! only first one! made into elements, plural - works?

        except Exception as e:
            print e
        try:
            authors = browser.find_elements_by_xpath('//span[contains(@class, "name")]').text
            #not working! only letter "Y"! made into elements, plural - works?
        except Exception as e:
            print e    
        try:
            date = browser.find_element_by_xpath('//time[contains(@class, "timestamp")]').text
        except Exception as e:
            print e
        try:        
            blurb = browser.find_element_by_xpath('//h2[contains(@class, "sub-head")]').text
        except Exception as e:
            print e    
            #add comments!
        try:    
            paragraphs = browser.find_elements_by_xpath('//p').text
            #not working at all! made into elements, plural - works?
        except Exception as e:
            print e
            pass

        try:
            g = open("WSJ_articles", "a")
        except Exception as e:
            print e
        try:
            g.write(article_url.encode('utf-8')+'??????')
            #change all these ?????? to a tab!?
        except Exception as e:
            print e
        try:
            g.write(title.encode('utf-8')+'??????')
        except Exception as e:
            print e
        try:        
            g.write(sections.encode('utf-8')+'??????')
        except Exception as e:
            print e
        try:    
            g.write(authors.encode('utf-8')+'??????')
        except Exception as e:
            print e
        try:    
            g.write(date.encode('utf-8')+'??????')
        except Exception as e:
            print e
        try:
            g.write(blurb.encode('utf-8')+'??????')
        except Exception as e:
            print e
        try:    
            g.write(paragraphs.encode('utf-8')+'??????')
        except Exception as e:
            print e
        try:    
            g.write('\n')    
            g.close()
        except Exception as e:
            print e
            pass
        time.sleep(1)
        browser.close()
        # browser.find_element_by_tag_name('body').send_keys(Keys.CONTROL + 'w')
        browser.switch_to_window(main_window)
        # browser.switch_to.window(windows[0])
    print 'saving article data'


# Start iterating links in search results
while True:
    try:
        time.sleep(5)
        print 5
        browser.find_element_by_class_name('next-page')
        elementLinks = browser.find_elements_by_xpath('//h3[@class="headline"]/a')      # article links in search results
        extractElements(getPageUrl(elementLinks))
        element = browser.find_element_by_link_text('Next')
        element.click()
        print 'next page'
    except NoSuchElementException:
        break
        # second_browser.close()
        browser.close()