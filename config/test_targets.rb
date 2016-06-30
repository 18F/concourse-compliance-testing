require 'minitest/autorun'
require_relative '../lib/team_data_filterer'

describe 'targets.json' do
  def targets_data
    filename = File.expand_path('targets.json', __dir__)
    TeamDataFilterer.read_json(filename)
  end

  it "has all lower case names" do
    targets_data.each do |project|
      project['name'].wont_match(/[A-Z]/)
    end
  end

  it "contains links" do
    targets_data.each do |target|
      target['links'].class.must_equal(Array)
    end
  end
end
