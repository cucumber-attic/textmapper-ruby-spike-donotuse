require 'spec_helper'

module TextMapper
  describe Dsl do
    let(:namespace) { Namespace.new }

    let(:context) do
      context = Context.new
      namespace.initialize_context(context)
      context
    end

    def within(namespace_or_dsl, &script)
      if Dsl === namespace_or_dsl
        ext_mod = namespace_or_dsl.to_module
      else
        ext_mod = Dsl.new(namespace_or_dsl).to_module
      end
      
      Module.new do
        extend ext_mod
        module_eval(&script)
      end
    end

    it "aliases constants so referencing them is easier" do
      dsl = Dsl.new(namespace, { String => :NewString, Array => :NewArray })
      constants = Module.new { extend dsl.to_module }.constants
      constants.should eq([:NewString, :NewArray])
    end

    it "adds new methods to the dsl" do
      foo = nil
      dsl = Dsl.new(namespace)
      dsl.define_method(:foo) do |arg|
        foo = arg
      end
      
      within(dsl) do
        foo(:bar)
      end

      foo.should eq(:bar)
    end

    describe ".map" do
      it "maps from a simple pattern to a method" do
        within(namespace) do
          map(:from).to(:to)

          def to
            @to = :to
          end
        end

        context.dispatch([:map, :from])
        context.instance_variable_get(:@to).should eq(:to)
      end

      it "maps from a multi-part pattern to a method" do
        within(namespace) do
          map(:from, :here).to(:to)

          def to
            @to = :to
          end
        end

        context.dispatch([:map, :from, :here])
        context.instance_variable_get(:@to).should eq(:to)
      end

      it "captures arguments" do
        within(namespace) do
          map(:from, Object).to(:to_obj)

          def to_obj(obj)
            @to = obj
          end
        end

        context.dispatch([:map, :from, "a string"])
        context.instance_variable_get(:@to).should eq("a string")
        context.dispatch([:map, :from, { :a => :hash }])
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

        context.dispatch([:map, :from, "a string"])
        context.instance_variable_get(:@to).should eq("a string")
        context.dispatch([:map, :from, [:an, :array]])
        context.instance_variable_get(:@to).should eq([:an, :array])
      end

      it "converts target arguments to the specified types" do
        within(namespace) do
          map(:from, String).to(:to, Integer)

          def to(int)
            @to = int
          end
        end

        context.dispatch([:map, :from, "1"])
        context.instance_variable_get(:@to).should eq(1)
      end

      it "annotates the next defined method if no target is given" do
        within(namespace) do
          map(:from, String)
          def to(str)
            @to = str
          end
        end

        context.dispatch([:map, :from, "hello"])
        context.instance_variable_get(:@to).should eq("hello")
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
