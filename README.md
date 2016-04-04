# Rubycrap

This is an implementation/interpretation of Alberto Savoia's C.R.A.P. Metric for RUBY (https://www.artima.com/weblogs/viewpost.jsp?thread=215899).
Rubycrap works with the "flog score" instead of the cyclomatic complexity because be belive it is more meaningful for Ruby.
It should work with Ruby 1.9+


## Installation

To build the gem you need to do:
```
	$ gem build rubycrap.gemspec
```

## Usage

Requirements: 

Simplecov (https://github.com/colszowka/simplecov with 'simplecov-json' gem) to generate a coverage.json file.
e.g.
```
	$ cd test/testapp;bundle install
	$ COVERAGE=true rspec spec
```
	=> Should result in coverage/coverage.json

To generate the rubycrap metric you need to pass a simplecov .json file as the 1st argument
```
	$ ruby -Ilib ./bin/rubycrap test/testapp/coverage/coverage.json
```

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ingojauch/rubycrap. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).