require 'net/http'
require 'json'
require 'uri'

class NewsService
  API_KEY = '01dca39a88b04afd8ac606fdbd1e9fad'
  CATEGORIES = {
    1 => 'business',
    2 => 'entertainment',
    3 => 'general',
    4 => 'health',
    5 => 'science',
    6 => 'sports',
    7 => 'technology'
  }

  def self.search_by_category(category)
    category_param = CATEGORIES[category.to_i]
    if category_param.nil?
      puts "Invalid category. Available categories:"
      CATEGORIES.each { |key, value| puts "#{key}. #{value}" }
      return
    end
  
    url = URI.parse("https://newsapi.org/v2/top-headlines/sources?category=#{category_param}&language=en&apiKey=#{API_KEY}")
  
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
  
    request = Net::HTTP::Get.new(url.request_uri)
    response = http.request(request)
  
    data = JSON.parse(response.body)
  
    sources = data['sources'].take(5)
  
    sources.each.with_index(1) do |article, article_number|
      title = article['title']
      description = article['description']
      url = article['url']
      puts ""
      puts "Article #{article_number}:"
      puts "Title: #{title}"
      puts "Description: #{description}"
      puts "URL: #{url}"
    end
  end

  def self.search_by_keyword(keyword)
    encoded_keyword = URI.encode_www_form_component(keyword.downcase)
    url = URI.parse("https://newsapi.org/v2/everything?q=#{encoded_keyword}&language=en&apiKey=#{API_KEY}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')

    request = Net::HTTP::Get.new(url.request_uri)
    response = http.request(request)

    data = JSON.parse(response.body)

    articles = data['articles'].take(5)

    articles.each.with_index(1) do |article, article_number|
      title = article['title']
      description = article['description']
      url = article['url']
      puts ""
      puts "Article #{article_number}:"
      puts "Title: #{title}"
      puts "Description: #{description}"
      puts "URL: #{url}"
    end
  end
end