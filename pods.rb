require 'open-uri'
require 'nokogiri'


PODCAST = ARGV[0]
FIRST_POD = ARGV[1].to_i
LAST_POD = ARGV.size > 2 ? ARGV[2].to_i : -1


class SiteParser
  def get_link_list
    raise "Not implemented"
  end

  def prefix
    raise "Not implemented"
  end
end

class FFParser < SiteParser
  def get_link_list
    addresses = []
    page = 1 
    loop do
      puts "page #{page}"
      html_doc = Nokogiri::HTML(open("http://www.filipochfredrik.com/podcast-arkiv/page/#{page}")) do |config|
        config.strict.nonet.noblanks
      end

      page_downloads = html_doc.css("a[@class ='download']")
      page_addresses = page_downloads.map {|dl| dl['href']}

      if page_addresses.empty?
        break
      end

      addresses += page_addresses
      page += 1 
    end

    addresses
  end

  def prefix
    "ff"
  end
end

case 
when 'ff'
  parser = FFParser.new
end

addresses = parser.get_link_list 

podnum = FIRST_POD

puts FIRST_POD
puts LAST_POD

addresses = addresses.reverse[FIRST_POD-1..LAST_POD-1]

puts addresses

addresses.each do |address|
  puts "podnum #{podnum}"
  file_name = "#{parser.prefix}_pod#{podnum}.mp3"
  unless File.exists?(file_name)
    puts "Downloading #{address} to #{file_name}"
    open(address) {|data|
      File.open(file_name, "wb") do |file|
        file.puts data.read
      end
    }
  else
    puts "#{file_name} already exists"
  end
  podnum += 1
end
