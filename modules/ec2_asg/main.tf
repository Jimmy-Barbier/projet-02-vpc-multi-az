# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.sg_ec2_id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Mise à jour du système
    yum update -y

    # Installation de Python et pip
    yum install -y python3 python3-pip git

    # Création du dossier app
    mkdir -p /app
    cd /app

    # Création de l'app Flask
    cat > /app/app.py << 'APPEOF'
    from flask import Flask, render_template, request, redirect, url_for
    import pymysql
    import os

    app = Flask(__name__)

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
    APPEOF

    # Création du dossier templates
    mkdir -p /app/templates

    # Création du fichier HTML
    cat > /app/templates/index.html << 'HTMLEOF'
    <!DOCTYPE html>
    <html lang="fr">
    <head>
        <meta charset="UTF-8">
        <title>Gestion de Contacts</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Segoe UI', sans-serif; background: #f0f4f8; color: #1a202c; }
            header { background: #2b6cb0; color: white; padding: 20px 40px; }
            header h1 { font-size: 1.5rem; }
            header p { font-size: 0.85rem; opacity: 0.8; margin-top: 4px; }
            .container { max-width: 900px; margin: 40px auto; padding: 0 20px; }
            .card { background: white; border-radius: 12px; padding: 28px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 28px; }
            .card h2 { font-size: 1.1rem; margin-bottom: 20px; color: #2d3748; }
            .form-grid { display: grid; grid-template-columns: 1fr 1fr 1fr auto; gap: 12px; align-items: end; }
            .form-group { display: flex; flex-direction: column; gap: 6px; }
            label { font-size: 0.8rem; font-weight: 600; color: #4a5568; text-transform: uppercase; }
            input { padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 0.95rem; }
            input:focus { outline: none; border-color: #2b6cb0; }
            button { padding: 10px 20px; background: #2b6cb0; color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; }
            button:hover { background: #2c5282; }
            table { width: 100%; border-collapse: collapse; }
            th { text-align: left; padding: 10px 14px; font-size: 0.78rem; text-transform: uppercase; color: #718096; border-bottom: 2px solid #e2e8f0; }
            td { padding: 14px; border-bottom: 1px solid #f7fafc; }
            .btn-delete { padding: 6px 12px; background: #fed7d7; color: #c53030; border: none; border-radius: 6px; cursor: pointer; font-size: 0.8rem; font-weight: 600; }
            .empty { text-align: center; padding: 40px; color: #a0aec0; }
            .count { font-size: 0.85rem; color: #718096; margin-bottom: 16px; }
        </style>
    </head>
    <body>
    <header>
        <h1>📋 Gestion de Contacts</h1>
        <p>Projet 02 — AWS VPC Multi-AZ · EC2 Flask · RDS MySQL</p>
    </header>
    <div class="container">
        <div class="card">
            <h2>Ajouter un contact</h2>
            <form action="/ajouter" method="POST">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="nom">Nom</label>
                        <input type="text" id="nom" name="nom" placeholder="Jean Dupont" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" placeholder="jean@email.com" required>
                    </div>
                    <div class="form-group">
                        <label for="telephone">Téléphone</label>
                        <input type="text" id="telephone" name="telephone" placeholder="06 00 00 00 00">
                    </div>
                    <button type="submit">Ajouter</button>
                </div>
            </form>
        </div>
        <div class="card">
            <h2>Liste des contacts</h2>
            <p class="count">{{ contacts|length }} contact(s) enregistré(s)</p>
            {% if contacts %}
            <table>
                <thead>
                    <tr><th>#</th><th>Nom</th><th>Email</th><th>Téléphone</th><th>Action</th></tr>
                </thead>
                <tbody>
                    {% for contact in contacts %}
                    <tr>
                        <td>{{ contact.id }}</td>
                        <td>{{ contact.nom }}</td>
                        <td>{{ contact.email }}</td>
                        <td>{{ contact.telephone or '—' }}</td>
                        <td><a href="/supprimer/{{ contact.id }}"><button class="btn-delete">Supprimer</button></a></td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
            {% else %}
            <div class="empty">Aucun contact pour l'instant. Ajoutez-en un !</div>
            {% endif %}
        </div>
    </div>
    </body>
    </html>
    HTMLEOF

    # Installation des dépendances Python
    pip3 install Flask==3.0.0 PyMySQL==1.1.0 cryptography==42.0.0

    # Configuration des variables d'environnement
    cat > /etc/environment << 'ENVEOF'
    DB_HOST=${var.db_host}
    DB_USER=${var.db_username}
    DB_PASSWORD=${var.db_password}
    DB_NAME=${var.db_name}
    ENVEOF

    # Export des variables pour la session courante
    export DB_HOST="${var.db_host}"
    export DB_USER="${var.db_username}"
    export DB_PASSWORD="${var.db_password}"
    export DB_NAME="${var.db_name}"

    # Création du service systemd pour Flask
    cat > /etc/systemd/system/flask.service << 'SERVICEEOF'
    [Unit]
    Description=Flask Contact App
    After=network.target

    [Service]
    Type=simple
    User=root
    WorkingDirectory=/app
    Environment="DB_HOST=${var.db_host}"
    Environment="DB_USER=${var.db_username}"
    Environment="DB_PASSWORD=${var.db_password}"
    Environment="DB_NAME=${var.db_name}"
    ExecStart=/usr/bin/python3 /app/app.py
    Restart=always

    [Install]
    WantedBy=multi-user.target
    SERVICEEOF

    # Démarrage du service Flask
    systemctl daemon-reload
    systemctl enable flask
    systemctl start flask
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-ec2"
      Environment = var.env
      Owner       = var.owner
      ManagedBy   = "Terraform"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = var.owner
    propagate_at_launch = true
  }
}