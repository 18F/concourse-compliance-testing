require 'minitest/autorun'
require_relative '../team_data_filterer'

def simple_project(name = "foo", options = {})
  {
    "name" => name
  }.merge options
end

describe TeamDataFilterer do
  describe '.transform_links' do
    it "converts String `links` to the Hash format" do
      links = [
        "https://example1.com",
        {
          "url" => "https://example2.com",
          "text" => "example2"
        }
      ]

      results = TeamDataFilterer.transform_links(links)
      expect(results).must_equal([
        {
          "url" => "https://example1.com"
        },
        {
          "url" => "https://example2.com",
          "text" => "example2"
        }
      ])
    end
  end

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
      expect(result).must_equal(
        "name" => "foo",
        "links" => [],
        "something" => 7
      )
    end

    it "sets `links` if not present" do
      project = simple_project("foo")
      target = simple_project("foo")

      result = TeamDataFilterer.transform_project(project, target)
      expect(result).must_equal(
        "name" => "foo",
        "links" => []
      )
    end
  end

  describe '.filtered_projects' do
    it "returns the list of projects, filtered by name" do
      projects = [
        {
          "name" => "foo",
          "links" => []
        },
        {
          "name" => "bar",
          "links" => [],
          "something" => 7
        }
      ]
      targets = [simple_project("bar")]

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
      targets = [simple_project("foo")]

      results = TeamDataFilterer.filtered_projects([], targets)
      expect(results).must_equal [
        {
          "name" => "foo",
          "links" => []
        }
      ]
    end

    it "downcases target names when filtering projects" do
      results = TeamDataFilterer.filtered_projects(
        [simple_project("foo")], [simple_project("FOO")]
      )
      expect(results).must_equal [
        {
          "name" => "foo",
          "links" => []
        }
      ]
    end

    it "downcases project names when filtering projects" do
      results = TeamDataFilterer.filtered_projects(
        [simple_project("FOO")], [simple_project("foo")]
      )
      expect(results).must_equal [
        {
          "name" => "foo",
          "links" => []
        }
      ]
    end
  end
end
