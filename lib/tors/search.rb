require 'yaml'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'tty-table'
require 'tty-prompt'

module TorS
  class Search
    def initialize(query = '', from = 'katcr', auto = false, directory = Dir.pwd)
      @provider = YAML.load_file(File.expand_path("../../../providers/#{from}.yml", __FILE__))
      @query = query
      @from = from
      @auto = auto
      @directory = directory

      check_download_directory
      scrape
    end

    def scrape
      @url = @provider['url'].gsub(/%{(\w+)}/, @query ? @query.tr(' ', '+') : '')
      @page = Nokogiri::HTML(open(@url))

      if @page.css(@provider['scrape']['selector']).empty?
        if threat_defence @page
          puts '😰  Sorry, I think you banned from ' + @from + '. There is a threat defense redirection.'
        end

        puts 'Please check this url is works : ' + @url
        return
      end

      @rows = []
      @downloads = []

      puts 'Scrabing...'

      @page.css(@provider['scrape']['selector']).each_with_index do |row, key|
        hash = {
          key: key + 1,
          name: row.search(@provider['scrape']['data']['name']).text,
          url: ''
        }
        if @provider['scrape']['data']['download'].is_a?(String)
          hash[:url] = @provider['download_prefix'] + row.search(@provider['scrape']['data']['download']).first['href']
        else
          @subpage = Nokogiri::HTML(open(@provider['download_prefix'] + row.css(@provider['scrape']['data']['download']['url']).first['href']))

          hash[:url] = @subpage.css(@provider['scrape']['data']['download']['selector']).first['href']
        end

        @downloads << hash

        @rows << [
          (key + 1).to_s,
          !@provider['scrape']['data']['category'].empty? ? row.css(@provider['scrape']['data']['category']).text.tr("\n", ' ').squeeze(' ').strip : '',
          !@provider['scrape']['data']['name'].empty? ? row.css(@provider['scrape']['data']['name']).text.strip : '',
          !@provider['scrape']['data']['size'].empty? ? row.css(@provider['scrape']['data']['size']).text.strip : '',
          !@provider['scrape']['data']['seed'].empty? ? row.css(@provider['scrape']['data']['seed']).text.strip.green : '',
          !@provider['scrape']['data']['leech'].empty? ? row.css(@provider['scrape']['data']['leech']).text.strip.red : ''
        ]
      end

      results
    end

    def results
      puts 'Results for : ' + @query
      puts 'From : ' + @from

      table = TTY::Table.new %i[# Category Title Size Seed Leech], @rows
      puts table.render(:unicode, padding: [0, 1, 0, 1]) do |renderer|
        renderer.border.style = :green
      end

      if @auto
        download @downloads.find { |v| v[:key] == 1 }
      else
        prompt
      end
    end

    def prompt
      prompt = TTY::Prompt.new(interrupt: :exit)
      choice = prompt.ask("Which torrent you want to download? (1..#{@downloads.size} or ctrl+c/cmd+c for interrupt)",
                          convert: :int,
                          default: 1) do |c|
        c.in "1-#{@downloads.size}"
      end

      c = @downloads.find { |v| v[:key] == choice.to_i }
      download c
    end

    def download(choice)
      if choice[:url] =~ /^magnet:\?/
        puts '😏  Sorry, I can\'t start automatically magnet links. Please use this in your torrent client.'
        puts choice[:url]
      else
        begin
          source            = Net::HTTP.get(URI.parse(choice[:url]))
          target_file_name  = choice[:name] + '.torrent'
          target_file       = File.join(@directory, choice[:name])
          puts 'Downloading ' + target_file_name
          File.write(target_file, source)
        rescue IOError => e
          puts '😵  There is an error! ' + e.message + ' Here: L108'
        ensure
          puts '🥂  Downloaded!'
        end
      end
    end

    def threat_defence(page)
      return false unless page.text =~ /threat_defence.php/
      true
    end

    private

    def check_download_directory
      raise "Your download directory #{@directory} not found." unless File.exist? @directory or File.directory? @directory
      raise "Your download directory #{@directory} not writable." unless File.writable? @directory
    end
  end
end
