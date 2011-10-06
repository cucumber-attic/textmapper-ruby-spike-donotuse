module TextMapper
  module Callback
    def match(raw_pattern)
      from === raw_pattern
    end

    def reify!
      self
    end
  end
end
