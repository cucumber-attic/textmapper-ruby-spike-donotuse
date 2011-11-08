require 'spec_helper'

module TextMapper
  describe Context do
    # These tests are more complex than they need to be, but they're
    # what we've got for now.

    def build_mapper(name, namespace)
      from = :"from_#{name}"
      to   = :"to_#{name}"

      Module.new do
        extend namespace
        map(from).to(to)
        define_method(to) { to }
      end
    end

    let(:namespace) { Namespace.new }

    describe "#dispatch" do
      it "calls the correct method" do
        build_mapper(:mapper_a, namespace.to_extension_module)
        namespace.build_context(subject)
        subject.dispatch([:dispatch, :from_mapper_a]).should eq(:to_mapper_a)
      end
    end
  end
end
