module DataAnon
  module Strategy
    module Field

      # Generates random float number between given -180 to 180
      #
      #    !!!ruby
      #    anonymize('longitude').using FieldStrategy::RandomLongitude

      class RandomLongitude
        def anonymize(_field)
          DataAnon::Utils::RandomFloat.generate(-180, 180)
        end
      end
    end
  end
end
