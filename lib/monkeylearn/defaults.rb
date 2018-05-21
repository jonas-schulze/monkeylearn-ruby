module Monkeylearn
  module Defaults
    # Constants
    DEFAULT_BATCH_SIZE = 200
    MAX_BATCH_SIZE = 200
    # Configurable options
    BASE_URL = 'https://api.monkeylearn.com/v3/'
    WAIT_ON_THROTTLE = true

    class << self
      def options
        Hash[Monkeylearn::Configurable.keys.map{|key| [key, send(key)]}]
      end

      def base_url
        ENV['MONKEYLEARN_API_BASE_URL'] || BASE_URL
      end

      def token
        ENV['MONKEYLEARN_TOKEN'] || nil
      end

      def wait_on_throttle
        ENV['MONKEYLEARN_WAIT_ON_THROTTLE'] || WAIT_ON_THROTTLE
      end

      def max_batch_size
        MAX_BATCH_SIZE
      end

      def default_batch_size
        DEFAULT_BATCH_SIZE
      end
    end
  end
end
