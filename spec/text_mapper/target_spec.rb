require 'spec_helper'

module TextMapper
  describe Target do
    it "sends a message to the context" do
      ctx = double("execution context")
      ctx.should_receive(:foo)
      to = Target.new(:foo)
      to.call(ctx)
    end

    it "sends a message with one argument to the context" do
      ctx = double("execution context")
      ctx.should_receive(:foo).with(:bar)
      to = Target.new(:foo)
      to.call(ctx, [:bar])
    end

    it "sends a message with two arguments to the context" do
      ctx = double("execution context")
      ctx.should_receive(:foo).with(:bar, :baz)
      to = Target.new(:foo)
      to.call(ctx, [:bar, :baz])
    end

    it "sends a message to a receiver in the context" do
      target = double("target attribute")
      target.should_receive(:foo)
      ctx = double("execution context")
      ctx.stub(:target).and_return(target)
      to = Target.new(:foo, [], :target)
      to.call(ctx)
    end

    it "converts arguments to the specified types" do
      ctx = double("execution context")
      ctx.should_receive(:foo).with(1)
      to = Target.new(:foo, [Integer])
      to.call(ctx, ["1"])
    end
  end
end
