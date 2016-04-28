require 'minitest/autorun'
require_relative '../lib/team_data_filterer'

describe 'targets.json' do
  it "has all lower case names" do
    filename = File.expand_path('targets.json', __dir__)
    data = TeamDataFilterer.read_json(filename)
    data.each do |project|
      project['name'].wont_match(/[A-Z]/)
    end
  end
end
