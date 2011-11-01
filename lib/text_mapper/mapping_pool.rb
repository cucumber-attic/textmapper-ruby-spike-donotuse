module TextMapper
  class UndefinedMappingError < NameError
    def initialize(missing)
      @missing = missing
    end

    def to_s
      "No mapping found that matches: #{@missing}"
    end
  end

  class MappingPool
    include Enumerable

    attr_reader :mappings

    def initialize(*mappings)
      @mappings = mappings
    end

    def find_one(pattern, metadata={})
      mappings.find do |mapping|
        mapping.match(pattern, metadata)
      end
    end

    def find_one!(pattern, metadata={})
      find_one(pattern, metadata) or (raise UndefinedMappingError, pattern)
    end

    def find_all(pattern, metadata={})
      mappings.select do |mapping|
        mapping.match(pattern, metadata)
      end
    end

    def find_all!(pattern, metadata={})
      all = find_all(pattern, metadata)
      raise UndefinedMappingError, pattern if all.empty?
      all
    end

    def add(mapping)
      mappings << mapping
    end

    def empty?
      mappings.empty?
    end

    def each(&block)
      mappings.each(&block)
    end
  end
end
