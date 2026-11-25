require 'debug'
require 'awesome_print'

class App < Sinatra::Base
  register Sinatra::Reloader

  def db
    return @db if @db

    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true

    @db
  end

  get '/todos' do
    @todos = db.execute('
            SELECT
                *
            FROM todos
            WHERE todos.status=0
        ')

    @done = db.execute('
            SELECT
                *
            FROM todos

            WHERE todos.status=1
        ')

    erb(:'todos/index')
  end

  get '/todos/new' do
    erb(:'todos/new')
  end

  post '/todos' do
    db.execute('INSERT INTO todos (name,description,priority,status,category_id) VALUES (?, ?, ?, ?, ?)',
               [params[:name], params[:description], 0, 0, 0])
    redirect('/todos')
  end

  get '/todos/:id' do |id|
    @todo = db.execute('
                SELECT * FROM todos WHERE todos.id=?
            ', id).first

    erb(:'todos/show')
  end

  post '/todos/:id/delete' do |id|
    db.execute('DELETE FROM todos WHERE id=?', id)
    redirect('/todos')
  end

  get '/todos/:id/edit' do |id|
    @todo = db.execute('SELECT * FROM todos WHERE todos.id=?', id).first

    erb(:'todos/edit')
  end

  post '/todos/:id/update' do |id|
    db.execute('UPDATE todos SET name=?, description=?, status=? WHERE id=?',
               [params[:name], params[:description], params[:status], id])

    redirect('/todos')
  end
end
