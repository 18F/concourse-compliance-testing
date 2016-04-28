require 'minitest/autorun'
require_relative '../lib/team_data_filterer'

describe TeamDataFilterer do
  describe '.transform_links' do
    it "converts String `links` to the Hash format" do
      links = ["https://example1.gov"]
      results = TeamDataFilterer.transform_links(links)
      results.must_equal([
        {
          "url" => "https://example1.gov"
        }
      ])
    end

    it "passes Hash format links through" do
      links = [
        {
          "url" => "https://example2.gov",
          "text" => "example2"
        }
      ].freeze

      results = TeamDataFilterer.transform_links(links)
      results.must_equal(links)
    end

    it "removes links that don't end in .gov" do
      links = %w(
        https://example1.com
        https://example1.com/foo
        https://example2.gov
        https://example2.gov/foo
      )

      results = TeamDataFilterer.transform_links(links)
      urls = results.map { |link| link['url'] }
      urls.must_equal(%w(
        https://example2.gov
        https://example2.gov/foo
      ))
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
      result.must_equal(
        "name" => "foo",
        "links" => [],
        "something" => 7
      )
    end

    it "sets `links` if not present" do
      project = { "name" => "foo" }
      target = { "name" => "foo" }

      result = TeamDataFilterer.transform_project(project, target)
      result.must_equal(
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
      targets = [
        { "name" => "bar" }
      ]

      results = TeamDataFilterer.filtered_projects(projects, targets)
      results.must_equal [
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
      results.must_equal [
        {
          "name" => "foo",
          "links" => []
        }
      ]
    end
  end
end
