require 'bunny'
require 'json'

module Packageiq
  module Transport
    # rabbitmq transport
    class Rabbitmq
      attr_accessor :host, :port, :tls,
                    :tls_cert, :tls_key, :tls_ca_certificates,
                    :vhost, :user, :pass

      def initialize(args = {})
        @host                   = args[:host] || '127.0.0.1'
        @port                   = args[:port] || 5672
        @tls                    = args[:tls] || false
        @tls_cert               = args[:tls_cert] || ''
        @tls_key                = args[:tls_key] || ''
        @tls_ca_certificates    = args[:tls_ca_certificates] || []
        @vhost                  = args[:vhost] || '/'
        @user                   = args[:user] || 'guest'
        @pass                   = args[:pass] || 'guest'
      end

      # serialize message
      def self.serialize(message)
        JSON.parse(message)
      end

      attr_reader :conn

      # initialize bunny instance and start connection
      def start
        @conn = Bunny.new(host: host, port: port,
                          tls: tls, tls_cert: tls_cert,
                          tls_key: tls_key,
                          tls_ca_certificates: tls_ca_certificates,
                          vhost: vhost, user: user, pass: pass)
        @conn.start
      end

      attr_reader :channel

      # create rabbitmq channel
      def create_channel
        @channel = conn.create_channel
      end

      # close rabbitmq channel
      def close_channel
        @channel.close_channel
      end

      attr_reader :queue

      # create rabbitmq queue
      def create_queue(name, opts = {})
        durable     = opts[:durable] || false
        auto_delete = opts[:auto_delete] || false
        exclusive   = opts[:exclusive] || false
        @queue      = channel.queue(name,
                                    durable: durable,
                                    auto_delete: auto_delete,
                                    exclusive: exclusive)
      end

      # check if queue exists
      # returns boolean
      def queue_exists?(name)
        conn.queue_exists?(name)
      end
    end
  end
end
