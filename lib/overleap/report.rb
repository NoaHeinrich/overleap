require 'faraday'
require 'json'
module Overleap
  class Report
    attr_reader :propensity, :ranking
    # def initialize(attributes)
    #   raise ArgumentError unless attributes.has_key?("propensity") && attributes.has_key?("ranking")

    #   @propensity = attributes["propensity"]
    #   @ranking = attributes["ranking"]
    # end

    def initialize(url, data)
      connection = make_connection(url)
      response = get_response(connection, data)
      @propensity = response["propensity"]
      @ranking = response["ranking"]
    end

    def self.make_connection(url)
      connection = Faraday.new(:url => url) do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      end
      connection
    end

    def self.get_response(socket, data)
      check_faraday(socket)
      check_data(data)
      response = socket.get "/customer_scoring",
        { :income => data[:income],
        :zipcode => data[:zipcode],
        :age => data[:age] }
      attributes = JSON.parse(response.body)
      check_response(attributes)
      attributes
    end


    # def self.generate_report(source, data)
    #   check_faraday(source)
    #   check_data(data)
    #   response = source.get "/customer_scoring",
    #     { :income => data[:income],
    #     :zipcode => data[:zipcode],
    #     :age => data[:age] }
    #   attributes = JSON.parse(response.body)
    #   check_response(attributes)
    #   new(attributes)
    # end

    # def self.create_connection(url)
    #   connection = Faraday.new(:url => url) do |faraday|
    #     faraday.request  :url_encoded
    #     faraday.response :logger
    #     faraday.adapter  Faraday.default_adapter
    #   end
    #   connection.get
    #   connection
    # end

    private

    def self.check_faraday(source)
      raise TypeError, "Connection not valid. Please use create_connection with a valid url to create a Faraday connection." unless source.is_a? Faraday::Connection
    end

    def self.check_data(data)
      raise RuntimeError, "The information you entered was either incomplete or incorrect. Please include income, zipcode, and age." unless data.has_key?(:income) && data.has_key?(:zipcode) && data.has_key?(:age)
    end

    def self.check_response(response)
      raise RuntimeError, "The received response did not include correct data. Please check that your source leads to the correct API." unless response.has_key?("propensity") && response.has_key?("ranking")
    end
  end
end
