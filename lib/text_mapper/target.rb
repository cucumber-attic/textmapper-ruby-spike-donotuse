module TextMapper
  class Target
    attr_reader :target

    def initialize(target)
      @target = target
    end

    def call(ctx, args=[])
      final_ctx, final_target = find_target(ctx, target)
      final_ctx.send(final_target, *args)
    end

    private

    def find_target(ctx, messages)
      if messages.length == 1
        [ctx, messages.first]
      else
        find_target(ctx.send(messages.first), messages[1..-1])
      end
    end
  end
end
