require 'faraday'
require 'json'
module Overleap
  class Report
    attr_reader :propensity, :ranking
    def initialize(url, data)
      connection = Overleap::Report.make_connection(url)
      response = Overleap::Report.get_response(connection, data)
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
      attributes = nil
      check_faraday(socket)
      check_data(data)
      response = socket.get "/customer_scoring",
        { :income => data[:income],
        :zipcode => data[:zipcode],
        :age => data[:age] }
      check_status_code(response.status)
      attributes = JSON.parse(response.body)
      check_response(attributes)
      attributes
    end

    private

    def self.check_faraday(source)
      raise TypeError, "Connection not valid. Please use create_connection with a valid url to create a Faraday connection." unless source.is_a? Faraday::Connection
    end

    def self.check_data(data)
      if data.is_a? Hash
        raise RuntimeError, "The information you entered was either incomplete or incorrect. Please include income, zipcode, and age." unless data.has_key?(:income) && data.has_key?(:zipcode) && data.has_key?(:age)
      else
        raise TypeError, "Please include income, zipcode, and age in a Hash."
      end
    end

    def self.check_response(response)
      if response.is_a? Hash
        raise RuntimeError, "The received response did not include correct data. Please check that your source leads to the correct API." unless response.has_key?("propensity") && response.has_key?("ranking")
      else
        raise TypeError, "The received response was not a JSON. Please check that your source leads to the correct API."
      end
    end

    def self.check_status_code(code)
      raise RuntimeError, "Error code #{code} received. Please confirm that you are connecting to the correct website." unless code == 200
    end
  end
end
