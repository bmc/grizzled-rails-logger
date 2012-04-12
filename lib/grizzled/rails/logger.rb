# +Grizzled::Rails::Logger+ is an extension to the stock Rails 3
# logger, providing additional logging options and capablities.
#
# Author::    Brian M. Clapper (mailto:bmc@clapper.org)
# Copyright:: Copyright (c) 2012 Brian M. Clapper
# License::   BSD

require 'active_support/buffered_logger'
require 'term/ansicolor'
require 'ostruct'

module Grizzled # :nodoc:
  module Rails # :nodoc:

    # Logger is the public face of this gem.
    module Logger

      # Configuration constants
      Configuration = OpenStruct.new(
          :flatten    => true,
          :format     => '[%T] (%S) %P %M',
          :timeformat => '%Y/%m/%d %H:%M:%S',
          :colorize   => true,
          :colors     => {
            :debug => Term::ANSIColor.cyan,
            :warn  => Term::ANSIColor.yellow + Term::ANSIColor.bold,
            :fatal => Term::ANSIColor.red + Term::ANSIColor.bold,
            :error => Term::ANSIColor.red
          }
      )

      # Configure the plugin. Use like:
      #
      #     Grizzled::Rails::Logger.configure do |cfg|
      #       cfg.flatten = false
      #       ...
      #     end
      def configure(&block)
        block.call Configuration
      end

      module_function :configure

      # The actual logging extension sits in here.
      module Extension # :nodoc:

        Severity = ActiveSupport::BufferedLogger::Severity
        SEVERITIES = Severity.constants.sort_by { |c| Severity.const_get(c) }

        ERROR = ActiveSupport::BufferedLogger::ERROR
        WARN  = ActiveSupport::BufferedLogger::WARN
        FATAL = ActiveSupport::BufferedLogger::FATAL
        DEBUG = ActiveSupport::BufferedLogger::DEBUG
        INFO  = ActiveSupport::BufferedLogger::INFO

        SEVERITY_MAP = {
          DEBUG => :debug,
          WARN  => :warn,
          FATAL => :fatal,
          ERROR => :error,
          INFO  => :info
        }

        def self.included(base)
          base.class_eval do
            alias_method_chain :add, :grizzling
          end
        end

        def exception(message, ex, progname = nil)
          ex_message = "#{ex.class} (backtrace):\n#{ex.backtrace.join("\n")}"
          if message.nil? || (message.length == 0)
            message = "#{ex_message}"
          else
            message << "\n#{ex_message}"
          end

          do_add(ERROR, message, progname, :flatten => false)
        end

        def add_with_grizzling(severity, message = nil, progname = nil, &block)
          do_add(severity, message, progname, &block)
        end

        private

        def do_add(severity, message, progname, options = {}, &block)
          return if @level > severity

          if message.nil?
            if block_given?
              if severity < @level
                return true
              end
              message = yield
            end
          end

          flatten = options.fetch(:flatten, Configuration.flatten)
          message.gsub!("\n", '') if flatten
          time = Time.now.strftime(Configuration.timeformat)
          pid = $$.to_s
          sev = SEVERITIES[severity].to_s

          message = Configuration.format.gsub("%T", time).
                                         gsub("%P", pid).
                                         gsub("%S", sev).
                                         gsub("%M", message)
      
          if Configuration.colorize
            color = Configuration.colors[SEVERITY_MAP[severity]]
            message = "#{color}#{message}#{Term::ANSIColor.reset}" if color
          end

          add_without_grizzling(severity, message, progname, &block)
        end
      end

      # Bind it into Rails.
      class Railtie < ::Rails::Railtie
        ActiveSupport::BufferedLogger.send(:include, ::Grizzled::Rails::Logger::Extension)
      end
    end
  end
end
