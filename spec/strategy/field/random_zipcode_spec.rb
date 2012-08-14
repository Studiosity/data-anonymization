require "spec_helper"

describe DataAnon::Strategy::Field::RandomZipcode do

  RandomZipcode = DataAnon::Strategy::Field::RandomZipcode
  let(:field) {DataAnon::Core::Field.new('zipcode','12345',1,nil)}

  describe 'anonymized zipcode should be different from original zipcode' do
    let(:anonymized_zipcode) {RandomZipcode.new.anonymize(field)}
    it {anonymized_zipcode.should_not eq("12345")}
  end
end