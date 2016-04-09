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
    describe "#make_connection" do
      it "creates a Faraday connection" do
        connection = Overleap::Report.make_connection("http://jsonplaceholder.typicode.com")
        expect(connection).to be_a Faraday::Connection
      end
    end

    describe "#get_response" do
      it "returns a Hash" do
        response = Overleap::Report.get_response(@test, @data)
        expect(response).to be_a Hash
      end

      it "returns a Hash with correct data" do
        response = Overleap::Report.get_response(@test, @data)
        expect(response.has_key?("propensity")).to be true
        expect(response.has_key?("ranking")).to be true
      end

      it "raises a TypeError if not given a Faraday connection" do
        expect{ Overleap::Report.get_response("http://fake-url.com", @data) }.to raise_error(TypeError)
      end

      it "raises a RuntimeError when data does not include income" do
        bad_data = { zipcode: 60641, age: 25 }
        expect{ Overleap::Report.get_response(@test, bad_data) }.to raise_error(RuntimeError)
      end

      it "raises a RuntimeError when data does not include zipcode" do
        bad_data = { income: 60641, age: 25 }
        expect{ Overleap::Report.get_response(@test, bad_data) }.to raise_error(RuntimeError)
      end

      it "raises a RuntimeError if given data that is not a Hash" do
        expect{ Overleap::Report.get_response(@test, "dfasdfdsaf") }.to raise_error(TypeError)
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

        expect{ Overleap::Report.get_response(test, @data) }.to raise_error(RuntimeError)
      end

      it "raises an error if the response is not JSON" do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/customer_scoring') { |env| [200, {}, "C"] }
        end

        test = Faraday.new do |builder|
          builder.adapter :test, stubs do |stub|
          end
        end

        expect{ Overleap::Report.get_response(test, @data) }.to raise_error(JSON::ParserError )
      end

      it "raises an error if source leads to invalid url" do
        WebMock.allow_net_connect!
        socket = Overleap::Report.make_connection("http://fake-url.com")
        expect{ Overleap::Report.get_response(socket, @data) }.to raise_error(Faraday::ConnectionFailed, "The URL you entered was either invalid, or incorrect.")
      end

      it "raises an error if it receives an error code" do
        hash = { propensity: 1, ranking: 'C' }
        js = JSON.generate(hash)
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/customer_scoring') { |env| [404, {}, js] }
        end

        test = Faraday.new do |builder|
          builder.adapter :test, stubs do |stub|
          end
        end
        expect{ Overleap::Report.get_response(test, @data) }.to raise_error(RuntimeError)
      end
    end

    describe "#new" do
      before(:each) do
        WebMock.disable_net_connect!
        hash = { propensity: 1, ranking: 'C' }
        js = JSON.generate(hash)
        stub_request(:get, "http://jsonplaceholder.typicode.com/customer_scoring?age=25&income=20000&zipcode=60641").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).to_return(:status => 200, :body => js, :headers => {})
      end

      it "creates an Overleap Report" do
        url = "http://jsonplaceholder.typicode.com"
        report = Overleap::Report.new(url, @data)
        expect(report).to be_a Overleap::Report
      end

      it "creates a Report with a propensity and ranking" do
        url = "http://jsonplaceholder.typicode.com"
        report = Overleap::Report.new(url, @data)
        expect(report.propensity).to eq 1
        expect(report.ranking).to eq "C"
      end

      it "raises an error if given data not in a hash" do
        url = "http://jsonplaceholder.typicode.com"
        expect{ Overleap::Report.new(url, "Hi") }.to raise_error(TypeError)
      end

      it "raises an error if given data does not include income" do
        data = { zipcode: 60641, age: 25 }
        url = "http://jsonplaceholder.typicode.com"
        expect{ Overleap::Report.new(url, data) }.to raise_error(RuntimeError)
      end

      it "raises an error if given a bad url" do
        WebMock.allow_net_connect!
        expect{ Overleap::Report.new("http://fake-url.com", @data) }.to raise_error(Faraday::ConnectionFailed, "The URL you entered was either invalid, or incorrect.")
      end
    end
  end
end
