module Batsir
  class Config
    class << self

      # Adapted from Merb::Config class

      attr_accessor :config

      def defaults
        @defaults ||= {
          :amqp_host => 'localhost',
          :amqp_port => 5672,
          :amqp_user => 'guest',
          :amqp_pass => 'guest',
          :amqp_vhost => '/',
          :db_host => 'localhost',
          :db_name => 'batsir',
          :db_user => 'postgres',
          :db_pass => 'postgres',
          :log_name => 'batsir',
          :redis_url => 'redis://localhost:6379/0',
          :sidekiq_queue => 'batsir'
        }
      end

      # Returns the current configuration or sets it up
      def configuration
        @config ||= setup
      end

      # Yields the configuration.
      #
      # ==== Block parameters
      # c<Hash>:: The configuration parameters.
      #
      # ==== Examples
      #   Batsir::Config.use do |config|
      #     config[:exception_details] = false
      #     config[:log_stream]        = STDOUT
      #   end
      #
      # ==== Returns
      # nil
      #
      # :api: public
      def use
        yield configuration
        nil
      end

      # Detects whether the provided key is in the config.
      #
      # ==== Parameters
      # key<Object>:: The key to check.
      #
      # ==== Returns
      # Boolean:: True if the key exists in the config.
      #
      # :api: public
      def key?(key)
        configuration.key?(key)
      end

      # Retrieve the value of a config entry.
      #
      # ==== Parameters
      # key<Object>:: The key to retrieve the parameter for.
      #
      # ==== Returns
      # Object:: The value of the configuration parameter.
      #
      # :api: public
      def [](key)
        configuration[key]
      end

      # Set the value of a config entry.
      #
      # ==== Parameters
      # key<Object>:: The key to set the parameter for.
      # val<Object>:: The value of the parameter.
      #
      # :api: public
      def []=(key, val)
        configuration[key] = val
      end

      # Remove the value of a config entry.
      #
      # ==== Parameters
      # key<Object>:: The key of the parameter to delete.
      #
      # ==== Returns
      # Object:: The value of the removed entry.
      #
      # :api: public
      def delete(key)
        configuration.delete(key)
      end

      # Resets the configuration to its default state
      #
      def reset
        setup
      end

      # Retrieve the value of a config entry, returning the provided default if the key is not present
      #
      # ==== Parameters
      # key<Object>:: The key to retrieve the parameter for.
      # default<Object>::
      #   The default value to return if the parameter is not set.
      #
      # ==== Returns
      # Object:: The value of the configuration parameter or the default.
      #
      # :api: public
      def fetch(key, default)
        configuration.fetch(key, default)
      end

      # Returns the configuration as a hash.
      #
      # ==== Returns
      # Hash:: The config as a hash.
      #
      # :api: public
      def to_hash
        configuration
      end

      # Sets up the configuration by storing the given settings.
      #
      # ==== Parameters
      # settings<Hash>::
      #   Configuration settings to use. These are merged with the defaults.
      #
      # ==== Returns
      # The configuration as a hash.
      #
      # :api: private
      def setup(settings = {})
        @config = defaults.merge(settings)
      end

      # Set configuration parameters from a code block, where each method
      # evaluates to a config parameter.
      #
      # ==== Parameters
      # &block:: Configuration parameter block.
      #
      # ==== Examples
      #   # Set environment and log level.
      #   Batsir::Config.configure do
      #     environment "development"
      #     log_level   "debug"
      #   end
      #
      # ==== Returns
      # nil
      #
      # :api: public
      def configure(&block)
        ConfigBlock.new(self, &block) if block_given?
        nil
      end

      # Allows retrieval of single key config values via Batsir::Config.<key>
      # Allows single key assignment via Merb.config.<key> = ...
      #
      # ==== Parameters
      # method<~to_s>:: Method name as hash key value.
      # *args:: Value to set the configuration parameter to.
      #
      # ==== Returns
      # The value of the entry fetched or assigned to.
      #
      # :api: public
      def method_missing(method, *args)
        if method.to_s[-1,1] == '='
          self[method.to_s.tr('=','').to_sym] = args.first
        else
          self[method]
        end
      end

    end # class << self

    class ConfigBlock

      # Evaluates the provided block, where any call to a method causes
      # #[]= to be called on klass with the method name as the key and the arguments
      # as the value.
      #
      # ==== Parameters
      # klass<Object~[]=>:: The object on which to assign values.
      # &block:: The block which specifies the config values to set.
      #
      # ==== Returns
      # nil
      #
      # :api: private
      def initialize(klass, &block)
        @klass = klass
        instance_eval(&block)
      end

      # Assign args as the value of the entry keyed by method.
      #
      # :api: private
      def method_missing(method, *args)
        @klass[method] = args.first
      end

    end # ConfigBlock
  end # Config
end
