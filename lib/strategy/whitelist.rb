module DataAnon
  module Strategy
    class Whitelist < DataAnon::Strategy::Base

      def self.whitelist?
        true
      end

      def process_record(index, record)
        dirty = false
        
        record.attributes.each do |field_name, field_value|
          unless field_value.nil? || is_primary_key?(field_name)
            field = DataAnon::Core::Field.new(field_name, field_value, index, record, @name)
            field_strategy = @fields[field_name] || default_strategy(field_name)
            record[field_name] = field_strategy.anonymize(field)
            dirty = true
          end
        end

        record.save! if dirty
      end

    end
  end
end
