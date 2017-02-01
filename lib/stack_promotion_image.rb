require 'json'
require 'uri'

require_relative 'env'
require_relative 'image_metadata_fetcher'

class StackPromotionImage
  def initialize(stack: '', group: '', infra: '')
    @stack = stack
    @group = group
    @infra = infra
  end

  attr_reader :stack, :group, :infra

  def name
    @name ||= begin
      q = URI.encode_www_form(
        name: name_search,
        infra: infra,
        tags: "group_#{group}:true",
        'fields[images]' => 'name'
      )

      JSON.parse(
        `#{curl_exe} -f -s '#{env['JOB_BOARD_IMAGES_URL']}?#{q}'`
      ).fetch('data').map { |e| e['name'] }.sort.last
    end
  end

  def name_search
    {
      'gce' => "^travis-ci-#{stack}.*",
      'docker' => "^travisci/ci-#{stack}.*"
    }.fetch(infra)
  end

  def metadata
    @metadata ||= ImageMetadataFetcher.new(
      image_name: name,
      infra: infra
    ).fetch
  end

  private def env
    @env ||= Env.new
  end

  private def curl_exe
    @curl_exe ||= env.fetch('CURL_EXE', 'curl')
  end
end
