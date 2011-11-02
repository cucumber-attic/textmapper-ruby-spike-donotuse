require 'spec_helper'

shared_examples "a listener" do
  it "has an id" do
    subject.should respond_to(:id)
  end
end
