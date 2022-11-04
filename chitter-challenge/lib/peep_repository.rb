require_relative "peep"
require_relative "peep_repository"
require "time"

class PeepRepository
  def initialize
    @peeps = []
  end

  def all
    sql = "SELECT id, message_content, time_created, user_id FROM peeps;"
    result_set = DatabaseConnection.exec_params(sql, [])
    # Result set is an array of hashes.

    # Loop through result_set to create a model object for each record hash.
    result_set.each do |record|
      # Create a new model object with the record data.
      peep = Peep.new
      peep.id = record["id"].to_i
      peep.message_content = record["message_content"]
      peep.time_created = (record["time_created"])
      peep.user_id = record["user_id"].to_i
      peep.user_name = get_user_name(peep)

      @peeps << peep
    end

    return @peeps
  end

  def reverse_chronological_order
    return(
      @peeps.sort_by { |attribute| Time.parse(attribute.time_created) }.reverse
    )
  end

  def find(id)
    sql =
      "SELECT id, message_content, time_created, user_id FROM peeps WHERE id = $1;"
    result_set = DatabaseConnection.exec_params(sql, [id])

    peep = Peep.new
    peep.id = result_set[0]["id"].to_i
    peep.message_content = result_set[0]["message_content"]
    peep.time_created = (result_set[0]["time_created"])
    peep.user_id = result_set[0]["user_id"].to_i

    return peep
  end

  def create(peep)
    sql =
      "INSERT INTO peeps (message_content, time_created, user_id) VALUES ($1, $2, $3);"
    sql_params = [peep.message_content, peep.time_created, peep.user_id]
    DatabaseConnection.exec_params(sql, sql_params)

    return nil
  end

  def get_user_name(peep) # takes single peep and returns peep writer's name as String 
    sql = "SELECT users.name FROM peeps JOIN users ON peeps.user_id = users.id WHERE peeps.id = $1;"
    params = [peep.user_id]
    results_set = DatabaseConnection.exec_params(sql, params)
    return results_set[0]["name"]
  end
end