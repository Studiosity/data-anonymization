module DataAnon
  module Strategy
    module Field


      class Anonymous

        def initialize opts, &block
          @opts = opts
          @block = block
        end

        def anonymize field
          @block.call field
        end

        def unsafe?
          @opts.is_a?(Hash) && !!@opts[:unsafe]
        end

      end


    end
  end
end