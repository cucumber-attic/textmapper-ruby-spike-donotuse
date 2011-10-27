require 'spec_helper'

module TextMapper
  describe Namespace do
    describe "#listeners" do
      it "filters listeners from mappings and returns them" do
        listener = Listener.new([:from]){}
        subject.add_mapping(Mapping.new([:from], :to))
        subject.add_mapping(listener)
        subject.listeners.should eq([listener])
      end
    end

    describe "#to_extension_module" do
      it "returns a module" do
        Namespace.new.to_extension_module.should be_an_instance_of(Module)
      end
    end

    describe "#build_context" do
      subject { Namespace.new }

      def build_mapper(name, namespace)
        from = :"from_#{name}"
        to   = :"to_#{name}"

        Module.new do
          extend namespace
          map(from).to(to)
          define_method(to) { to }
        end
      end

      it "builds an execution context" do
        # Move dispatch assertion to Context spec, use a mock to ensure the Context Factory's new method
        # is called with the correct arguments
        build_mapper(:mapper_a, subject.to_extension_module)
        context = subject.initialize_context(Context.new)
        context.dispatch([:map, :from_mapper_a]).should eq(:to_mapper_a)
      end
    end

    describe "#find_mapping" do
      def mapping(from, to)
        Mapping.from_primitives([from], [to])
      end

      it "returns the mapping matching the pattern" do
        namespace = Namespace.new
        foo_mapping = mapping(:foo, :bar)
        baz_mapping = mapping(:baz, :qux)
        namespace.add_mapping(foo_mapping)
        namespace.add_mapping(baz_mapping)
        namespace.find_mapping([:foo]).should eq(foo_mapping)
      end

      it "passes the metadata to the mapping collection" do
        namespace = Namespace.new
        namespace.mappings.should_receive(:find!)
                          .with([:foo], { :bar => :baz })
                          .and_return(double("dummy").as_null_object)
        namespace.find_mapping([:foo], { :bar => :baz })
      end
    end
  end
end
