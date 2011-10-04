module TextMapper
  class Target
    attr_reader :name, :receiver

    def initialize(name, receiver=nil)
      @name, @receiver = name, receiver
    end

    # TODO: Retrieving the receiver with an explicit
    # protocol supported by the context is probably
    # more polite.
    def call(ctx, args=[])
      if receiver
        final_ctx = ctx.send(receiver)
        final_ctx.send(name, *args)
      else
        ctx.send(name, *args)
      end
    end
  end
end
