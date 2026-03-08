from flask import Flask, render_template, request, redirect, url_for
import pymysql
import os

app = Flask(__name__)

# Configuration base de données
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_USER = os.environ.get('DB_USER', 'root')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'password')
DB_NAME = os.environ.get('DB_NAME', 'contacts_db')

def get_db():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

def init_db():
    conn = get_db()
    with conn.cursor() as cursor:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS contacts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nom VARCHAR(100) NOT NULL,
                email VARCHAR(100) NOT NULL,
                telephone VARCHAR(20)
            )
        """)
    conn.commit()
    conn.close()

@app.route('/')
def index():
    conn = get_db()
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM contacts ORDER BY id DESC")
        contacts = cursor.fetchall()
    conn.close()
    return render_template('index.html', contacts=contacts)

@app.route('/ajouter', methods=['POST'])
def ajouter():
    nom = request.form['nom']
    email = request.form['email']
    telephone = request.form['telephone']
    conn = get_db()
    with conn.cursor() as cursor:
        cursor.execute(
            "INSERT INTO contacts (nom, email, telephone) VALUES (%s, %s, %s)",
            (nom, email, telephone)
        )
    conn.commit()
    conn.close()
    return redirect(url_for('index'))

@app.route('/supprimer/<int:id>')
def supprimer(id):
    conn = get_db()
    with conn.cursor() as cursor:
        cursor.execute("DELETE FROM contacts WHERE id = %s", (id,))
    conn.commit()
    conn.close()
    return redirect(url_for('index'))

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000, debug=True)
