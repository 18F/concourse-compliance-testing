require 'minitest/autorun'
require_relative '../team_data_filterer'

describe TeamDataFilterer do
  describe '.filtered_projects' do
    it "returns the list of projects, filtered by name" do
      projects = [
        {
          "name" => "foo",
          "something" => 6
        },
        {
          "name" => "bar",
          "something_else" => 7
        }
      ]
      targets = [
        { "name" => "bar" }
      ]

      results = TeamDataFilterer.filtered_projects(projects, targets)
      expect(results).must_equal [
        {
          "name" => "bar",
          "something_else" => 7
        }
      ]
    end

    it "handles a target not present in the projects" do
      targets = [
        { "name" => "foo" }
      ]

      results = TeamDataFilterer.filtered_projects([], targets)
      expect(results).must_equal []
    end

    it "merges in attributes from the target" do
      projects = [
        {
          "name" => "foo",
          "something" => 6
        },
      ]
      targets = [
        {
          "name" => "foo",
          "something_else" => 7
        }
      ]

      results = TeamDataFilterer.filtered_projects(projects, targets)
      expect(results).must_equal [
        {
          "name" => "foo",
          "something" => 6,
          "something_else" => 7
        }
      ]
    end
  end
end
