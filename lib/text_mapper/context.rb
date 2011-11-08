module TextMapper
  class Context
    attr_accessor :namespace

    def mixins=(mixins)
      mixins.each { |mixin| extend(mixin) }
    end

    def dispatch(pattern)
      mapping = namespace.find_matching(pattern)
      mapping.call(self, pattern)
    end
  end
end
