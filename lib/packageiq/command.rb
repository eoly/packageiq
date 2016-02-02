require 'open3'

module Packageiq
  # run system commands
  class Command
    attr_accessor :command

    def initialize(args = {})
      @command = args[:command] if args[:command]
    end

    attr_reader :stdout, :stderr, :status
    def run
      @stdout, @stderr, @status = Open3.capture3(@command)
    end
  end
end
