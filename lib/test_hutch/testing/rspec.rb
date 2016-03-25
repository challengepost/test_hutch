module TestHutch
  module Testing
    module Rspec
      extend self

      def before_each
        # Clears out the messages for tests using the Fake mode.
        TestHutch.reset!

        example = RSpec.current_example

        if example.metadata[:hutch] == :fake
          TestHutch.fake!
        elsif example.metadata[:hutch] == :inline
          TestHutch.inline!
        elsif example.metadata[:type] == :acceptance
          TestHutch.inline!
        else
          TestHutch.disabled!
        end
      end
    end
  end
end
