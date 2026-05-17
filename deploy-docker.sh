#!/bin/bash
# Run this script on each EC2 instance to deploy the e-commerce application

set -e

echo "🚀 E-Commerce Application Deployment Script"
echo "==========================================="

APP_DIR="/opt/ecommerce"
echo "📁 Creating application directory at $APP_DIR..."
sudo mkdir -p $APP_DIR
sudo chown -R ubuntu:ubuntu $APP_DIR
cd $APP_DIR

echo "📦 Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker

echo "📄 Creating application files..."

# Create app.js
cat > app.js << 'APPFILE'
const express = require('express');
const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URL = process.env.MONGO_URL || 'mongodb://mongodb:27017/ecommerce';

app.disable('x-powered-by');
app.use(bodyParser.json());

const products = [
  { id: 1, name: 'Laptop', price: 1200, description: 'High-performance laptop with latest processor and graphics' },
  { id: 2, name: 'Phone', price: 800, description: 'Latest flagship smartphone with amazing camera' },
  { id: 3, name: 'Smartwatch', price: 300, description: 'Feature-rich smartwatch with health monitoring' },
  { id: 4, name: 'Tablet', price: 500, description: 'Powerful tablet for work and entertainment' },
  { id: 5, name: 'Headphones', price: 150, description: 'Premium wireless headphones with noise cancellation' }
];

