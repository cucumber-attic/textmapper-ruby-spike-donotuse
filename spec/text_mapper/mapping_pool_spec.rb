require 'spec_helper'

module TextMapper
  describe MappingPool do
    let(:mapping) { Mapping.new([:foo], :bar) }

    context "without mappings" do
      subject { MappingPool.new }

      describe "#find" do
        it "returns nil" do
          subject.find([:foo]).should eq(nil)
        end
      end

      describe "#find!" do
        it "raises UndefinedMappingError" do
          expect {
            subject.find!([:foo])
          }.to raise_error(UndefinedMappingError)
        end
      end

      describe "#add" do
        it "adds the mapping to the pool" do
          subject.add(mapping)
          subject.mappings.should eq([mapping])
        end
      end

      describe "#empty?" do
        it "says that the pool is empty" do
          subject.should be_empty
        end
      end
    end

    context "with mappings" do
      subject { MappingPool.new(mapping) }

      describe "#find" do
        it "returns the matching mapping" do
          subject.find([:foo]).should eq(mapping)
        end

        it "returns nil if no mapping matches" do
          subject.find([:bar]).should eq(nil)
        end

        it "passes the metadata to the mapping" do
          mapping.should_receive(:match)
                 .with([:foo], { :bar => :baz })
          subject.find([:foo], { :bar => :baz })
        end
      end

      describe "#empty?" do
        it "says that the pool is not empty" do
          subject.should_not be_empty
        end
      end
    end
  end
end
