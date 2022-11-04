Peeps Model and Repository Classes Design Recipe
Copy this recipe template to design and implement Model and Repository classes for a database table.

1. Design and create the Table
   If the table is already created in the database, you can skip this step.

Table created

2. Create Test SQL seeds
   Your tests will depend on data stored in PostgreSQL to run.

If seed data is provided (or you already created it), you can skip this step.

```sql
-- EXAMPLE
-- (file: spec/seeds\_{table_name}.sql)

-- Write your SQL seed here.

-- First, you'd need to truncate the table - this is so our table is emptied between each test run,
-- so we can start with a fresh state.
-- (RESTART IDENTITY resets the primary key)

TRUNCATE TABLE peeps RESTART IDENTITY; -- replace with your own table name.

-- Below this line there should only be `INSERT` statements.
-- Replace these statements with your own seed data.

INSERT INTO peeps (message_content, time_created, user_id) VALUES ('Eating breakfast!', '2022-09-01 10:00:00', 1);
INSERT INTO peeps (message_content, time_created, user_id) VALUES ('Going on holiday!', '2022-09-10 06:00:00', 2);

```

Run this SQL file on the database to truncate (empty) the table, and insert the seed data. Be mindful of the fact any existing records in the table will be deleted.

```bash
psql -h 127.0.0.1 your*database_name < seeds*{table_name}.sql
```

3. Define the class names
   Usually, the Model class name will be the capitalised table name (single instead of plural). The same name is then suffixed by Repository for the Repository class name.

```ruby
# EXAMPLE
# Table name: peeps

# Model class
# (in lib/peep.rb)
class Peep
end

# Repository class
# (in lib/book_repository.rb)
class PeepRepository
end
```

4. Implement the Model class
   Define the attributes of your Model class. You can usually map the table columns to the attributes of the class, including primary and foreign keys.

```ruby
# EXAMPLE
# Table name: peeps

# Model class
# (in lib/peep.rb)
class Peep
  # Replace the attributes by your own columns.
  attr_accessor :id, :message_content, :time_created, :user_id
end
```

You may choose to test-drive this class, but unless it contains any more logic than the example above, it is probably not needed.

5. Define the Repository Class interface
   Your Repository class will need to implement methods for each "read" or "write" operation you'd like to run against the database.

Using comments, define the method signatures (arguments and return value) and what they do - write up the SQL queries that will be used by each method.

```ruby
# EXAMPLE

# Table name: peeps
# Repository class
# (in lib/peep_repository.rb)

class PeepRepository
  # Selecting all records
  # No arguments
  def all
    # Executes the SQL query: # SELECT id, message_content, time_created, user_id FROM peeps;
    # Returns an array of Peep objects.
  end

  def reverse_chronological_order
    # Returns an array of Peep objects in reverse order based on time_created.
    return(
      @peeps.sort_by { |attribute| Time.parse(attribute.time_created) }.reverse
    )
  end

  def find(id)
    # Executes the SQL query: "SELECT id, message_content, time_created, user_id FROM peeps WHERE id = $1;"
    # Returns a single Peep object based on given id.
  end

  def create(peep)
    # Executes the SQL query: "INSERT INTO peeps (message_content, time_created, user_id) VALUES ($1, $2, $3);"
    # Does not need to return anything as only creates record.
  end
end
```

6. Write Test Examples
   Write Ruby code that defines the expected behaviour of the Repository class, following your design from the table written in step 5.

These examples will later be encoded as RSpec tests.

```ruby
# EXAMPLES

# 1
# Get all peeps

repo = PeepRepository.new
peeps = repo.all
peeps.length # => 2 due to seeds_peeps having 2 entries
peeps.first.id # => 1
peeps.first.message_content # => ('Eating breakfast!')
peeps.first.time_created # => ('2022-09-01 10:00:00')
peeps.first.user_id # => 1

# 2
# Get a single peep

repo = PeepRepository.new
peep = repo.find(1)
peep.id # => 1
peep.message_content # => ('Eating breakfast!')
peep.time_created # => ('2022-09-01 10:00:00')
peep.user_id # => 1

peep = repo.find(2)
peep.id # => 2
peep.message_content # => ('Going on holiday!')
peep.time_created # => ('2022-09-10 06:00:00')
peep.user_id # => 2

# 3
# Get all peeps in reverse chronological order

repo = PeepRepository.new
peeps = repo.all
expect(peeps.length).to eq 2
expect(peeps.first.time_created).to eq "2022-09-10 06:00:00"
expect(peeps.last.time_created).to eq "2022-09-01 10:00:00"

# 4
# Creates a new peep (message)

repo = PeepRepository.new
new_peep = Peep.new
expect(new_peep.message_content).to eq = "Can't wait for the weekend..."
expect(new_peep.time_created).to eq = "2022-09-01 23:00:00"
expect(new_peep.user_id).to eq = 1

repo.create(new_peep)

all_peeps = repo.all
expect(all_peeps).to include (
          have_attributes(
            message_content:
              new_peep.message_content = "Can't wait for the weekend...",
            time_created: new_peep.time_created = "2022-09-01 23:00:00",
            user_id: new_peep.user_id = 1
          )
        )
```

Encode this example as a test.

7. Reload the SQL seeds before each test run
   Running the SQL code present in the seed file will empty the table and re-insert the seed data.

This is so you get a fresh table contents every time you run the test suite.

```ruby
# EXAMPLE

# file: spec/peep_repository_spec.rb

def reset_peeps_table
  seed_sql = File.read("spec/test_seeds/seeds_peeps.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "chitter_test" })
  connection.exec(seed_sql)
end

describe PeepRepository do
  before(:each) { reset_peeps_table }
end

# (your tests will go here).
```

8. Test-drive and implement the Repository class behaviour
   After each test you write, follow the test-driving process of red, green, refactor to implement the behaviour.