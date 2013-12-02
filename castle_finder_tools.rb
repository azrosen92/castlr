require "net/http"
require "uri"
require "nokogiri"
require "titleize"

#returns a hash of countries
def get_all_castles
  puts "getting all castles..."
  t_start = Time.now
  base_query = "List of castles in "

  castle_list_url = "http://en.wikipedia.org/wiki/List_of_castles_in_Europe"
  uri = URI.parse(castle_list_url)
  response = Net::HTTP.get_response(uri)
  html_text = response.body

  parser = Nokogiri::HTML(html_text)

  castle_url_hash = {}
  parser.xpath('//div[@id="mw-content-text"]//ul').each do |lst|
    lst.xpath('li').each do |castle|
      article_url = castle.xpath('a//@href').to_s
      article_title = castle.xpath('a//@title').to_s
      if /List of castles in/.match(article_title)
        article_title = article_title.sub 'List of castles in ', ''
        country = article_title.downcase
        castle_url_hash[country] = article_url unless /\(page does not exist\)/ =~ country
      end
    end
  end

  t_end = Time.now
  puts "execution time: #{t_end - t_start}"
  return castle_url_hash

end

def get_all_castles_from(country_url)
  t_start = Time.now
  puts "getting all castles from #{country_url}"
  puts "========================================"
  base_url = "http://en.wikipedia.org"
  full_url = URI.parse(base_url + country_url)
  
  castle_response = Net::HTTP.get_response(full_url)
  castle_html_text = castle_response.body

  castle_parser = Nokogiri::HTML(castle_html_text)

  castle_hash = {}
  castle_parser.xpath('//div[@id="mw-content-text"]//ul').each do |castle_lst|
    castle_lst.xpath('li').each do |castle_country|
      castle_name = castle_country.xpath('a//@title').to_s
      castle_url = castle_country.xpath('a//@href').to_s
      if /\w Castle/ =~ castle_name
        castle_hash[castle_name.downcase] = castle_url unless /\(page does not exist\)/ =~ castle_name
      end
    end
  end
  #puts castle_hash
  t_end = Time.now
  puts "===================================="
  puts "execution time: #{t_end - t_start}"
  return castle_hash
end

def get_data_about(castle_url)
  t_start = Time.now
  puts "getting all data about #{castle_url}"
  puts "========================================"
  puts "getting data from " + castle_url
  base_url = "http://en.wikipedia.org"
  full_url = URI.parse(base_url + castle_url)

  r = Net::HTTP.get_response(full_url)
  html_text = r.body

  parser = Nokogiri::HTML(html_text)
  
  if parser.at_css('span.geo-dms')

    puts "-----------------------------------"
    puts "beginning parsing..."
    parse_start = Time.now

    content = parser.xpath('//div[@id="bodyContent"]')
    image = content.xpath('//a[@class="image"]//img//@src')[0].to_s
    latitude = parser.xpath('//span[@class="latitude"]')[0].text.to_s
    longitude = parser.xpath('//span[@class="longitude"]')[0].text.to_s
    parse_end = Time.now
    puts "ending parsing, time taken: #{parse_end - parse_start}"
    puts "------------------------------------"

    castle_hash = {}
    castle_hash[:latitude] = latitude
    castle_hash[:longitude] = longitude
    castle_hash[:img_url] = image
    
    t_end = Time.now
    puts "===================================="
    puts "execution time: #{t_end - t_start}"

    return castle_hash 
  end
end

country = "denmark"
all_countries = get_all_castles
castle_list = get_all_castles_from(all_countries[country])
castle_list.each do |castle, url| 
  puts "getting data for #{castle}..."
  data = get_data_about url
  puts data
end

#get_all_castles.each do |country, url| 
  #puts "getting all castles from #{country}..."
  #castle_list = get_all_castles_from(url) 
  #puts castle_list
#end

#castle_list = get_all_castles_from(country_hash['Poland'])
#puts castle_list


