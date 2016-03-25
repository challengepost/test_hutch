module TestHutch
  module Publishers
    class DisabledPublisher
      def publish(*); end
    end
  end
end
