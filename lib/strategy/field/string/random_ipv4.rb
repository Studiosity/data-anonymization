module DataAnon
  module Strategy
    module Field

      # Return a random IPv4 address (as a string)
      #
      #    !!!ruby
      #    anonymize('ip_address').using FieldStrategy::RandomIPv4.new

      class RandomIPv4 < Safe
        def anonymize(_field)
          (0..3).map { SecureRandom.random_number(255) }.join '.'
        end
      end
    end
  end
end
