require 'text_mapper/listener'
require 'text_mapper/pattern'

module TextMapper
  class BlockMapping
    include Listener

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
