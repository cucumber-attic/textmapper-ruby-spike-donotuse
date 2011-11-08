require 'spec_helper'

module TextMapper
  describe Namespace do
    def mapping(from, to)
      MethodMapping.from_primitives([from], [to])
    end

    describe "#to_extension_module" do
      it "returns a module" do
        subject.to_extension_module.should be_an_instance_of(Module)
      end
    end

    describe "#build_context" do
      let(:context) { double("context", :namespace= => true, :mixins= => true) }

      it "sets the namespace" do
        context.should_receive(:namespace=).with(subject)
        subject.build_context(context)
      end

      it "sets the mixins" do
        context.should_receive(:mixins=).with(subject.mixins)
        subject.build_context(context)
      end
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
