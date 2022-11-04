require "peep"
require "peep_repository"

def reset_peeps_table
  seed_sql = File.read("spec/test_seeds/seeds_peeps.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "chitter_test" })
  connection.exec(seed_sql)
end

describe PeepRepository do
  before(:each) { reset_peeps_table }

  context "#all method" do
    it "gets and returns all peeps" do
      repo = PeepRepository.new
      peeps = repo.all
      expect(peeps.length).to eq 2
      expect(peeps.first.id).to eq 1
      expect(peeps.first.message_content).to eq "Eating breakfast!"
      expect(peeps.first.time_created).to eq "2022-09-01 10:00:00"
      expect(peeps.first.user_id).to eq 1
    end
  end

  context "#reverse_chronological_order method" do
    it "gets and returns all peeps in reverse chronological order" do
      repo = PeepRepository.new
      peeps = repo.all
      most_recent_peeps = repo.reverse_chronological_order
      expect(most_recent_peeps.length).to eq 2
      expect(most_recent_peeps.first.time_created).to eq "2022-09-10 06:00:00"
      expect(most_recent_peeps.last.time_created).to eq "2022-09-01 10:00:00"
    end
  end

  context "#find method" do
    it "gets and returns a specific peep given id" do
      repo = PeepRepository.new
      peep = repo.find(1)
      expect(peep.message_content).to eq "Eating breakfast!"
      expect(peep.time_created).to eq "2022-09-01 10:00:00"
      expect(peep.user_id).to eq 1

      peep = repo.find(2)
      expect(peep.message_content).to eq "Going on holiday!"
      expect(peep.time_created).to eq "2022-09-10 06:00:00"
      expect(peep.user_id).to eq 2
    end
  end

  context "#create method" do
    it "creates a new peep (message)" do
      repo = PeepRepository.new
      new_peep = Peep.new
      new_peep.message_content = "Can't wait for the weekend..."
      new_peep.time_created = "2022-09-01 23:00:00"
      new_peep.user_id = 1

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
    end
  end

  context "#get_user_name method" do
    it "joins peeps and users tables and returns name of peep poster" do
      peeps_repo = PeepRepository.new
      peep = peeps_repo.find(1)
      expect(peeps_repo.get_user_name(peep)).to eq "Tom"
    end
  end

end
