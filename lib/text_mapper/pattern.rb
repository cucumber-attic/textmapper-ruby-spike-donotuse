module TextMapper
  class Pattern
    attr_reader :parts

    def initialize(parts)
      ensure_array_like(parts)
      @parts = parts.to_a
    end

    def match(targets)
      return false unless array_like?(targets)
      result, bindings = compare(parts, targets.to_a)
      return bindings if result
    end

    def ===(targets)
      !!match(targets)
    end

    def to_s
      "#{self.class}: '#{parts}'"
    end

    private

    def compare(parts, targets, last_result=nil, captures=[])
      return [last_result, captures] if parts.length != targets.length
      # the presence of nil in parts or targets short-circuits the evaluation because
      # the value of an assignment in an expression context is the result of the assignment,
      # which when nil evaluates to false and [last_result, captures] is returned. There's
      # a spec showing we're aware of this behavior. Not sure what to do about it yet. It's
      # not high-priority.
      return [last_result, captures] unless part = parts[0] and target = targets[0]

      if current_result = (part === target)
        case part
        when Class
          captures.push(target)
        when Regexp
          captures.push(*part.match(target).captures)
        end
        compare(parts[1..-1], targets[1..-1], current_result, captures)
      end
    end

    def array_like?(obj)
      obj.respond_to?(:to_a)
    end

    def ensure_array_like(obj)
      unless array_like?(obj)
        raise TypeError, "can't convert #{obj.class} into Array"
      end
    end
  end
end
