require 'text_mapper/callback'
require 'text_mapper/pattern'

module TextMapper
  class Listener
    include Callback

    attr_reader :from

    def initialize(signature, &blk)
      @from = Pattern.new(signature)
      @blk = blk
    end

    def call(context, test_case)
      context.instance_exec(test_case, &@blk)
    end
  end
end
