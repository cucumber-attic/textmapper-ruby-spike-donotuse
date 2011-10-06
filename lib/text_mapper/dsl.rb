require 'text_mapper/mapping'

module TextMapper
  class MappingBuilder
    attr_reader :pattern, :target

    def initialize(args)
      @pattern = Pattern.new(args)
    end

    def to(*args)
      @target = Target.new(*args)
    end

    def match(raw_pattern)
      pattern === raw_pattern
    end

    def reify!
      @mapping ||= Mapping.new(pattern, target)
    end
  end

  class Dsl
    def initialize(mappings, const_aliases={})
      @mappings = mappings
      @const_aliases = const_aliases
    end

    def to_module
      lambda do |mappings, const_aliases|
        Module.new do
          metaclass = (class << self; self; end)

          metaclass.send(:define_method, :extended) do |mapper|
            const_aliases.each_pair do |const, const_alias|
              mapper.const_set(const_alias, const)
            end

            mappings.add_mapper(mapper)
          end

          define_method(:map) do |*from|
            mapping = MappingBuilder.new(from.unshift(:map))
            mappings.add_mapping(mapping)
            mapping
          end

          define_method(:on) do |*event, &callback|
            mappings.add_mapping(Listener.new(event, &callback))
          end
        end
      end.call(@mappings, @const_aliases)
    end
  end
end
