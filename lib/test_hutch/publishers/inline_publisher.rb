module TestHutch
  module Publishers
    class InlinePublisher
      def publish(routing_key, message, hutch)
        hutch.enqueue_message(routing_key, message)
        hutch.process!
      end
    end
  end
end
