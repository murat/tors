require 'tors/version'
require 'tors/search'
require 'colorize'
require 'optparse'

module TorS
  options = {}
  OptionParser.new do |opts|
    opts.on('-s=s', '--search=s', 'Search term [SEARCH]') do |s|
      options[:search] = s
    end
    opts.on('-p=p', '--provider=p', 'From provider name [PROVIDER]') do |p|
      options[:provider] = p
    end
    opts.on('-a=a', '--auto-download=a', 'Auto download best choice') do |a|
      options[:auto] = a || true
    end
  end.parse!

  TorS::Search.new(options[:search], options[:provider] || 'katcr', options[:auto] || false)
end
