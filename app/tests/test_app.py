import pytest
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app, db

@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    with app.app_context():
        db.create_all()
        yield app.test_client()
        db.drop_all()

def test_health(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert b'ok' in response.data

def test_ready(client):
    response = client.get('/ready')
    assert response.status_code == 200

def test_dashboard(client):
    response = client.get('/')
    assert response.status_code == 200

def test_items(client):
    response = client.get('/items')
    assert response.status_code == 200
