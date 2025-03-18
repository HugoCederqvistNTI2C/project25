require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

def db_connection
  db = SQLite3::Database.new('db/Databas.db')
  db.results_as_hash = true
  return db
end

get('/') do
  slim(:start)
end

get('/pass') do
  redirect('/login') unless session[:user_id]
  db = db_connection
  @passes = db.execute("SELECT * FROM pass WHERE user_id = ?", [session[:user_id]])
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
    db = db_connection
    db.execute("INSERT INTO users (namn, losen) VALUES (?,?)", [namn, password_digest])
    redirect('/login')
  else
    "Lösenorden matchade inte!"
  end
end

get('/login') do
  slim(:login)
end

post('/login') do
  namn = params[:name]
  losen = params[:losen]
  db = db_connection
  user = db.execute("SELECT * FROM users WHERE namn = ?", [namn]).first
  
  if user && BCrypt::Password.new(user['losen']) == losen
    session[:user_id] = user['id']
    redirect('/pass')
  else
    "Fel användarnamn eller lösenord!"
  end
end

get('/logout') do
  session.clear
  redirect('/login')
end

get('/pass/new') do
  redirect('/login') unless session[:user_id]
  slim(:new_pass)
end

post('/pass/create') do
  redirect('/login') unless session[:user_id]
  name = params[:name]
  exce = params[:exce]
  vikt = params[:vikt].to_i
  sets = params[:sets].to_i
  reps = params[:reps].to_i
  db = db_connection
  db.execute("INSERT INTO pass (user_id, name, exce, vikt, sets, reps) VALUES (?,?,?,?,?,?)", [session[:user_id], name, exce, vikt, sets, reps])
  redirect('/pass')
end

get('/pass/:id/edit') do
  redirect('/login') unless session[:user_id]
  db = db_connection
  @pass = db.execute("SELECT * FROM pass WHERE id = ? AND user_id = ?", [params[:id], session[:user_id]]).first
  slim(:edit_pass)
end

post('/pass/:id/update') do
  redirect('/login') unless session[:user_id]
  name = params[:name]
  exce = params[:exce]
  vikt = params[:vikt].to_i
  sets = params[:sets].to_i
  reps = params[:reps].to_i
  db = db_connection
  db.execute("UPDATE pass SET name = ?, exce = ?, vikt = ?, sets = ?, reps = ? WHERE id = ? AND user_id = ?", [name, exce, vikt, sets, reps, params[:id], session[:user_id]])
  redirect('/pass')
end

post('/pass/:id/delete') do
  redirect('/login') unless session[:user_id]
  db = db_connection
  db.execute("DELETE FROM pass WHERE id = ? AND user_id = ?", [params[:id], session[:user_id]])
  redirect('/pass')
end

before do
  @logged_in = session[:user_id] != nil
end
