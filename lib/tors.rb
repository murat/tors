require 'tors/version'
require 'tors/search'
require 'colorize'
require 'optparse'

module TorS
  options = {}
  OptionParser.new do |opts|
    opts.on('-h', '--help', 'Show usage instructions') do |s|
      puts opts
      abort
    end
    opts.on('-s=s', '--search=s', 'Search term [SEARCH]') do |s|
      options[:search] = s
    end
    opts.on('-d=d', '--directory=d', 'Destination path for download torrent [DIRECTORY]') do |d|
      options[:directory] = d
    end
    opts.on('-p=p', '--provider=p', 'Provider name [PROVIDER]') do |p|
      options[:provider] = p
    end
    opts.on('-a', '--auto-download', 'Auto download best choice') do
      options[:auto] = true
    end
  end.parse!

  TorS::Search.new(options[:search], options[:provider] || 'katcr', options[:auto] || false, options[:directory] || Dir.pwd)
end