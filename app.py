from flask import Flask, request, jsonify, g, render_template
import sqlite3
import hashlib
import os

app = Flask(__name__)

DATABASE = 'database.db'
SECRET_KEY = 'your_secret_key'


def connect_db():
    return sqlite3.connect(DATABASE)


def init_db():
    with app.app_context():
        db = get_db()
        with app.open_resource('schema.sql', mode='r') as f:
            db.cursor().executescript(f.read())
        db.commit()


def get_db():
    if not hasattr(g, 'sqlite_db'):
        g.sqlite_db = connect_db()
    return g.sqlite_db


@app.teardown_appcontext
def close_db(error):
    if hasattr(g, 'sqlite_db'):
        g.sqlite_db.close()


def hash_password(password):
    salt = hashlib.sha256(os.urandom(60)).hexdigest().encode('ascii')
    pwd_hash = hashlib.pbkdf2_hmac(
        'sha512', password.encode('utf-8'), salt, 100000)
    pwd_hash = pwd_hash.hex()
    return (salt + pwd_hash).decode('ascii')


def verify_password(stored_password, provided_password):
    salt = stored_password[:64]
    stored_password = stored_password[64:]
    pwd_hash = hashlib.pbkdf2_hmac('sha512', provided_password.encode(
        'utf-8'), salt.encode('ascii'), 100000)
    pwd_hash = pwd_hash.hex()
    return pwd_hash == stored_password

# ... (seu código anterior)

def verify_password(stored_password, provided_password):
    salt = stored_password[:64]
    stored_password = stored_password[64:]
    pwd_hash = hashlib.pbkdf2_hmac('sha512', provided_password.encode(
        'utf-8'), salt.encode('ascii'), 100000)
    pwd_hash = pwd_hash.hex()
    return pwd_hash == stored_password


# ===============================================
# <<< ADICIONE O NOVO CÓDIGO EXATAMENTE AQUI >>>
@app.route('/')
def home():
    return "<h1>Bem-vindo à API de Cupcakes!</h1>"
# ===============================================


# ... (o resto da sua função continua normalmente)

# SUBSTITUA PELO CÓDIGO ABAIXO
@app.route('/register', methods=['GET', 'POST'])  # <-- MUDANÇA AQUI
def register():
    # Se o formulário foi enviado (método POST)
    if request.method == 'POST':
        data = request.json
        db = get_db()
        try:
            hashed_password = hash_password(data['password'])
            db.execute('INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
                       [data['username'], data['email'], hashed_password])
            db.commit()
            return jsonify({'message': 'Usuário registrado com sucesso!'}), 201
        except Exception as e:
            return jsonify({'error': str(e)}), 400
    # Se a página foi apenas visitada (método GET)
    else:
        return render_template('cadastro.html')


# SUBSTITUA PELO CÓDIGO ABAIXO
@app.route('/login', methods=['GET', 'POST'])  # <-- MUDANÇA AQUI
def login():
    # Se o formulário foi enviado (método POST)
    if request.method == 'POST':
        data = request.json
        db = get_db()
        cur = db.execute('SELECT * FROM users WHERE username = ?',
                         [data['username']])
        user = cur.fetchone()
        if user and verify_password(user['password'], data['password']):
            return jsonify({'message': 'Login bem-sucedido!'}), 200
        else:
            return jsonify({'error': 'Credenciais inválidas'}), 401
    # Se a página foi apenas visitada (método GET)
    else:
        return render_template('login.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
