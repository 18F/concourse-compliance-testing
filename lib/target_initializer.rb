require 'aws-sdk'
require 'set'

class TargetInitializer
  attr_reader :config, :targets

  def initialize(config, targets)
    @config = config
    @targets = targets
  end

  def run
    targets.each do |target|
      name = target['name']
      key = "results/#{name}.json"

      # since Concourse resources stall on a `get` if the remote file doesn't exist, we need to seed the last-results
      next if existing_project_keys.include?(key)

      print "ZAP results don't exist for #{name}. Creating..."
      seed_result(key)
      puts "done."
    end
  end

  private

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      access_key_id: config['aws-access-key'],
      secret_access_key: config['aws-secret-key'],
      region: 'us-east-1'
    )
  end

  def bucket
    config['aws-bucket']
  end

  def objects
    @objects ||= s3_client.list_objects(
      bucket: bucket,
      prefix: 'results/'
    )
  end

  def existing_project_keys
    @existing_project_keys ||= objects.contents.map(&:key).to_set.freeze
  end

  def seed_result(key)
    s3_client.put_object(
      bucket: bucket,
      key: key,
      body: '[]'
    )
  end
end
