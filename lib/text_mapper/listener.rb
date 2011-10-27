module TextMapper
  module Listener
    def match(raw_pattern, metadata={})
      from === raw_pattern
    end

    def reify!
      self
    end
  end
end
