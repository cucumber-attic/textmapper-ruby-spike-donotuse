require 'text_mapper/mapping'
require 'text_mapper/pattern'
require 'text_mapper/target'

module TextMapper
  class MethodMapping
    include Mapping

    def self.from_primitives(from, to)
      meth_name, *types = to
      new(Pattern.new(from), Target.new(meth_name, types))
    end

    attr_reader :from, :to

    def initialize(from, to)
      @from, @to = from, to
    end

    def captures_from(raw_pattern)
      from.match(raw_pattern) or []
    end

    def call(receiver, action=[])
      args = captures_from(action)
      to.call(receiver, args)
    end

    class Builder
      class << self
        attr_accessor :last_mapping

        def ensure_target(meth_name)
          unless last_mapping.target
            last_mapping.to(meth_name)
          end
        end
      end

      attr_reader :pattern, :target

      def initialize(args)
        self.class.last_mapping = self
        @pattern = Pattern.new(args)
      end

      def to(meth_name, *types)
        @target = Target.new(meth_name, types)
      end

      def match(raw_pattern, metadata={})
        pattern === raw_pattern
      end

      def build
        @mapping ||= MethodMapping.new(pattern, target)
      end
    end
  end
end
