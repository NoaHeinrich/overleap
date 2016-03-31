require 'faraday'
require 'json'

API_URL = "http://not_real.com/customer_scoring?"
module Overleap
  class Report
    attr_reader :propensity, :ranking
    def initialize(attributes)
      @propensity = attributes["propensity"]
      @ranking = attributes["ranking"]
    end

    def self.generate_score(data)
      income = data["income"]
      zipcode = data["zipcode"]
      age = data["age"]
      response = Faraday.get("#{API_URL}income=#{income}&zipcode=#{zipcode}&age=#{age}")
      attributes = JSON.parse(response.body)
      new(attributes)
    end
  end
end