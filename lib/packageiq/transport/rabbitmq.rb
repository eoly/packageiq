require 'bunny'

module Packageiq
  module Transport
    # rabbitmq transport
    class Rabbitmq
      attr_accessor :host, :port, :ssl, :vhost, :user, :pass
      def initialize(args = {})
        @host   = args[:host] || '127.0.0.1'
        @port   = args[:port] || 5672
        @ssl    = args[:ssl] || false
        @vhost  = args[:vhost] || '/'
        @user   = args[:user] || 'guest'
        @pass   = args[:pass] || 'guest'
      end

      attr_reader :conn
      def start
        @conn = Bunny.new(host: host, port: port,
                          ssl: ssl, vhost: vhost,
                          user: user, pass: pass)
        conn.start
      end

      attr_reader :channel
      def create_channel
        @channel = conn.create_channel
      end

      def close_channel
        @channel.close_channel
      end

      attr_reader :queue
      def create_queue(name, opts = {})
        durable     = opts[:durable] || false
        auto_delete = opts[:auto_delete] || false
        exclusive   = opts[:exclusive] || false
        @queue      = channel.queue(name,
                                    durable: durable,
                                    auto_delete: auto_delete,
                                    exclusive: exclusive)
      end

      def queue_exists?(name)
        conn.queue_exists?(name)
      end
    end
  end
end
