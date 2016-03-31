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
    end
  end

end
