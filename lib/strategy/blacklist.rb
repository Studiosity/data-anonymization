module DataAnon
  module Strategy
    class Blacklist < DataAnon::Strategy::Base

      def process_record index, record
        updates = {}

        @fields.each do |field, strategy|
          database_field_name = record.attributes.select { |k,v| k == field }.keys[0]
          field_value = record.attributes[database_field_name]
          unless field_value.nil? || is_primary_key?(database_field_name)
            field = DataAnon::Core::Field.new(database_field_name, field_value, index, record, @name)
            updates[database_field_name] = strategy.anonymize(field)
          end
        end

        record.update_columns(updates) if updates.any?
      end

    end
  end
end
