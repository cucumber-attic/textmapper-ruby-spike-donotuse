require 'text_mapper/pattern'
require 'text_mapper/target'

module TextMapper
  class Mapping
    def self.from_fluent(dsl_args)
      from, to = dsl_args.shift
      pattern = [:map, from].flatten
      meth_name, *types = to
      new(Pattern.new(pattern), Target.new(meth_name, types))
    end

    attr_reader :from, :to

    def initialize(from, to, types=[])
      @from, @to, @types = from, to, types
    end

    def match(raw_pattern)
      from === raw_pattern
    end

    def captures_from(raw_pattern)
      from.match(raw_pattern) or []
    end

    def call(receiver, action=[])
      args = captures_from(action)
      to.call(receiver, args)
    end
  end
end
