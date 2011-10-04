module TextMapper
  class Target
    attr_reader :name, :types, :receiver

    def initialize(name, types=[], receiver=nil)
      @name, @types, @receiver = name, types, receiver
    end

    # TODO: Retrieving the receiver with an explicit
    # protocol supported by the context is probably
    # more polite.
    def call(ctx, args=[])
      converted_args = convert_arguments(args)

      if receiver
        final_ctx = ctx.send(receiver)
        final_ctx.send(name, *converted_args)
      else
        ctx.send(name, *converted_args)
      end
    end

    def convert_arguments(args)
      return args if types.empty?

      args.zip(types).collect do |arg, type|
        # FIXME: Add other built-ins with idiosyncratic build protocols
        if Integer == type
          arg.to_i
        elsif Float == type
          arg.to_f
        else
          type.new(arg)
        end
      end
    end
  end
end
