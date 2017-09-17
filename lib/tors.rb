require 'tors/version'
require 'tors/search'
require 'slop'

# Main module for passing options and initializing TorS::Search class
module TorS
  REQUIRE_AUTH = %w[zamunda].freeze

  opts = Slop.parse do |o|
    o.banner = 'usage: tors [options] SEARCH_STRING'
    o.string '-d', '--directory', 'Destination path for downloaded torrent', default: Dir.pwd
    o.string '-p', '--provider', 'Provider name', default: 'katcr'
    o.string '-u', '--username', 'Username for authentication'
    o.string '-w', '--password', 'Password for authentication'
    o.on     '-l', '--list-providers', 'List available providers' do
      puts '- 1337x'
      puts '- extratorrent'
      puts '- katcr'
      puts '- rarbg'
      puts '- thepiratebay'
      puts '- zamunda (requires authentication)'
      puts '- zooqle'
      exit
    end

    o.bool '-a', '--auto-download', 'Auto download best choice', default: false

    if RUBY_PLATFORM =~ /darwin/
      o.bool '-o', '--open', 'Open torrent after downloading', default: false
    end

    o.on '-h', '--help', 'Print help' do
      puts o
      exit
    end

    o.on '-v', '--version', 'Print version' do
      puts VERSION
      exit
    end
  end

  if opts.arguments.empty?
    puts opts
    exit
  end

  if REQUIRE_AUTH.include?(opts['provider'])
    if opts['username'].nil? || opts['password'].nil?
      puts "ERROR! Provider #{opts['provider']} requires username and password for authentication".red
      abort
    end
  end

  tors = TorS::Search.new(opts.arguments[0]) do |ts|
    ts.username      = opts['username']
    ts.password      = opts['password']
    ts.from          = opts['provider']
    ts.auto_download = opts.auto_download?
    ts.directory     = opts['directory']

    # We only have this option in Darwin platform and slop throws an exception
    # for non-defined parameters. That's the reason to check the platform here
    ts.open_torrent = RUBY_PLATFORM =~ /darwin/ ? opts.open? : false
  end

  tors.run

end
