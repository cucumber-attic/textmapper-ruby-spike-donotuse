require 'spec_helper'

module TextMapper
  describe MappingPool do
    let(:mapping) { Mapping.new([:foo], :bar) }

    context "without mappings" do
      subject { MappingPool.new }

      describe "#find_one" do
        it "returns nil" do
          subject.find_one([:foo]).should eq(nil)
        end
      end

      describe "#find_one!" do
        it "raises UndefinedMappingError because there are no mappings" do
          expect {
            subject.find_one!([:foo])
          }.to raise_error(UndefinedMappingError)
        end
      end

      describe "#find_all" do
        it "returns an empty array" do
          subject.find_all([:foo]).should eq([])
        end
      end

      describe "#find_all!" do
        it "raises UndefinedMappingError because there are no mappings" do
          expect do
            subject.find_all!([:foo])
          end.to raise_error(UndefinedMappingError)
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

      describe "#find_one" do
        it "returns the matching mapping" do
          subject.find_one([:foo]).should eq(mapping)
        end

        it "returns nil if no mapping matches" do
          subject.find_one([:bar]).should eq(nil)
        end

        it "passes the metadata to the mapping" do
          mapping.should_receive(:match)
                 .with([:foo], { :bar => :baz })
          subject.find_one([:foo], { :bar => :baz })
        end
      end

      describe "#find_all" do
        it "returns all matching mappings" do
          subject.find_all([:foo]).should eq([mapping])
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
