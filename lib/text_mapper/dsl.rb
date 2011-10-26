require 'text_mapper/mapping'

module TextMapper
  class MappingBuilder
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
      @user_methods = {}
    end

    def define_method(name, &body)
      @user_methods[name] = body
    end
    
    def to_module
      lambda do |mappings, const_aliases, user_methods|
        Module.new do
          metaclass = (class << self; self; end)

          metaclass.send(:define_method, :extended) do |mapper|
            const_aliases.each_pair do |const, const_alias|
              mapper.const_set(const_alias, const)
            end

            mappings.add_mixin(mapper)
          end

          def method_added(meth_name)
            MappingBuilder.ensure_target(meth_name)
          end

          define_method(:map) do |*from|
            mapping = MappingBuilder.new(from.unshift(:map))
            mappings.add_mapping(mapping)
            mapping
          end

          define_method(:on) do |*event, &callback|
            mappings.add_mapping(Listener.new(event, &callback))
          end

          user_methods.each do |name, body|
            define_method(name, &body)
          end
        end
      end.call(@mappings, @const_aliases, @user_methods)
    end
  end
end
