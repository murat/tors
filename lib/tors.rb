require 'tors/version'
require 'tors/search'
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
    opts.on('-u=u', '--username=u', 'Username for authentication') do |u|
      options[:username] = u
    end
    opts.on('-w=p', '--password=p', 'Password for authentication') do |p|
      options[:password] = p
    end
    opts.on('-l', '--list-providers', 'List providers') do |_l|
      puts '- 1337x'
      puts '- extratorrent'
      puts '- katcr'
      puts '- rarbg'
      puts '- thepiratebay'
      puts '- zamunda'
      puts '- zooqle'
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
    ts.username     = options[:username]
    ts.password     = options[:password]
    ts.query        = options[:search]
    ts.auto         = options[:auto] || false
    ts.directory    = options[:directory] || Dir.pwd
    ts.open_torrent = options[:open] || false
  end

  tors.run
end
