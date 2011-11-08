require 'spec_helper'

module TextMapper
  describe Namespace do
    def mapping(from, to)
      MethodMapping.from_primitives([from], [to])
    end

    describe "#listeners" do
      it "filters listeners from mappings and returns them" do
        listener = BlockMapping.new([:from]){}
        subject.add_mapping(mapping(:from, :to))
        subject.add_mapping(listener)
        subject.listeners.should eq([listener])
      end
    end

    describe "#to_extension_module" do
      it "returns a module" do
        subject.to_extension_module.should be_an_instance_of(Module)
      end
    end

    describe "#build_context" do
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
        context = subject.build_context(Context.new)
        context.dispatch([:dispatch, :from_mapper_a]).should eq(:to_mapper_a)
      end

      it "sets the namespace"
      it "sets the mixins"
    end

    describe "#find_matching" do
      it "returns the mapping matching the pattern" do
        foo_mapping = mapping(:foo, :bar)
        baz_mapping = mapping(:baz, :qux)
        subject.add_mapping(foo_mapping)
        subject.add_mapping(baz_mapping)
        subject.find_matching([:foo]).should eq(foo_mapping)
      end

      it "raises if nothing is found" do
        expect do
          subject.find_matching([:whatever])
        end.to raise_error(UndefinedMappingError)
      end

      it "passes the metadata to the mapping collection" do
        subject.mappings.should_receive(:find_one!)
                          .with([:foo], { :bar => :baz })
                          .and_return(double("dummy").as_null_object)
        subject.find_matching([:foo], { :bar => :baz })
      end
    end

    describe "#find_all_matching" do
      it "returns all the mappings matching the pattern" do
        foo1_mapping = mapping(:foo, :bar)
        foo2_mapping = mapping(:foo, :qux)
        subject.add_mapping(foo1_mapping)
        subject.add_mapping(foo2_mapping)
        subject.find_all_matching([:foo]).should eq([foo1_mapping, foo2_mapping])
      end

      it "raises if nothing is found" do
        expect do
          subject.find_all_matching([:whatever])
        end.to raise_error(UndefinedMappingError)
      end
    end
  end
end
