require 'spec_helper'

module TextMapper
  describe Dsl do
    let(:namespace) { Namespace.new }

    let(:context) do
      context = Context.new
      namespace.build_context(context)
      context
    end

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

    describe ".map" do
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

      it "maps from a multi-part pattern to a method" do
        within(namespace) do
          map(:from, :here).to(:to)

          def to
            @to = :to
          end
        end

        context.dispatch([:from, :here])
        context.instance_variable_get(:@to).should eq(:to)
      end

      it "captures arguments" do
        within(namespace) do
          map(:from, Object).to(:to_obj)

          def to_obj(obj)
            @to = obj
          end
        end

        context.dispatch([:from, "a string"])
        context.instance_variable_get(:@to).should eq("a string")
        context.dispatch([:from, { :a => :hash }])
        context.instance_variable_get(:@to).should eq({ :a => :hash })
      end

      it "maps based on the type of the dispatch argument" do
        within(namespace) do
          map(:from, String).to(:to_string)
          map(:from, Array).to(:to_array)

          def to_string(str)
            @to = str
          end

          def to_array(ary)
            @to = ary
          end
        end

        context.dispatch([:from, "a string"])
        context.instance_variable_get(:@to).should eq("a string")
        context.dispatch([:from, [:an, :array]])
        context.instance_variable_get(:@to).should eq([:an, :array])
      end
    end

    describe ".on" do
      it "registers an event listener that executes within the context" do
        within(namespace) do
          on(:setup) do
            @foo = :foo
          end
        end

        context.dispatch([:setup])
        context.instance_variable_get(:@foo).should eq(:foo)
      end
    end
  end
end
