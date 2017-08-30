# TorS

[![Licence](https://img.shields.io/github/license/muratbsts/tors.svg)](https://github.com/muratbsts/tors/blob/master/LICENCE)
[![Release](https://img.shields.io/github/release/muratbsts/tors.svg)](https://github.com/muratbsts/tors/releases)
[![Build](https://travis-ci.org/muratbsts/tors.svg?branch=master)](https://travis-ci.org/muratbsts/tors)
[![Issues](https://img.shields.io/github/issues/muratbsts/tors.svg)](https://github.com/muratbsts/tors/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/muratbsts/tors.svg)](https://github.com/muratbsts/tors/pulls)

[![Downloads](https://img.shields.io/gem/dt/tors.svg)](https://rubygems.org/gems/tors)

Yet another torrent searching application for your command line.    
But this has an option for automatically download the best torrent.

[Read Yardoc from here](http://muratbt.com/tors/doc)... 🤓

[Come here](https://github.com/muratbsts/tors) for stars or forks... 🙃 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tors'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tors

## Usage

Open your terminal and run this command:

    $ tors -s 'game of thrones'

It will list torrents ordered descending by seeder from **katcr**.

**Wait! Why katcr?**

Because katcr fastest provider for scrabing currently.

**Is there another provider and how can I change it?**

Yep, there is a few provider option.

| Provider          | Status |
|:------------------|:------:|
| katcr             | ✅     |
| rarbg             | ✅     |
| thepiratebay      | ✅     |
| extratorrent      | ✅     |
| 1337x             | ✅     |
| zooqle            | ☑️     |
| torrentfunk       | ☑️     |
| limetorrents      | ☑️     |

Use `-p PROVIDER` flag for scrape another providers.

    $ tors -s 'game of thrones' -p thepiratebay

And then It will ask for **which torrent you want to download?** You can answer with a torrent number seen on list.

You can use `-a 1` flag for automatically download the best torrent. Example:

    $ tors -s 'game of thrones' -p 1337x -a 1

You can use `-d TARGET` flag for set destination storage path. Example:

    $ tors -s 'Assassins' -d $HOME/Downloads -a 1

And you can list all active providers and usage instructions with `-h` or `--help` flag.

    $ tors -h
    Usage: tors [options]
        -s, --search=s                   Search term [SEARCH]
        -p, --provider=p                 From provider name [PROVIDER]
        -a, --auto-download=a            Auto download best choice
        -d, --directory=d                Destination torrent download directory

[![See it in action](https://asciinema.org/a/No1Zdfk3gYoCYdGb2XUdFaUyS.png)](https://asciinema.org/a/No1Zdfk3gYoCYdGb2XUdFaUyS)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/muratbsts/TorS](https://github.com/muratbsts/tors). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TorS project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/muratbsts/tors/blob/master/CODE_OF_CONDUCT.md).
