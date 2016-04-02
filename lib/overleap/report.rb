require 'faraday'
require 'json'
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
      response = source.get "/customer_scoring",
        { :income => data[:income],
        :zipcode => data[:zipcode],
        :age => data[:age] }
      attributes = JSON.parse(response.body)
      check_response(attributes)
      new(attributes)
    end

    def self.create_connection(url)
      connection = Faraday.new(:url => url) do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      end
      connection.get
      connection
    end

    private

    def self.check_faraday(source)
      raise TypeError, "Use a Faraday Connection" unless source.class == Faraday::Connection
    end

    def self.check_data(data)
      raise RuntimeError, "The information you entered was either incomplete or incorrect" unless data.has_key?(:income) && data.has_key?(:zipcode) && data.has_key?(:age)
    end

    def self.check_response(response)
      raise RuntimeError, "The response did not include correct data" unless response.has_key?("propensity") && response.has_key?("ranking")
    end
  end
end
