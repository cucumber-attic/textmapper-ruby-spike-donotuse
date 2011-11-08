require 'text_mapper/block_mapping'
require 'text_mapper/mapping_pool'
require 'text_mapper/dsl'

module TextMapper
  class Namespace
    attr_reader :mappings, :mixins, :constant_aliases

    def initialize(constant_aliases = {})
      @mappings = MappingPool.new
      @mixins = []
      @constant_aliases = constant_aliases
    end

    def add_mixin(mixin)
      mixins << mixin
    end

    def add_mapping(mapping)
      mappings.add(mapping)
    end

    def find_matching(from, metadata={})
      mapping = mappings.find_one!(from, metadata)
      mapping.build
    end

    def find_all_matching(from, metadata={})
      mappings.find_all!(from, metadata).map do |mapping|
        mapping.build
      end
    end

    def build_context(context)
      context.namespace = self
      context.mixins = mixins
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
