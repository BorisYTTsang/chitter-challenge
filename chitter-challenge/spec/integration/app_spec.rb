require "spec_helper"
require "rack/test"
require_relative "../../app"

def reset_users_table
  seed_sql = File.read("spec/seeds/test_seeds/seeds_users.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "chitter_test" })
  connection.exec(seed_sql)
end

def reset_peeps_table
  seed_sql = File.read("spec/seeds/test_seeds/seeds_peeps.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "chitter_test" })
  connection.exec(seed_sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  before(:each) do
    reset_users_table
    reset_peeps_table
  end

  context "GET /" do
    it "should return an index page if not logged in" do
      response = get("/")
      expect(response.status).to eq 200
      expect(response.body).to include "<h1>Welcome to Chitter!</h1>"
    end

    it "should return /peeps if logged in" do
      post("/login", email: "tom@gmail.com", password: "password123")
      response = get("/")
      expect(response.status).to eq 302
    end
  end

  context "GET /login" do
    it "should return a login page" do
      response = get("/login")
      expect(response.status).to eq 200
    end
  end

  context "POST /login" do
    it "logs user in and displays login success page" do
      response = post("/login", email: "sarah@gmail.com", password: "!@£$%^456")
      expect(response.status).to eq 200
      expect(response.body).to include("Log-In Successful!")
    end

    it "returns login failure page when user email not found" do
      response =
        post("/login", email: "roi@outlook.com", password: "password777")
      expect(response.status).to eq 200
      expect(response.body).to include("Log-In Unsuccessful!")
    end

    it "returns login failure page when user password is incorrect" do
      response =
        post("/login", email: "tom@gmail.com", password: "password777")
      expect(response.status).to eq 200
      expect(response.body).to include("Log-In Unsuccessful!")
    end
  end

  context "GET /signup" do
    it "should return a sign-up page" do
      response = get("/signup")
      expect(response.status).to eq 200
      expect(response.body).to include "<h1>Chitter Sign-Up:</h1>"
      expect(response.body).to include '<form method="POST" action="/users">'
      expect(response.body).to include '<input type="text" placeholder="Enter name" name="name" required />'
      expect(response.body).to include '<input type="text" placeholder="Enter email" name="email" required />'
      expect(response.body).to include '<input type="password" placeholder="Enter password" name="password" required />'
    end

    it "signing up after logging in redirects to /peeps" do
      post("/login", email: "tom@gmail.com", password: "password123")
      response = get("/signup")
      expect(response.status).to eq 302
    end
  end

  context "POST /users" do
    it "creates a new user account" do
      response = post("/users", name: "Han Solo", email: "hansolo@gmail.com", password: "falcon456")
      expect(response.status).to eq 200
      expect(response.body).to include "<h1>Thanks Han Solo for creating an account!</h1>"
    end

    it "returns sign-up error page if email already exists" do
      response = post("/users", name: "Craig", email: "tom@gmail.com", password: "falcon456")
      expect(response.status).to eq 200
      expect(response.body).to include "Email address is already associated with an account."
    end
  end

  context "GET /peeps" do
    it "returns a list of peeps (messages) when logged in with greeting to user" do
      response = post("/login", email: "tom@gmail.com", password: "password123")
      expect(response.body).to include("Log-In Successful!")
      response = get("/peeps")
      expect(response.status).to eq 200
      expect(response.body).to include ("Hey, Tom! Here are all peeps:")
    end
    
    it "should redirect to login page if not logged-in" do
      response = get("/peeps")
      expect(response.status).to eq 302
    end
  end

  context "POST /peeps/all" do
    it "should return 302 OK" do
      response = get("/peeps/all")
      expect(response.status).to eq 302
    end
  end

  context "POST /peeps/user" do
    it "should return 302 OK" do
      response = get("/peeps/user")
      expect(response.status).to eq 302
    end
  end

  context "POST /logout" do
    it "logs user out and /peeps redirects back to login page" do
      post("/login", email: "kat@gmail.com", password: "!@£$%^456")
      post("/logout")
      response = get("/peeps")
      expect(response.status).to eq 302
    end
  end

  context "GET /peeps/new" do
    it "returns 200 OK and gets form for new peep for session user" do
      post("/login", email: "tom@gmail.com", password: "password123")
      response = get("/peeps/new")
      expect(response.status).to eq 200
      expect(response.body).to include("Post a new peep:")
    end

    it "returns 302 Redirected (to /login)" do
      response = get("/peeps/new")
      expect(response.status).to eq 302
    end
  end

  context "POST /peeps" do
    it "returns 200 OK and adds new peep, displayed on /peeps page" do
      post("/login", email: "tom@gmail.com", password: "password123")
      response = post("/peeps", message_content: "Another day, another dollar...", time_created: "2022-09-01 23:00:00")
      peeps_repo = PeepRepository.new.all
      expect(response.status).to eq 200
      expect(peeps_repo.size).to eq 3
      expect(response.body).to include("Peep posted!")
    end

    it "returns 302 redirected when not logged in" do
      response = post("/peeps", message_content: "Hello")
      expect(response.status).to eq 302
    end
  end
end
