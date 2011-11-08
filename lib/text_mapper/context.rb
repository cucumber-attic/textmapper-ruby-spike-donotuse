module TextMapper
  class Context
    attr_accessor :namespace

    def mixins=(mappers)
      mappers.each { |mapper| extend(mapper) }
    end

    def dispatch(pattern)
      mapping = namespace.find_matching(pattern)
      mapping.call(self, pattern)
    end
  end
end