app.get('/', (req, res) => {
  const html = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Commerce Store</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        header {
            text-align: center;
            color: white;
            margin-bottom: 40px;
        }
        .logo { font-size: 48px; margin-bottom: 10px; }
        h1 { font-size: 42px; font-weight: 300; }
        .subtitle { font-size: 18px; margin-top: 10px; opacity: 0.9; }
        .status-banner {
            background: #4CAF50;
            color: white;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 30px;
            text-align: center;
            font-size: 16px;
            font-weight: 500;
        }
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        .product-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .product-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        }
        .product-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .product-icon { font-size: 32px; }
        .product-name { font-size: 20px; font-weight: 600; }
        .product-content { padding: 20px; }
        .product-description { color: #666; margin-bottom: 15px; font-size: 14px; line-height: 1.6; }
        .product-price { font-size: 28px; font-weight: bold; color: #667eea; margin-bottom: 15px; }
        .add-to-cart-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: opacity 0.3s ease;
            width: 100%;
        }
        .add-to-cart-btn:hover { opacity: 0.9; }
        .cart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #eee;
        }
        .cart-toggle {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            position: relative;
        }
        .cart-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            background: #FF6B6B;
            color: white;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: bold;
        }
        .cart-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 999;
        }
        .cart-overlay.open { display: block; }
        .cart-panel {
            position: fixed;
            right: -400px;
            top: 0;
            width: 400px;
            height: 100vh;
            background: white;
            box-shadow: -10px 0 30px rgba(0,0,0,0.3);
            z-index: 1000;
            overflow-y: auto;
            transition: right 0.3s ease;
            padding: 20px;
        }
        .cart-panel.open { right: 0; }
        .cart-title { font-size: 24px; font-weight: 600; margin-bottom: 20px; }
        .cart-items { margin-bottom: 20px; }
        .cart-item {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .item-details { flex: 1; }
        .item-name { font-weight: 600; }
        .item-quantity { color: #666; font-size: 14px; }
        .item-price { font-weight: 600; color: #667eea; }
        .qty-controls {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-top: 8px;
        }
        .qty-btn {
            background: #667eea;
            color: white;
            border: none;
            width: 24px;
            height: 24px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: bold;
        }
        .remove-btn {
            background: #FF6B6B;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
        }
        .cart-total {
            font-size: 18px;
            font-weight: 600;
            padding: 15px 0;
            border-top: 2px solid #eee;
            border-bottom: 2px solid #eee;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
        }
        .checkout-btn {
            background: #4CAF50;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            width: 100%;
            margin-bottom: 10px;
        }
        .clear-cart-btn {
            background: #FF6B6B;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            width: 100%;
        }
        .empty-cart { text-align: center; color: #999; padding: 40px 0; }
        .success-message {
            background: #4CAF50;
            color: white;
            padding: 15px;
            border-radius: 6px;
            margin-top: 20px;
            display: none;
            text-align: center;
        }
        .toast {
            position: fixed;
            bottom: 20px;
            left: 20px;
            background: #333;
            color: white;
            padding: 15px 20px;
            border-radius: 6px;
            z-index: 2000;
            animation: slideIn 0.3s ease;
        }
        @keyframes slideIn {
            from { transform: translateX(-400px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        footer {
            text-align: center;
            color: white;
            opacity: 0.8;
            margin-top: 40px;
            font-size: 14px;
        }
        .footer-links {
            margin-top: 20px;
            display: flex;
            justify-content: center;
            gap: 15px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="logo">🛍️</div>
            <h1>E-Commerce Store</h1>
            <p class="subtitle">Premium Products at Great Prices</p>
        </header>

        <div class="status-banner">✅ Service is running successfully</div>

        <div class="cart-header">
            <h2>Featured Products</h2>
            <button class="cart-toggle" id="cartBtn">
                Open Cart
                <span class="cart-badge" id="cartBadge" style="display:none;">0</span>
            </button>
        </div>

        <div class="products-grid" id="productsGrid"></div>

        <div class="cart-overlay" id="cartOverlay"></div>
        <div class="cart-panel" id="cartPanel">
            <h2 class="cart-title">Your Cart</h2>
            <div class="cart-items" id="cartItems"></div>
            <div class="cart-total">
                <span>Total:</span>
                <span id="cartTotal">$0</span>
            </div>
            <button class="checkout-btn" id="checkoutBtn">Checkout</button>
            <button class="clear-cart-btn" id="clearCartBtn">Clear Cart</button>
            <div class="success-message" id="successMessage">✅ Order placed successfully!</div>
        </div>
    </div>

    <script>
        const products = ${JSON.stringify(products)};
        let cart = JSON.parse(localStorage.getItem('ecommerce-cart')) || [];

        function renderProducts() {
            const grid = document.getElementById('productsGrid');
            grid.innerHTML = products.map(p => \`
                <div class="product-card">
                    <div class="product-header">
                        <div class="product-icon">📦</div>
                        <div class="product-name">\${p.name}</div>
                    </div>
                    <div class="product-content">
                        <p class="product-description">\${p.description}</p>
                        <div class="product-price">$\${p.price}</div>
                        <button class="add-to-cart-btn" onclick="addToCart(\${p.id}, '\${p.name}', \${p.price})">Add to Cart</button>
                    </div>
                </div>
            \`).join('');
        }

        function addToCart(id, name, price) {
            const item = cart.find(i => i.id === id);
            if (item) {
                item.quantity++;
            } else {
                cart.push({ id, name, price, quantity: 1 });
            }
            saveCart();
            updateCart();
            showToast(\`✅ Added \${name} to cart\`);
            document.getElementById('cartPanel').classList.add('open');
            document.getElementById('cartOverlay').classList.add('open');
        }

        function updateCart() {
            const badge = document.getElementById('cartBadge');
            const total = cart.reduce((sum, item) => sum + item.quantity, 0);
            badge.textContent = total;
            badge.style.display = total > 0 ? 'flex' : 'none';

            const cartItems = document.getElementById('cartItems');
            if (cart.length === 0) {
                cartItems.innerHTML = '<div class="empty-cart">Your cart is empty</div>';
            } else {
                cartItems.innerHTML = cart.map(item => \`
                    <div class="cart-item">
                        <div class="item-details">
                            <div class="item-name">\${item.name}</div>
                            <div class="item-quantity">$\${item.price} × \${item.quantity}</div>
                            <div class="qty-controls">
                                <button class="qty-btn" onclick="updateQuantity(\${item.id}, -1)">−</button>
                                <span>\${item.quantity}</span>
                                <button class="qty-btn" onclick="updateQuantity(\${item.id}, 1)">+</button>
                            </div>
                        </div>
                        <button class="remove-btn" onclick="removeFromCart(\${item.id})">Remove</button>
                    </div>
                \`).join('');
            }

            const total = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);
            document.getElementById('cartTotal').textContent = '$' + total.toFixed(2);
        }

        function updateQuantity(id, delta) {
            const item = cart.find(i => i.id === id);
            if (item) {
                item.quantity += delta;
                if (item.quantity <= 0) removeFromCart(id);
                else { saveCart(); updateCart(); }
            }
        }

        function removeFromCart(id) {
            cart = cart.filter(i => i.id !== id);
            saveCart();
            updateCart();
            showToast('❌ Item removed from cart');
        }

        function saveCart() {
            localStorage.setItem('ecommerce-cart', JSON.stringify(cart));
        }

        function showToast(message) {
            const toast = document.createElement('div');
            toast.className = 'toast';
            toast.textContent = message;
            document.body.appendChild(toast);
            setTimeout(() => toast.remove(), 3000);
        }

        document.getElementById('cartBtn').onclick = () => {
            document.getElementById('cartPanel').classList.add('open');
            document.getElementById('cartOverlay').classList.add('open');
        };

        document.getElementById('cartOverlay').onclick = () => {
            document.getElementById('cartPanel').classList.remove('open');
            document.getElementById('cartOverlay').classList.remove('open');
        };

        document.getElementById('checkoutBtn').onclick = () => {
            if (cart.length === 0) return;
            document.getElementById('successMessage').style.display = 'block';
            showToast('🎉 Order placed successfully!');
            cart = [];
            saveCart();
            setTimeout(() => {
                document.getElementById('successMessage').style.display = 'none';
                document.getElementById('cartPanel').classList.remove('open');
                document.getElementById('cartOverlay').classList.remove('open');
                updateCart();
            }, 2000);
        };

        document.getElementById('clearCartBtn').onclick = () => {
            if (cart.length === 0) return;
            cart = [];
            saveCart();
            updateCart();
            showToast('🗑️ Cart cleared');
        };

        renderProducts();
        updateCart();
    </script>
    <footer>
        <p>Powered by Docker, MongoDB, Node.js, Nginx & Ansible</p>
        <p>ITeam University DevOps Lab 2025-2026</p>
    </footer>
</body>
</html>\`;
  res.send(html);
});

app.get('/api/products', (req, res) => {
  res.json(products);
});

app.get('/api/products/:id', (req, res) => {
  const product = products.find(p => p.id === parseInt(req.params.id));
  if (!product) return res.status(404).json({ error: 'Product not found' });
  res.json(product);
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`🚀 E-Commerce app listening on port ${PORT}`);
  console.log(`📍 Open http://localhost:${PORT} in your browser`);
});
APPFILE

# Create package.json
cat > package.json << 'PKGFILE'
{
  "name": "ecommerce-app",
  "version": "1.0.0",
  "description": "E-Commerce application",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongodb": "^5.0.0",
    "body-parser": "^1.20.2"
  }
}
PKGFILE

# Create Dockerfile
cat > Dockerfile << 'DOCKERFILE'
FROM node:18-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --production
COPY app.js .
CMD ["npm", "start"]
DOCKERFILE

# Create docker-compose.yml
cat > docker-compose.yml << 'COMPOSE'
version: '3.8'

services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - ecommerce-net

  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGO_URL=mongodb://mongodb:27017/ecommerce
    depends_on:
      - mongodb
    restart: unless-stopped
    networks:
      - ecommerce-net

  mongodb:
    image: mongo:6.0
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
    restart: unless-stopped
    networks:
      - ecommerce-net

networks:
  ecommerce-net:
    driver: bridge

volumes:
  mongo_data:
COMPOSE

# Create nginx.conf
cat > nginx.conf << 'NGINX'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    upstream nodejs_app {
        server app:3000;
    }

    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://nodejs_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_redirect off;
        }

        location ~ ^/(api|health)/ {
            proxy_pass http://nodejs_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
NGINX

echo "🐳 Starting Docker containers..."
docker-compose up -d --build

echo "⏳ Waiting for containers to be healthy..."
sleep 10

echo "📊 Checking container status..."
docker ps --format "table {{.Names}}\t{{.Status}}"

echo "✅ Deployment completed!"
echo "🌐 Application is running on http://localhost"
echo "📱 Access from browser: http://$(hostname -I | awk '{print $1}')"
