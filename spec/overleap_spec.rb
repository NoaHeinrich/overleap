require_relative 'spec_helper'

describe Overleap do
  before(:all) do
    hash = { propensity: 1, ranking: 'C' }
    js = JSON.generate(hash)
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/customer_scoring') { |env| [200, {}, js] }
    end

    @test = Faraday.new do |builder|
      builder.adapter :test, stubs do |stub|
      end
    end

    @data = { income: 20000, zipcode: 60641, age: 25 }
  end

  it 'has a version number' do
    expect(Overleap::VERSION).not_to be nil
  end

  describe Overleap::Report do
    describe "#new" do
      it "creates an Overlap::Report object" do
        report = Overleap::Report.new({ "propensity" => 1, "ranking" => "C" })
        expect(report).to be_a Overleap::Report
      end

      it "raises an argument error if not given a propensity" do
        expect{ Overleap::Report.new({ "ranking" => "C" }) }.to raise_error(ArgumentError)
      end

      it "raises an argument error if not given a ranking" do
        expect{ Overleap::Report.new({ "propensity" => 1 }) }.to raise_error(ArgumentError)
      end

      it "raises an error if not given parameters" do
        expect{ Overleap::Report.new }.to raise_error(ArgumentError)
      end
    end

    describe "#generate_report" do
      it "creates a Report given a faraday source and data" do
        response = Overleap::Report.generate_report(@test, @data)
        expect(response).to be_a Overleap::Report
      end

      it "generates a report with a propensity and ranking" do
        response = Overleap::Report.generate_report(@test, @data)
        expect(response.propensity).to eq 1
        expect(response.ranking).to eq "C"
      end

      it "raises a TypeError if not given a Faraday connection" do
        expect{ Overleap::Report.generate_report(5, @data) }.to raise_error(TypeError)
      end

      it "raises a RuntimeError if data does not include income" do
        bad_data = { zipcode: 60641, age: 25 }
        expect{ Overleap::Report.generate_report(@test, bad_data)}.to raise_error(RuntimeError)
      end

      it "raises a RuntimeError if data does not include zipcode" do
        bad_data = { income: 40, age: 25 }
        expect{ Overleap::Report.generate_report(@test, bad_data)}.to raise_error(RuntimeError)
      end

      it "raises a RuntimeError if the response does not include the correct data" do
        hash = { ranking: 'C' }
        js = JSON.generate(hash)
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/customer_scoring') { |env| [200, {}, js] }
        end

        test = Faraday.new do |builder|
          builder.adapter :test, stubs do |stub|
          end
        end

        expect{ Overleap::Report.generate_report(test, @data) }.to raise_error(RuntimeError)
      end
    end

    describe "#create_connection" do
      it "creates a Faraday Connection" do
        url = "http://jsonplaceholder.typicode.com"
        stub_request(:get, url)
        connection = Overleap::Report.create_connection(url)
        expect(connection).to be_a Faraday::Connection
      end

      it "raises an error if given an invalid url" do
        url = "http://fake-url.com"
        WebMock.allow_net_connect!
        expect{ Overleap::Report.create_connection(url) }.to raise_error(Faraday::ConnectionFailed)
      end
    end
  end

end
