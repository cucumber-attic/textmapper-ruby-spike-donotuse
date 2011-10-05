require 'spec_helper'

module TextMapper
  describe Dsl do
    let(:namespace) { Namespace.new }

    def within(namespace, &script)
      Module.new do
        extend Dsl.new(namespace).to_module
        module_eval(&script)
      end
    end

    it "aliases constants so referencing them is easier" do
      dsl = Dsl.new(namespace, { String => :NewString, Array => :NewArray })
      constants = Module.new { extend dsl.to_module }.constants
      constants.should eq([:NewString, :NewArray])
    end

    describe ".def_map" do
      it "creates a mapping in the namespace" do
        namespace.should_receive(:add_mapping).with(an_instance_of(Mapping))
        within(namespace) do
          def_map :from => :to
        end
      end
    end

    it "maps from a simple pattern to a method" do
      within(namespace) do
        map(:from).to(:to)

        def to
          @to = :to
        end
      end

      context.dispatch([:from])
      context.instance_variable_get(:@to).should eq(:to)
    end
  end
end
