require 'spec_helper'

module TextMapper
  describe MethodMapping do
    def pattern(*args)
      Pattern.new(args)
    end

    def target(*args)
      Target.new(*args)
    end

    subject { MethodMapping.from_primitives([:from], [:to]) }
    it_behaves_like "a mapping"

    describe ".from_primitives" do
      it "builds a mapping from primitive data types" do
        receiver = double("dispatch receiver")
        receiver.should_receive(:to)
        mapping = MethodMapping.from_primitives([:from], [:to])
        mapping.should match([:from])
        mapping.call(receiver)
      end
    end

    describe "#call" do
      let(:receiver) { double("dispatch receiver") }

      it "invokes the correct method name" do
        receiver.should_receive(:to)
        mapping = MethodMapping.new(pattern(:from), target(:to))
        mapping.call(receiver)
      end

      it "invokes a method with arguments" do
        receiver.should_receive(:hair).with("red")
        mapping = MethodMapping.new(pattern(/(.+) hair/), target(:hair))
        mapping.call(receiver, ["red hair"])
      end

      it "converts captured arguments into the specified type" do
        receiver.should_receive(:add).with(1, 2.0)
        mapping = MethodMapping.new(pattern(/(\d+) and (\d+)/), target(:add, [Integer, Float]))
        mapping.call(receiver, ["1 and 2.0"])
      end

      it "raises NoMethodError when 'to' does not exist on the receiver" do
        receiver.should_receive(:to).and_raise(NoMethodError)
        mapping = MethodMapping.new(pattern(:from), target(:to))
        expect { mapping.call(receiver) }.to raise_error(NoMethodError)
      end

      it "raises an error when the action does not contain enough information to satisfy the 'from'"
    end

    describe "#build" do
      it "returns self" do
        mapping = MethodMapping.new(pattern(:from), target(:to))
        mapping.build.should eq(mapping)
      end
    end

    describe "#source_location" do
      it "says where the mapping was defined"
    end
  end
end
