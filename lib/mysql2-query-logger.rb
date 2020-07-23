require 'benchmark'
require 'logger'

module Mysql2QueryLogger
  VERSION = '1.0.0'

  class Logger
    def initialize(file:, root_dir:, threshold_time:)
      @root_dir = root_dir
      @threshold_time = threshold_time
      @logger = ::Logger.new(file)
      @logger.formatter = proc { |severity, datetime, progname, message|
        message + "\n"
      }
    end

    def log(time, sql)
      return if time * 1000 < @threshold_time

      message = "#{format_time(time)} #{sql} #{format_caller}"
      @logger.info(message)
    end

    private

    def format_time(time)
      color = case
        when time < 0.01
          :green
        when time < 0.1
          :yellow
        else
          :red
      end
      colorize(color, "(#{(time * 1000).round(1)}ms)")
    end

    def format_caller
      loc = caller_locations.find {|c| c.path.match?('/gems/') == false && c.absolute_path != __FILE__ }
      return colorize(:gray, "(unknown)") unless loc

      path = @root_dir ? loc.absolute_path.sub("#{@root_dir}/", "") : loc.path
      colorize(:gray, "(#{path}:#{loc.lineno})")
    end

    def colorize(color, str)
      case color
      when :red
        "\e[31m#{str}\e[0m"
      when :green
        "\e[32m#{str}\e[0m"
      when :yellow
        "\e[33m#{str}\e[0m"
      when :gray
        "\e[90m#{str}\e[0m"
      end
    end
  end

  def self.enable(file: STDOUT, root_dir: nil, threshold_time: 0)
    Mysql2::Client.prepend(Mysql2QueryLogger::ClientMethods)
    Mysql2::Statement.prepend(Mysql2QueryLogger::StatementMethods)
    @logger = Mysql2QueryLogger::Logger.new(file: file, root_dir: root_dir, threshold_time: threshold_time)
  end

  def self.execute(sql)
    result = nil

    time = Benchmark.realtime do
      result = yield
    end

    @logger.log(time, sql)

    result
  end

  module ClientMethods
    def prepare(sql)
      super.tap { |stmt| stmt.instance_variable_set(:@_sql, sql) }
    end

    def query(sql, options = {})
      Mysql2QueryLogger.execute(sql) { super }
    end
  end

  module StatementMethods
    def execute(*args)
      Mysql2QueryLogger.execute(@_sql) { super }
    end
  end
end
