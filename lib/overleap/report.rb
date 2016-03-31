require 'faraday'
require 'json'

# FARA = Faraday.new(:url => "http://jsonplaceholder.typicode.com") do |faraday|
#   faraday.request  :url_encoded
#   faraday.response :logger
#   faraday.adapter  Faraday.default_adapter
# end


module Overleap
  class Report
    attr_reader :propensity, :ranking
    def initialize(attributes)
      raise ArgumentError unless attributes.has_key?("propensity") && attributes.has_key?("ranking")
      @propensity = attributes["propensity"]
      @ranking = attributes["ranking"]
    end

    def self.generate_report(source, data)
      check_faraday(source)
      check_data(data)
      response = source.get "/customer_scoring", { :income => data[:income], :zipcode => data[:zipcode], :age => data[:age] }
      attributes = JSON.parse(response.body)
      new(attributes)
    end

    private
    def self.check_faraday(source)
      raise TypeError, "Use a Faraday Connection" unless source.class == Faraday::Connection
    end

    def self.check_data(data)
      raise RuntimeError, "The information you entered was either incomplete or incorrect" unless data.has_key?(:income) && data.has_key?(:zipcode) && data.has_key?(:age)
    end

  end
end
