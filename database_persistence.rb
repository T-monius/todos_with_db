# database_persistence.rb

require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: 'todos')
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)

    tuple = result.first
    list_id = tuple['id'].to_i
    { id: list_id , name: tuple['name'] , todos: find_todos_for_a_list(list_id) }
  end

  def all_lists
    sql = "SELECT * FROM lists;"
    result = query(sql)
    lists = result.map do |tuple|
      list_id = tuple['id'].to_i
      { id: list_id , name: tuple['name'] , todos: find_todos_for_a_list(list_id) }
    end
    # @logger.info lists
    lists
  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    query(sql, list_name)
  end

  def delete_list(id)
    sql_todos_deletion = "DELETE FROM todos WHERE list_id = $1"
    sql_list_deletion = "DELETE FROM lists WHERE id = $1;"
    query(sql_todos_deletion, id)
    query(sql_list_deletion, id)
  end

  def update_list_name(id, new_name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2;"
    query(sql, new_name, id)
  end

  def create_new_todo(list_id, todo_name)
    # list = find_list(list_id)
    # id = next_element_id(list[:todos])
    # list[:todos] << { id: id, name: todo_name, completed: false }
  end

  def delete_todo(list_id, todo_id)
    # list = find_list(list_id)
    # list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo_status(list_id, todo_id, new_status)
    # list = find_list(list_id)
    # todo = list[:todos].find { |td| td[:id] == todo_id }
    # todo[:completed] = new_status
  end

  def mark_all_todos_complete(list_id)
    # list = find_list(list_id)
    # list[:todos].each { |todo| todo[:completed] = true }
  end

  private

  def find_todos_for_a_list(list_id)
    sql = <<~TODOS
            SELECT * FROM todos
            WHERE list_id = $1;
          TODOS
    result = query(sql, list_id)
    todos = result.map do |tuple|
      { id: tuple['id'].to_i,
        name: tuple['name'],
        completed: tuple['completed'] == 't' }
    end
    # @logger.info todos
    todos
  end
end