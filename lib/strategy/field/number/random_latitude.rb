module DataAnon
  module Strategy
    module Field

      # Generates random float number between given -90 to 90
      #
      #    !!!ruby
      #    anonymize('latitude').using FieldStrategy::RandomLatitude

      class RandomLatitude < Safe
        def anonymize(_field)
          DataAnon::Utils::RandomFloat.generate(-90, 90)
        end
      end
    end
  end
end
