require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:start)
end

get('/pass') do
    slim(:pass)
end

get('/register') do
    slim(:register)
end

post('/users/new') do
    namn = params[:namn]
    losen = params[:losen]
    losen_igen = params[:losen_igen]
    if losen == losen_igen
      password_digest = BCrypt::Password.create(losen)
      db = SQLite3::Database.new('db/Databas.db')
      db.execute("INSERT INTO users (namn, losen) VALUES (?,?)",[namn, password_digest])
      redirect('/')
    else
  
      "Lösenorden matchade inte!"
    end
end

get('/login') do
    slim(:login)
end
