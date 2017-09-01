require 'tors/version'
require 'tors/search'
require 'colorize'
require 'optparse'

module TorS
  options = {}
  OptionParser.new do |opts|
    opts.on('-h', '--help', 'Show usage instructions') do |_h|
      puts opts
      abort
    end
    opts.on('-s=s', '--search=s', 'Search term [SEARCH]') do |s|
      options[:search] = s
    end
    opts.on('-d=d', '--directory=d', 'Destination path for downloaded torrent [DIRECTORY]') do |d|
      options[:directory] = d
    end
    opts.on('-p=p', '--provider=p', 'Provider name [PROVIDER]') do |p|
      options[:provider] = p
    end
    opts.on('-l', '--list-providers', 'List providers') do |_l|
      Dir[File.expand_path('providers/*.yml')].each do |f|
        puts '- ' + File.basename(f).split('.').first
      end
      abort
    end
    opts.on('-a', '--auto-download', 'Auto download best choice') do
      options[:auto] = true
    end

    if RUBY_PLATFORM =~ /darwin/
      opts.on('-o', '--open', 'Open torrent after downloading') do
        options[:open] = true
      end
    end
  end.parse!

  tors = TorS::Search.new(options[:provider] || 'katcr') do |ts|
    ts.query        = options[:search]
    ts.auto         = options[:auto] || false
    ts.directory    = options[:directory] || Dir.pwd
    ts.open_torrent = options[:open] || false
  end

  tors.run
end
