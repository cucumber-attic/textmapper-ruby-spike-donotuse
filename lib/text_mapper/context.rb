module TextMapper
  class Context
    attr_reader :mappings

    def mappings=(mappings)
      @mappings = mappings
    end

    def mappers=(mappers)
      mappers.each { |mapper| extend(mapper) }
    end

    def dispatch(pattern)
      mapping = mappings.find_mapping(pattern)
      mapping.call(self, pattern)
    end
  end
end
