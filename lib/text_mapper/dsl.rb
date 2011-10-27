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
    def initialize(namespace, const_aliases={})
      @namespace     = namespace
      @const_aliases = const_aliases
      @dsl_methods   = {}

      define_default_dsl_methods(@namespace)
    end

    def define_method(name, &body)
      @dsl_methods[name] = body
    end

    def to_module
      lambda do |namespace, const_aliases, dsl_methods|
        Module.new do
          metaclass = (class << self; self; end)

          metaclass.send(:define_method, :extended) do |mapper|
            const_aliases.each_pair do |const, const_alias|
              mapper.const_set(const_alias, const)
            end

            namespace.add_mixin(mapper)
          end

          def method_added(meth_name)
            MappingBuilder.ensure_target(meth_name)
          end

          dsl_methods.each do |name, body|
            define_method(name, &body)
          end
        end
      end.call(@namespace, @const_aliases, @dsl_methods)
    end

    private

    def define_default_dsl_methods(namespace)
      define_map_method(namespace)
      define_on_method(namespace)
    end

    def define_map_method(namespace)
      define_method(:map) do |*from|
        mapping = MappingBuilder.new(from.unshift(:map))
        namespace.add_mapping(mapping)
        mapping
      end
    end

    def define_on_method(namespace)
      define_method(:on) do |*event, &callback|
        namespace.add_mapping(Listener.new(event, &callback))
      end
    end
  end
end
