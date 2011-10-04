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

      class TestContext
        attr_reader :mappings

        def mappings=(mappings)
          @mappings = mappings
        end

        def mappers=(mappers)
          mappers.each { |mapper| extend(mapper) }
        end

        def dispatch(pattern)
          mapping = mappings.find_mapping(pattern)
          mapping.call(self, pattern)
        end
      end

      def build_mapper(name, namespace)
        from = :"from_#{name}"
        to   = :"to_#{name}"

        Module.new do
          extend namespace
          def_map from => to
          define_method(to) { to }
        end
      end

      it "builds an execution context" do
        # Move dispatch assertion to Context spec, use a mock to ensure the Context Factory's new method
        # is called with the correct arguments
        build_mapper(:mapper_a, subject.to_extension_module)
        context = subject.build_context(TestContext.new)
        context.dispatch([:map, :from_mapper_a]).should eq(:to_mapper_a)
      end
    end
  end
end