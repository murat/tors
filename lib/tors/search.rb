require 'yaml'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'tty-table'
require 'tty-prompt'

module TorS
  class Search
    attr_accessor :query, :from, :auto, :directory, :open_torrent

    def initialize(from = 'katcr', &block)
      @from = from

      yaml = File.expand_path("../../../providers/#{from}.yml", __FILE__)
      if File.exists? yaml
        @provider = YAML.load_file(yaml)
      else
        list_providers_and_exit
      end

      if block_given?
        yield self
      else
        raise "#{self.class} requires block to initialize"
      end
    end

    def run
      check_download_directory
      scrape
    end

    def scrape
      @url = @provider['url'].gsub(/%{(\w+)}/, @query ? @query.tr(' ', '+') : '')
      @page = Nokogiri::HTML(open(@url))

      if @page.css(@provider['scrape']['selector']).empty?
        if threat_defence @page
          puts "😰  Sorry, I think you are banned from #{from}. There is a threat defense redirection."
        end

        puts 'Please check this url is works : ' + @url
        return
      end

      @rows = []
      @downloads = []

      puts 'Scraping...'

      key = 0
      @page.css(@provider['scrape']['selector']).each do |row|
        hash = {
          key: key + 1,
          name: row.search(@provider['scrape']['data']['name']).text,
          url: ''
        }
        if @provider['scrape']['data']['download'].is_a?(String)
          link = row.search(@provider['scrape']['data']['download'])
          if !link.empty?
            hash[:url] = @provider['download_prefix'] + link.first['href']
          else
            next
          end
        else
          @subpage = Nokogiri::HTML(open(@provider['download_prefix'] + row.css(@provider['scrape']['data']['download']['url']).first['href']))

          hash[:url] = @subpage.css(@provider['scrape']['data']['download']['selector']).first['href']
        end

        @downloads << hash

        @rows << [
          (key + 1).to_s,
          !@provider['scrape']['data']['category'].empty? ? row.css(@provider['scrape']['data']['category']).text.tr("\n", ' ').squeeze(' ').strip : '',
          !@provider['scrape']['data']['name'].empty? ? row.css(@provider['scrape']['data']['name']).text.strip[0..60] + '[...]' : '',
          !@provider['scrape']['data']['size'].empty? ? row.css(@provider['scrape']['data']['size']).text.strip : '',
          !@provider['scrape']['data']['seed'].empty? ? row.css(@provider['scrape']['data']['seed']).text.strip.green : '',
          !@provider['scrape']['data']['leech'].empty? ? row.css(@provider['scrape']['data']['leech']).text.strip.red : ''
        ]

        key += 1
      end

      results
    end

    def results
      puts 'Results for : ' + @query
      puts 'From : ' + @from

      table = TTY::Table.new %i[# Category Title Size Seed Leech], @rows
      puts table.render(:unicode, padding: [0, 1, 0, 1])

      if @auto
        download @downloads.find { |v| v[:key] == 1 }
      else
        prompt
      end
    end

    def prompt
      prompt = TTY::Prompt.new(interrupt: :exit)
      choice = prompt.ask("Which torrent do you want to download? (1..#{@downloads.size} or ctrl+c/cmd+c to interrupt)",
                          convert: :int,
                          default: 1) do |c|
        c.in "1-#{@downloads.size}"
      end

      c = @downloads.find { |v| v[:key] == choice.to_i }
      download c
    end

    def download(choice)
      if choice[:url] =~ /^magnet:\?/
        puts '😏  Sorry, I cannot download magnet links. Please copy/paste the following link into your torrent client'
        puts choice[:url]
      else
        begin
          target_file_name  = choice[:name].tr("\n", ' ').squeeze(' ').strip + '.torrent'
          puts 'Downloading ' + target_file_name

          source            = Net::HTTP.get(URI.parse(choice[:url]))
          target_file       = File.join(@directory, target_file_name)

          File.write(target_file, source)
        rescue IOError => e
          # FIXME: what about HTTP errors? Net::HTTP throws a number of
          # exceptions. It would be wise to use another HTTP library for this
          # purpose
          puts '😵  There is an error! ' + e.message
        else
          puts '🥂  Downloaded!'

          # Open torrent option is only present in Darwin platform so there is
          # no need to check the platform here
          system("open '#{target_file}'") if @open_torrent
        end
      end
    end

    def threat_defence(page)
      return false unless page.text =~ /threat_defence.php/
      true
    end

    private

    def list_providers_and_exit
      puts "☠️  Provider '#{@from}' does not exist."
      puts "Please choose a valid provider from the following list:\n\n"

      Dir[File.expand_path('providers/*.yml')].each do |f|
        puts '- ' + File.basename(f).split('.').first
      end

      abort
    end

    def check_download_directory
      ioerr = false
      ioerr = "😱  Directory #{@directory} not found." unless File.exist? @directory or File.directory? @directory
      ioerr = "😱  Directory #{@directory} not writable." unless File.writable? @directory
      if ioerr
        puts ioerr
        abort 'Exiting'
      end
    end
  end
end
