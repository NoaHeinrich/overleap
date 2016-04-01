# Overleap

Overleap is a simple gem written for Leapfrog Online's coding challenge. It integrates with a hypothetical API, and creates an object meant to represent client data.

## Installation

I have not pushed this to Rubygems, so for now you can include Overleap like you would any other module.

Dependencies:
ruby 2.1.6
rspec 3.4.0
json 1.8.3
webmock 1.24.2
faraday 0.9.2
rake 10.5.0

Run
    bundle install
To install the gems necessary.

To run the test suite, simply type
    rspec
from the root directory.

## Usage

This gem can be used to get a score report from an API that provides this information. It uses the Faraday gem to manage HTTP connections. To establish a Faraday connection:
    source = Overleap::Report.create_connection(url)
This will create a connection that can be used to connect to the API. To generate a report, do the following:
    report = Overleap::Report.generate_report(source, { income: 1000, zipcode: 12345, age: 25 })

    report.propensity
    #=> .01212121

    report.ranking
    #=> "C"
The data you provide must include income, zipcode, and age in order to generate a report.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NoahHeinrich/overleap.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

