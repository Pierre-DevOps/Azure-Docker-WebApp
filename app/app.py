from flask import Flask, render_template_string
import socket
import os
from datetime import datetime

app = Flask(__name__)

# Template HTML simple
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Azure Docker WebApp</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            max-width: 600px;
            width: 100%;
        }
        h1 {
            color: #667eea;
            margin-bottom: 10px;
        }
        .subtitle {
            color: #666;
            margin-bottom: 30px;
        }
        .info-box {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
        .info-box strong {
            color: #333;
        }
        .info-box span {
            color: #667eea;
            font-weight: bold;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #999;
            font-size: 14px;
        }
        .status {
            display: inline-block;
            background: #10b981;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Azure Docker WebApp</h1>
        <p class="subtitle">Application conteneurisée déployée sur Azure</p>
        <div class="status">✓ Conteneur actif</div>
        
        <div class="info-box">
            <strong>🖥️ Hostname:</strong> <span>{{ hostname }}</span>
        </div>
        
        <div class="info-box">
            <strong>🌐 Adresse IP:</strong> <span>{{ ip_address }}</span>
        </div>
        
        <div class="info-box">
            <strong>🕐 Date/Heure:</strong> <span>{{ current_time }}</span>
        </div>
        
        <div class="info-box">
            <strong>🐍 Version Python:</strong> <span>{{ python_version }}</span>
        </div>
        
        <div class="info-box">
            <strong>📦 Environnement:</strong> <span>{{ environment }}</span>
        </div>
        
        <div class="footer">
            Projet DevOps - CCP1 Bachelor Administrateur Système DevOps<br>
            Automatisation du déploiement avec Docker & Azure
        </div>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    # Récupération des informations système
    hostname = socket.gethostname()
    try:
        ip_address = socket.gethostbyname(hostname)
    except:
        ip_address = "Non disponible"
    
    current_time = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    python_version = os.popen('python --version').read().strip()
    environment = os.getenv('ENVIRONMENT', 'Production')
    
    return render_template_string(
        HTML_TEMPLATE,
        hostname=hostname,
        ip_address=ip_address,
        current_time=current_time,
        python_version=python_version,
        environment=environment
    )

@app.route('/health')
def health():
    """Endpoint de health check pour Azure"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}, 200

if __name__ == '__main__':
    # Le conteneur écoutera sur le port 5000
    app.run(host='0.0.0.0', port=5000, debug=False)
