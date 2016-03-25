module TestHutch
  extend self

  delegate \
    :publish,
    :add_consumer,
    :registered_consumers,
    :reset!,
    :queued_messages,
    :process!,
    :registered_consumers,
    to: :hutch

  def hutch
    @hutch ||= TestHutch::Hutch.new
  end

  def inline!
    hutch.publisher = TestHutch::Publishers::InlinePublisher.new
  end

  def disabled!
    hutch.publisher = TestHutch::Publishers::DisabledPublisher.new
  end

  def fake!
    hutch.publisher = TestHutch::Publishers::FakePublisher.new
  end

  def connect
    # NOOP
  end
end
