module TextMapper
  module Listener
    def match(raw_pattern, metadata={})
      from === raw_pattern
    end

    def build
      self
    end

    def id
      object_id
    end
  end
end
