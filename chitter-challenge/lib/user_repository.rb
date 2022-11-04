require_relative "user"
require_relative "user_repository"

class UserRepository
  def initialize
    @users = []
  end

  def all
    sql = "SELECT id, name, email, password FROM users;"
    result_set = DatabaseConnection.exec_params(sql, [])
    # Result set is an array of hashes.

    # Loop through result_set to create a model object for each record hash.
    result_set.each do |record|
      # Create a new model object with the record data.
      user = User.new
      user.id = record["id"].to_i
      user.name = record["name"]
      user.email = record["email"]
      user.password = record["password"]

      @users << user
    end

    return @users
  end

  def find(id)
    sql = "SELECT id, name, email, password FROM users WHERE id = $1;"
    result_set = DatabaseConnection.exec_params(sql, [id])

    user = User.new
    user.id = result_set[0]["id"].to_i
    user.name = result_set[0]["name"]
    user.email = result_set[0]["email"]
    user.password = result_set[0]["password"]

    return user
  end

  def create(name, email, password)
    sql = "INSERT INTO users (name, email, password) VALUES ($1, $2, $3);"
    params = [name, email, password]
    result_set = DatabaseConnection.exec_params(sql, params)

    return nil
  end

  # def find_by_email(email)
  #   @users
  #   user = @users.find { |user| user.email == email }
  #   if user.nil?
  #     return nil
  #   else
  #     return user
  #   end
  # end

  def find_by_email(email)
    sql = "SELECT id, name, email, password FROM users WHERE email = $1;"
    result_set = DatabaseConnection.exec_params(sql, [email])
    all
    return nil unless @users.any? { |user| user.email == email }
    user = User.new
    user.id = result_set[0]["id"].to_i
    user.name = result_set[0]["name"]
    user.email = result_set[0]["email"]
    user.password = result_set[0]["password"]
    return user
  end
end
