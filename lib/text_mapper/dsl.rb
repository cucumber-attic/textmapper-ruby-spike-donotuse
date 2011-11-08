require 'text_mapper/method_mapping'
require 'text_mapper/block_mapping'

module TextMapper
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

          metaclass.send(:define_method, :extended) do |mixin|
            const_aliases.each_pair do |const, const_alias|
              mixin.const_set(const_alias, const)
            end

            namespace.add_mixin(mixin)
          end

          def method_added(meth_name)
            MethodMapping::Builder.ensure_target(meth_name)
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
        mapping = MethodMapping::Builder.new(from.unshift(:dispatch))
        namespace.add_mapping(mapping)
        mapping
      end
    end

    def define_on_method(namespace)
      define_method(:on) do |*event, &callback|
        namespace.add_mapping(BlockMapping.new(event, &callback))
      end
    end
  end
end
