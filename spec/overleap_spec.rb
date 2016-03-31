require_relative 'spec_helper'
hash = { propensity: 1, ranking: 'C' }

js = JSON.generate(hash)
STUBS = Faraday::Adapter::Test::Stubs.new do |stub|
  stub.get('/customer_scoring') { |env| [200, {}, js] }
end
TEST = Faraday.new do |builder|
  builder.adapter :test, STUBS do |stub|
  end
end

describe Overleap do
  it 'has a version number' do
    expect(Overleap::VERSION).not_to be nil
  end

end
