module DataAnon
  module Strategy
    module Field

      class Safe
        def unsafe?
          false
        end
      end

    end
  end
end
