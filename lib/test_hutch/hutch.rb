module TestHutch
  class Hutch
    def initialize
      @publisher = TestHutch::Publishers::DisabledPublisher.new
      load!
    end

    def publish(routing_key, message = {})
      publisher.publish(routing_key, message, self)
    end

    def reset!
      queued_messages.clear
      remove_additional_consumers
    end

    # returns the instance of the consumer
    # returns the existing instance of the consumer
    # if it was previously registered
    def add_consumer(consumer_class)
      find_consumer(consumer_class) do |consumer_instance|
        return consumer_instance
      end

      register_consumer(consumer_class) do |_|
        additional_consumers << consumer_class
      end
    end

    def registered_consumers
      @consumers.values.flatten
    end

    def process!
      while queued_message = queued_messages.shift
        process_message(*queued_message)
      end

      queued_messages.clear
    end

    def enqueue_message(routing_key, message)
      queued_messages << [routing_key, message]
    end

    attr_accessor :consumers, :queued_messages, :publisher
    private
    attr_accessor :additional_consumers

    def process_message(routing_key, message)
      consumers_for(routing_key).each do |consumer|
        consumer.process(message.symbolize_keys)
      end
    end

    def consumers_for(routing_key)
      keys = routing_keys_matching(routing_key)
      consumers.values_at(*keys).flatten
    end

    def routing_keys_matching(routing_key)
      consumers.keys.select do |key|
        !!(regexpify_key(key) =~ routing_key)
      end
    end

    def load!
      @consumers = Hash.new { |hash, key| hash[key] = [] }
      @queued_messages = []
      @additional_consumers = []
      load_consumers
    end

    def load_consumers
      Dir.glob("#{Rails.root}/app/consumers/*.rb").each do |path|
        load_consumer(path)
      end
    end

    def load_consumer(path)
      file_name = File.basename(path, ".rb")
      consumer_class = file_name.camelize.safe_constantize
      register_consumer(consumer_class)
    end

    # Possible improvement: if Hutch actually supports it,
    # this method should return an array of keys
    def consumer_routing_key(consumer_class)
      consumer_class.routing_keys.to_a.first
    end

    # registered consumers will be able to consumer messages
    def register_consumer(consumer_class)
      key = consumer_routing_key(consumer_class)

      # we can't route without a key
      return if key.blank?

      new_consumer = consumer_class.new
      consumers[key] << new_consumer

      yield(new_consumer) if block_given?
    end

    def remove_additional_consumers
      additional_consumers.each do |consumer_class|
        remove_consumer(consumer_class)
      end
    end

    def remove_consumer(consumer_class)
      key = consumer_routing_key(consumer_class)

      consumers[key].delete_if do |consumer_instance|
        consumer_class == consumer_instance.class
      end
    end

    def find_consumer(consumer_class)
      consumer_instance = registered_consumers.find do |consumer|
        consumer_class == consumer.class
      end
      yield(consumer_instance) unless consumer_instance.nil?
    end

    def regexpify_key(key)
      matchers = {
        "." => "\\.",
        "#" => "(\\w+\\.)*(\\w+)",
        "*" => "(\\w+)",
      }

      regexp_key = key.gsub(/[.#*]/, matchers)

      %r{^#{regexp_key}$}
    end
  end
end
