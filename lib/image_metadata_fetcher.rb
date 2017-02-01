require 'tmpdir'
require_relative 'env'
require_relative 'image_metadata'

class ImageMetadataFetcher
  def initialize(image_name: '', infra: '', tarball_path: nil)
    @image_name = image_name
    @infra = infra
    @tarball_path = tarball_path
  end

  def fetch
    return nil if image_name.to_s.empty? || infra.to_s.empty?

    candidate_urls.each do |url|
      if system(
        curl_exe, '-fsSL', '-o', tarball_path, url,
        %i(out err) => '/dev/null'
      )
        return ImageMetadata.new(
          tarball: tarball_path,
          url: url,
          env: Env.new(base: {})
        )
      end
    end
    nil
  end

  attr_reader :image_name, :infra
  private :image_name
  private :infra

  private def env
    @env ||= Env.new
  end

  private def candidate_urls
    [
      File.join(
        s3_base_url,
        template_name,
        packer_builder_name,
        "image-metadata-#{image_name}.tar.bz2"
      ),
      File.join(
        s3_base_url,
        template_name,
        packer_builder_name,
        'packer-templates', 'tmp',
        "image-metadata-#{image_name}.tar.bz2"
      )
    ]
  end

  private def tarball_path
    @tarball_path ||= File.join(
      Dir.tmpdir,
      "image-metadata-#{image_name}.tar.bz2"
    )
  end

  private def s3_base_url
    @s3_base_url ||= env.fetch(
      'IMAGE_METADATA_BASE_URL',
      File.join(
        'https://s3.amazonaws.com',
        'travis-infrastructure-packer-build-artifacts',
        'travis-ci',
        'packer-templates'
      )
    )
  end

  private def template_name
    @template_name ||= "ci-#{image_name.to_s.split('-').fetch(2)}"
  end

  private def curl_exe
    @curl_exe ||= env.fetch('CURL_EXE', 'curl')
  end

  private def packer_builder_name
    {
      'gce' => 'googlecompute',
      'docker' => 'docker',
    }.fetch(infra)
  end
end
