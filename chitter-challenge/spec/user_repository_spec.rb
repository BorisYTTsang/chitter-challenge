require "user"
require "user_repository"

def reset_users_table
  seed_sql = File.read("spec/test_seeds/seeds_users.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "chitter_test" })
  connection.exec(seed_sql)
end

describe UserRepository do
  before(:each) { reset_users_table }

  context "#all method" do
    it "gets and returns all users" do
      repo = UserRepository.new
      users = repo.all
      expect(users.length).to eq 2
      expect(users.first.id).to eq 1
      expect(users.first.name).to eq "Tom"
      expect(users.first.email).to eq "tom@gmail.com"
      expect(users.first.password).to eq "password123"
    end

    context "#find(id) method" do
      it "gets and returns a specific user given id" do
        repo = UserRepository.new
        user = repo.find(1)
        expect(user.id).to eq 1
        expect(user.name).to eq "Tom"
        expect(user.email).to eq "tom@gmail.com"
        expect(user.password).to eq "password123"

        user = repo.find(2)
        expect(user.id).to eq 2
        expect(user.name).to eq "Sarah"
        expect(user.email).to eq "sarah@gmail.com"
        expect(user.password).to eq "!@£$%^456"
      end
    end

    context "#find_by_email(email) method" do
      it "gets and returns a specific user given email" do
        repo = UserRepository.new
        user = repo.find_by_email("tom@gmail.com")
        expect(user.id).to eq 1
        expect(user.name).to eq "Tom"
        expect(user.email).to eq "tom@gmail.com"
        expect(user.password).to eq "password123"

        user = repo.find_by_email("sarah@gmail.com")
        expect(user.id).to eq 2
        expect(user.name).to eq "Sarah"
        expect(user.email).to eq "sarah@gmail.com"
        expect(user.password).to eq "!@£$%^456"
      end

      it "returns nil when given email not present in database" do
        repo = UserRepository.new
        user = repo.find_by_email("roi@outlook.com")
        expect(user).to eq nil
      end
    end

    context "#create method" do
      it "creates a new user" do
        repo = UserRepository.new
        repo.create("Boris", "boris@outlook.com", "horizon_Z$R0-d@wN")
        users = repo.all
        expect(users.length).to eq 3
        expect(users.any? { |users| users.name == "Boris" }).to eq true
      end
    end
  end
end
