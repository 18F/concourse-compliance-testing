require 'minitest/autorun'
require_relative '../team_data_filterer'

describe TeamDataFilterer do
  describe '.transform_project' do
    it "merges in attributes from the target" do
      project = {
        "name" => "foo",
        "links" => []
      }
      target = {
        "name" => "foo",
        "something" => 7
      }

      result = TeamDataFilterer.transform_project(project, target)
      expect(result).must_equal({
        "name" => "foo",
        "links" => [],
        "something" => 7
      })
    end

    it "sets `links` if not present" do
      project = { "name" => "foo" }
      target = { "name" => "foo" }

      result = TeamDataFilterer.transform_project(project, target)
      expect(result).must_equal({
        "name" => "foo",
        "links" => []
      })
    end
  end

  describe '.filtered_projects' do
    it "returns the list of projects, filtered by name" do
      projects = [
        {
          "name" => "foo",
          "links" => [],
        },
        {
          "name" => "bar",
          "links" => [],
          "something" => 7
        }
      ]
      targets = [
        { "name" => "bar" }
      ]

      results = TeamDataFilterer.filtered_projects(projects, targets)
      expect(results).must_equal [
        {
          "name" => "bar",
          "links" => [],
          "something" => 7
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
  end
end
