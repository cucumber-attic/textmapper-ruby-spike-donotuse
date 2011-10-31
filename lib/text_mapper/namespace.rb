require 'text_mapper/block_mapping'
require 'text_mapper/mapping_pool'
require 'text_mapper/dsl'

module TextMapper
  class Namespace
    attr_reader :mappings, :mappers, :constant_aliases

    def initialize(constant_aliases = {})
      @mappings = MappingPool.new
      @mappers = []
      @constant_aliases = constant_aliases
    end

    def add_mixin(mapper)
      mappers << mapper
    end

    def add_mapping(mapping)
      mappings.add(mapping)
    end

    def find_mapping(from, metadata={})
      mapping = mappings.find!(from, metadata)
      mapping.reify!
    end

    def listeners
      mappings.select { |mapping| BlockMapping === mapping }
    end

    def initialize_context(context)
      context.mappings = self
      context.mappers = mappers
      context
    end

    def define_dsl_method(name, &body)
      dsl.define_method(name, &body)
    end

    def dsl
      @dsl ||= Dsl.new(self, constant_aliases)
    end

    def to_extension_module
      dsl.to_module
    end
  end
end
