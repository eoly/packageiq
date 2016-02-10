class PackageIQ < FPM::Cookery::Recipe
  name 'packageiq'
  version '0.1.0'

  source '', :with => :noop

  description 'PackageIQ'

  maintainer 'Eric Olsen <eric@ericolsen.net'

  homepage 'https://github.com/eoly/packageiq'

  depends ['rubygem-packageiq',
           'rubygem-bunny',
           'rubygem-json',
           'rubygem-elasticsearch',
           'rubygem-sneakers']

  config_files ['/etc/packageiq/rabbitmq.json',
                '/etc/packageiq/indexer.json',
                '/etc/packageiq/elasticsearch.json']

  chain_package true
  chain_recipes ['bunny',
                 'packageiq',
                 'amqp-protocol',
                 'faraday',
                 'json',
                 'multi_json',
                 'multipart-post',
                 'serverengine',
                 'sigdump',
                 'thor',
                 'thread',
                 'elasticsearch',
                 'elasticsearch-api',
                 'elasticsearch-model',
                 'elasticsearch-persistence',
                 'elasticsearch-transport',
                 'sneakers']

  post_install 'postinst'

  def build
  end

  def install
    etc('packageiq').mkdir
    etc('packageiq').install workdir('../etc/packageiq/rabbitmq.json')
    etc('packageiq').install workdir('../etc/packageiq/elasticsearch.json')
    etc('packageiq').install workdir('../etc/packageiq/indexer.json')
    lib('systemd/system').install workdir('../lib/systemd/system/piq_indexer.service')
  end
end
