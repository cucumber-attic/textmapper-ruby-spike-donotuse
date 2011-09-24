require 'cucumber/text_mapper/listener'
require 'cucumber/text_mapper/mapping_pool'
require 'cucumber/text_mapper/dsl'

module Cucumber
  module TextMapper
    class Namespace
      attr_reader :mappings, :mappers, :constant_aliases

      def initialize(constant_aliases = {})
        @mappings = MappingPool.new
        @mappers = []
        @constant_aliases = constant_aliases
      end

      def add_mapper(mapper)
        mappers << mapper
      end

      def add_mapping(mapping)
        mappings.add(mapping)
      end

      def find_mapping(from)
        mappings.find!(from)
      end

      def listeners
        mappings.select { |mapping| Listener === mapping }
      end

      def build_context(context)
        context.mappings = self
        context.mappers = mappers
        context
      end

      def to_extension_module
        Dsl.new(self, constant_aliases).to_module
      end
    end
  end
end

