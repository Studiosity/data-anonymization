# Data::Anonymization
Tool to create anonymized production data dump to use for PERF and other TEST environments.

[<img src="https://secure.travis-ci.org/sunitparekh/data-anonymization.png?branch=master">](http://travis-ci.org/sunitparekh/data-anonymization)
[<img src="https://gemnasium.com/sunitparekh/data-anonymization.png?travis">](https://gemnasium.com/sunitparekh/data-anonymization)
[<img src="https://codeclimate.com/badge.png">](https://codeclimate.com/github/sunitparekh/data-anonymization)

## Getting started

Install gem using:

    $ gem install data-anonymization

Install required database adapter library for active record:

    $ gem install sqlite3

Create ruby program using data-anonymization DSL as following `my_dsl.rb`:

```ruby
require 'data-anonymization'

database 'DatabaseName' do
  strategy DataAnon::Strategy::Blacklist  # whitelist (default) or blacklist

  # database config as active record connection hash
  source_db :adapter => 'sqlite3', :database => 'sample-data/chinook-empty.sqlite'

  # User -> table name (case sensitive)
  table 'User' do
    # id, DateOfBirth, FirstName, LastName, UserName, Password -> table column names (case sensitive)
    primary_key 'id' # composite key is also supported
    anonymize 'DateOfBirth','FirstName','LastName' # uses default anonymization based on data types
    anonymize('UserName').using FieldStrategy::StringTemplate.new('user#{row_number}')
    anonymize('Password') { |field| "password" }
  end

  ...

end
```

Run using:

    $ ruby my_dsl.rb

Liked it? please share

[<img src="https://si0.twimg.com/a/1346446870/images/resources/twitter-bird-light-bgs.png" height="35" width="35">](https://twitter.com/share?text=A+simple+ruby+DSL+based+data+anonymization&url=http:%2F%2Fsunitparekh.github.com%2Fdata-anonymization&via=dataanon&hashtags=dataanon)

## Examples

1. [Whitelist using Chinoook sample database](https://github.com/sunitparekh/data-anonymization/blob/master/whitelist_dsl.rb)
2. [Blacklist using Chinoook sample database](https://github.com/sunitparekh/data-anonymization/blob/master/blacklist_dsl.rb)
3. [Whitelist with composite primary key using DellStore sample database](https://github.com/sunitparekh/test-anonymization/blob/master/dell_whitelist.rb)
4. [Blacklist with composite primary key using DellStore sample database](https://github.com/sunitparekh/test-anonymization/blob/master/dell_blacklist.rb)

## Changelog

#### 0.3.0 (Sep 4, 2012)

Major changes:

1. Added support for Parallel table execution
2. Change in default String strategy from LoremIpsum to RandomString based on end user feedback.
3. Fixed issue with table column name 'type' as this is default name for STI in activerecord.

Please see the [Github 0.3.0 milestone page](https://github.com/sunitparekh/data-anonymization/issues?milestone=1&state=closed) for more details on changes/fixes in release 0.3.0

#### 0.2.0 (August 16, 2012)

1. Added the progress bar using 'powerbar' gem. Which also shows the ETA for each table.
2. Added More strategies
3. Fixed default anonymization strategies for boolean and integer values
4. Added support for composite primary key

#### 0.1.2 (August 14, 2012)

1. First initial release

## Roadmap

#### 0.4.0

1. MongoDB anonymization support (NoSQL document based database support)

#### 0.5.0

1. Generate DSL from database and build schema from source as part of Whitelist approach.

## Share feedback

Please use Github [issues](https://github.com/sunitparekh/data-anonymization/issues) to share feedback, feature suggestions and report issues.

## What is data anonymization?

For almost all projects there is a need for production data dump in order to run performance tests, rehearse production releases and debug production issues.
However, getting production data and using it is not feasible due to multiple reasons, primary being privacy concerns for user data. And thus the need for data anonymization.
This tool helps you to get anonymized production data dump using either Blacklist or Whitelist strategies.

## Anonymization Strategies

### Blacklist
This approach essentially leaves all fields unchanged with the exception of those specified by the user, which are scrambled/anonymized (hence the name blacklist).
For `Blacklist` create a copy of prod database and chooses the fields to be anonymized like e.g. username, password, email, name, geo location etc. based on user specification. Most of the fields have different rules e.g. password should be set to same value for all users, email needs to be valid.

The problem with this approach is that when new fields are added they will not be anonymized by default. Human error in omitting users personal data could be damaging.

```ruby
database 'DatabaseName' do
  strategy DataAnon::Strategy::Blacklist
  source_db :adapter => 'sqlite3', :database => 'sample-data/chinook-empty.sqlite'
  ...
end
```

### Whitelist
This approach, by default scrambles/anonymizes all fields except a list of fields which are allowed to copied as is. Hence the name whitelist.
By default all data needs to be anonymized. So from production database data is sanitized record by record and inserted as anonymized data into destination database. Source database needs to be readonly.
All fields would be anonymized using default anonymization strategy which is based on the datatype, unless a special anonymization strategy is specified. For instance special strategies could be used for emails, passwords, usernames etc.
A whitelisted field implies that it's okay to copy the data as is and anonymization isn't required.
This way any new field will be anonymized by default and if we need them as is, add it to the whitelist explicitly. This prevents any human error and protects sensitive information.

```ruby
database 'DatabaseName' do
  strategy DataAnon::Strategy::Whitelist
  source_db :adapter => 'sqlite3', :database => 'sample-data/chinook.sqlite'
  destination_db :adapter => 'sqlite3', :database => 'sample-data/chinook-empty.sqlite'
  ...
end
```

## Tips

1. In Whitelist approach make source database connection READONLY.
2. Change [default field strategies](#default-field-strategies) to avoid using same strategy again and again in your DSL.
3. To run anonymization in parallel at Table level, provided no FK constraint on tables use DataAnon::Parallel::Table strategy

## Running in Parallel
Currently provides capability of running anonymization in parallel at table level provided no FK constraints on tables.
It uses [Parallel gem](https://github.com/grosser/parallel) provided by Michael Grosser.
By default it starts multiple parallel ruby processes processing table one by one.
```ruby
database 'DellStore' do
  strategy DataAnon::Strategy::Whitelist
  execution_strategy DataAnon::Parallel::Table  # by default sequential table processing
  ...
end
```


## DataAnon::Core::Field
The object that gets passed along with the field strategies.

has following attribute accessor

- `name` current field/column name
- `value` current field/column value
- `row_number` current row number
- `ar_record` active record of the current row under processing

## Field Strategies


<table>
<tr>
<th align="left">Content</th>
<th align="left">Name</th>
<th align="left">Description</th>
</tr>
<tr>
<td align="left">Text</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/LoremIpsum">LoremIpsum</a></td>
<td align="left">Generates a random Lorep Ipsum String</td>
</tr>
<tr>
<td align="left">Text</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomString">RandomString</a></td>
<td align="left">Generates a random string of equal length</td>
</tr>
<tr>
<td align="left">Text</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/StringTemplate">StringTemplate</a></td>
<td align="left">Generates a string based on provided template</td>
</tr>
<tr>
<td align="left">Text</td>
<td align="left"><a>SelectFromList</a></td>
<td align="left">Randomly selects a string from a provided list</td>
</tr>
<tr>
<td align="left">Text</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/SelectFromFile">SelectFromFile</a></td>
<td align="left">Randomly selects a string from a provided file</td>
</tr>
<tr>
<td align="left">Text</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/FormattedStringNumber">FormattedStringNumber</a></td>
<td align="left">Randomize digits in a string while maintaining the format</td>
</tr>
<tr>
<td align="left">Text</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/SelectFromDatabase">SelectFromDatabase</a></td>
<td align="left">Selects randomly from the result of a query on a database</td>
</tr>
<tr>
<td align="left">Text</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomUrl">RandomURL</a></td>
<td align="left">Anonymizes a URL while mainting the structure</td>
</tr>
</table><table>
<tr>
<th align="left">Content</th>
<th align="left">Name</th>
<th align="left">Description</th>
</tr>
<tr>
<td align="left">Number</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomInteger">RandomInteger</a></td>
<td align="left">Generates a random integer between provided limits (default 0 to 100)</td>
</tr>
<tr>
<td align="left">Number</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomIntegerDelta">RandomIntegerDelta</a></td>
<td align="left">Generates a random integer within -delta and delta of original integer</td>
</tr>
<tr>
<td align="left">Number</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomFloat">RandomFloat</a></td>
<td align="left">Generates a random float between provided limits (default 0.0 to 100.0)</td>
</tr>
<tr>
<td align="left">Number</td>
<td align="left"><a>RandomFloatDelta</a></td>
<td align="left">Generates a random float within -delta and delta of original float</td>
</tr>
<tr>
<td align="left">Number</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomBigDecimalDelta">RandomBigDecimalDelta</a></td>
<td align="left">Similar to previous but creates a big decimal object</td>
</tr>
</table><table>
<tr>
<th align="left">Content</th>
<th align="left">Name</th>
<th align="left">Description</th>
</tr>
<tr>
<td align="left">Address</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomAddress">RandomAddress</a></td>
<td align="left">Randomly selects an address from a geojson flat file [Default US address]</td>
</tr>
<tr>
<td align="left">City</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomCity">RandomCity</a></td>
<td align="left">Similar to address, picks a random city from a geojson flafile [Default US cities]</td>
</tr>
<tr>
<td align="left">Province</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomProvince">RandomProvince</a></td>
<td align="left">Similar to address, picks a random city from a geojson flafile [Default US provinces]</td>
</tr>
<tr>
<td align="left">Zip code</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomZipcode">RandomZipcode</a></td>
<td align="left">Similar to address, picks a random zipcode from a geojson flafile [Default US zipcodes]</td>
</tr>
<tr>
<td align="left">Phone number</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomPhoneNumber">RandomPhoneNumber</a></td>
<td align="left">Randomizes a phone number while preserving locale specific fomatting</td>
</tr>
</table><table>
<tr>
<th align="left">Content</th>
<th align="left">Name</th>
<th align="left">Description</th>
</tr>
<tr>
<td align="left">DateTime</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/AnonymizeDateTime">AnonymizeDateTime</a></td>
<td align="left">Anonymizes each field (except year and seconds) within natural range of the field depending on true/false flag provided</td>
</tr>
<tr>
<td align="left">Time</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/AnonymizeTime">AnonymizeTime</a></td>
<td align="left">Exactly similar to above except returned object is of type 'Time'</td>
</tr>
<tr>
<td align="left">Date</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/AnonymizeDate">AnonymizeDate</a></td>
<td align="left">Anonymizes day and month within natural ranges based on true/false flag</td>
</tr>
<tr>
<td align="left">DateTimeDelta</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/DateTimeDelta">DateTimeDelta</a></td>
<td align="left">Shifts data randomly within given range. Default shifts date within 10 days + or - and shifts time within 30 minutes.</td>
</tr>
<tr>
<td align="left">TimeDelta</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/TimeDelta">TimeDelta</a></td>
<td align="left">Exactly similar to above except returned object is of type 'Time'</td>
</tr>
<tr>
<td align="left">DateDelta</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/DateDelta">DateDelta</a></td>
<td align="left">Shifts date randomly within given delta range. Default shits date within 10 days + or -</td>
</tr>
</table><table>
<tr>
<th align="left">Content</th>
<th align="left">Name</th>
<th align="left">Description</th>
</tr>
<tr>
<td align="left">Email</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomEmail">RandomEmail</a></td>
<td align="left">Generates email randomly using the given HOSTNAME and TLD.</td>
</tr>
<tr>
<td align="left">Email</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/GmailTemplate">GmailTemplate</a></td>
<td align="left">Generates a valid unique gmail address by taking advantage of the gmail + strategy</td>
</tr>
<tr>
<td align="left">Email</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomMailinatorEmail">RandomMailinatorEmail</a></td>
<td align="left">Generates random email using mailinator hostname.</td>
</tr>
</table><table>
<tr>
<th align="left">Content</th>
<th align="left">Name</th>
<th align="left">Description</th>
</tr>
<tr>
<td align="left">First name</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomFirstName">RandomFirstName</a></td>
<td align="left">Randomly picks up first name from the predefined list in the file. Default <a href="https://raw.github.com/sunitparekh/data-anonymization/master/resources/first_names.txt">file</a> is part of the gem.</td>
</tr>
<tr>
<td align="left">Last name</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomLastName">RandomLastName</a></td>
<td align="left">Randomly picks up first name from the predefined list in the file. Default <a href="https://raw.github.com/sunitparekh/data-anonymization/master/resources/first_names.txt">file</a> is part of the gem.</td>
</tr>
<tr>
<td align="left">Full Name</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomFullName">RandomFullName</a></td>
<td align="left">Generates full name using the RandomFirstName and RandomLastName strategies.</td>
</tr>
<tr>
<td align="left">User name</td>
<td align="left"><a href="http://rubydoc.info/github/sunitparekh/data-anonymization/DataAnon/Strategy/Field/RandomUserName">RandomUserName</a></td>
<td align="left">Generates random user name of same length as original user name.</td>
</tr>
</table><h2>


## Write you own field strategies
field parameter in following code is [DataAnon::Core::Field](#dataanon-core-field)

```ruby
class MyFieldStrategy

    # method anonymize is what required
    def anonymize field
      # write your code here
    end

end
```

write your own anonymous field strategies within DSL,

```ruby
  table 'User' do
    anonymize('Password') { |field| "password" }
    anonymize('email') do |field|
        "test+#{field.row_number}@gmail.com"
    end
  end
```

## Default field strategies

```ruby
DEFAULT_STRATEGIES = {:string => FieldStrategy::RandomString.new,
                      :fixnum => FieldStrategy::RandomIntegerDelta.new(5),
                      :bignum => FieldStrategy::RandomIntegerDelta.new(5000),
                      :float => FieldStrategy::RandomFloatDelta.new(5.0),
                      :bigdecimal => FieldStrategy::RandomBigDecimalDelta.new(500.0),
                      :datetime => FieldStrategy::DateTimeDelta.new,
                      :time => FieldStrategy::TimeDelta.new,
                      :date => FieldStrategy::DateDelta.new,
                      :trueclass => FieldStrategy::RandomBoolean.new,
                      :falseclass => FieldStrategy::RandomBoolean.new
}
```

Overriding default field strategies & can be used to provide default strategy for missing data type.

```ruby
database 'Chinook' do
  ...
  default_field_strategies  :string => FieldStrategy::RandomString.new
  ...
end
```

## Logging

How do I switch off the progress bar?

```ruby
# add following line in your ruby file
ENV['show_progress'] = 'false'
```

`Logger` provides debug level messages including database queries of active record.

```ruby
DataAnon::Utils::Logging.logger.level = Logger::INFO
```

## Want to contribute?

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

[MIT License](https://github.com/sunitparekh/data-anonymization/blob/master/LICENSE.txt)

## Credits

- [ThoughtWorks Inc](http://www.thoughtworks.com), for allowing us to build this tool and make it open source.
- [Panda](https://twitter.com/sarbashrestha) for reviewing the documentation.
- [Dan Abel](http://www.linkedin.com/pub/dan-abel/0/61b/9b0) for introducing me to Blacklist and Whitelist approach for data anonymization.
- [Chirga Doshi](https://twitter.com/chiragsdoshi) for encouraging me to get this done.
- [Aditya Karle](https://twitter.com/adityakarle) for the Logo. (Coming Soon...)


