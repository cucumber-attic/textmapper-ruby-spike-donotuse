require 'text_mapper/callback'
require 'text_mapper/pattern'
require 'text_mapper/target'

module TextMapper
  class Mapping
    include Callback

    def self.from_fluent(dsl_args)
      warn "This method will be removed without warning"
      from, to = dsl_args.shift
      pattern = [:map, from].flatten
      meth_name, *types = to
      new(Pattern.new(pattern), Target.new(meth_name, types))
    end

    def self.from_primitives(from, to)
      meth_name, *types = to
      new(Pattern.new(from), Target.new(meth_name, types))
    end

    attr_reader :from, :to

    def initialize(from, to, types=[])
      @from, @to, @types = from, to, types
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
