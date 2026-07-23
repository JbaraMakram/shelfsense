from flask import Flask, render_template, request, redirect, url_for, jsonify
from flask_sqlalchemy import SQLAlchemy
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import os

app = Flask(__name__)

# ── Database ──────────────────────────────────────────────────────
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///shelfsense.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# ── Prometheus Metrics ────────────────────────────────────────────
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)
REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency',
    ['endpoint']
)

# ── Database Model ────────────────────────────────────────────────
class Item(db.Model):
    id       = db.Column(db.Integer, primary_key=True)
    name     = db.Column(db.String(100), nullable=False)
    quantity = db.Column(db.Integer, nullable=False, default=0)
    location = db.Column(db.String(100), nullable=False)
    category = db.Column(db.String(50), nullable=False)

    def __repr__(self):
        return f'<Item {self.name}>'

# ── Routes ────────────────────────────────────────────────────────
@app.route('/')
def dashboard():
    start = time.time()
    items      = Item.query.all()
    total      = len(items)
    low_stock  = [i for i in items if i.quantity < 5]
    REQUEST_COUNT.labels(method='GET', endpoint='/', status='200').inc()
    REQUEST_LATENCY.labels(endpoint='/').observe(time.time() - start)
    return render_template('dashboard.html', items=items, total=total, low_stock=low_stock)

@app.route('/items')
def items():
    start = time.time()
    all_items = Item.query.all()
    REQUEST_COUNT.labels(method='GET', endpoint='/items', status='200').inc()
    REQUEST_LATENCY.labels(endpoint='/items').observe(time.time() - start)
    return render_template('items.html', items=all_items)

@app.route('/items/add', methods=['GET', 'POST'])
def add_item():
    if request.method == 'POST':
        item = Item(
            name     = request.form['name'],
            quantity = int(request.form['quantity']),
            location = request.form['location'],
            category = request.form['category']
        )
        db.session.add(item)
        db.session.commit()
        REQUEST_COUNT.labels(method='POST', endpoint='/items/add', status='200').inc()
        return redirect(url_for('items'))
    return render_template('add_item.html')

@app.route('/items/delete/<int:id>')
def delete_item(id):
    item = Item.query.get_or_404(id)
    db.session.delete(item)
    db.session.commit()
    return redirect(url_for('items'))

# ── DevOps Endpoints ──────────────────────────────────────────────
@app.route('/health')
def health():
    return jsonify({'status': 'ok', 'service': 'shelfsense'}), 200

@app.route('/ready')
def ready():
    try:
        db.session.execute(db.text('SELECT 1'))
        return jsonify({'status': 'ready', 'db': 'connected'}), 200
    except Exception as e:
        return jsonify({'status': 'not ready', 'error': str(e)}), 503

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

# ── Init ──────────────────────────────────────────────────────────
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000, debug=False)
