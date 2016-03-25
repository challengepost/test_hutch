module TestHutch
  module Publishers
    class FakePublisher
      def publish(routing_key, message, hutch)
        hutch.enqueue_message(routing_key, message)
      end
    end
  end
end
