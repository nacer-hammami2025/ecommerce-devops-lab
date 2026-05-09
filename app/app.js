const express = require('express');
const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URL = process.env.MONGO_URL || 'mongodb://localhost:27017/ecommerce';

app.use(bodyParser.json());

// Sample product catalog
const PRODUCTS = [
    { id: 1, name: 'Laptop', price: 1200, description: 'High-performance laptop' },
    { id: 2, name: 'Phone', price: 800, description: 'Latest smartphone' },
    { id: 3, name: 'Tablet', price: 500, description: 'Portable tablet' },
    { id: 4, name: 'Smartwatch', price: 300, description: 'Feature-rich smartwatch' },
    { id: 5, name: 'Headphones', price: 150, description: 'Noise-cancelling headphones' }
];

let db;

// Connect to MongoDB
MongoClient.connect(MONGO_URL, { useUnifiedTopology: true }, (err, client) => {
    if (err) {
        console.error('MongoDB connection error:', err);
    } else {
        db = client.db('ecommerce');
        console.log('Connected to MongoDB');
    }
});

// Root route - HTML page
app.get('/', (req, res) => {
    res.setHeader('Content-Type', 'text/html');
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>E-Commerce Store</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; }
                .container { max-width: 1200px; margin: 0 auto; }
                header { text-align: center; color: white; margin-bottom: 40px; }
                h1 { font-size: 3em; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
                .subtitle { font-size: 1.2em; opacity: 0.9; }
                .products { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
                .product { background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.2); transition: transform 0.3s, box-shadow 0.3s; }
                .product:hover { transform: translateY(-5px); box-shadow: 0 15px 40px rgba(0,0,0,0.3); }
                .product-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; }
                .product-name { font-size: 1.5em; font-weight: bold; margin-bottom: 5px; }
                .product-body { padding: 20px; }
                .product-description { color: #666; margin-bottom: 15px; line-height: 1.6; }
                .product-price { font-size: 2em; color: #667eea; font-weight: bold; margin-bottom: 15px; }
                .btn { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; font-size: 1em; transition: opacity 0.3s; }
                .btn:hover { opacity: 0.9; }
                footer { text-align: center; color: white; margin-top: 40px; padding: 20px; border-top: 1px solid rgba(255,255,255,0.2); }
                .status { background: rgba(0,255,0,0.2); color: #0f0; padding: 10px; border-radius: 5px; margin-bottom: 20px; text-align: center; }
            </style>
        </head>
        <body>
            <div class="container">
                <header>
                    <h1>🛍️ E-Commerce Store</h1>
                    <p class="subtitle">Premium Products at Great Prices</p>
                    <div class="status">✅ Service is running successfully</div>
                </header>
                
                <div class="products">
                    <div class="product">
                        <div class="product-header">
                            <div class="product-name">💻 Laptop</div>
                        </div>
                        <div class="product-body">
                            <p class="product-description">High-performance laptop with latest processor and graphics</p>
                            <div class="product-price">$1,200</div>
                            <button class="btn">Add to Cart</button>
                        </div>
                    </div>
                    
                    <div class="product">
                        <div class="product-header">
                            <div class="product-name">📱 Phone</div>
                        </div>
                        <div class="product-body">
                            <p class="product-description">Latest flagship smartphone with amazing camera</p>
                            <div class="product-price">$800</div>
                            <button class="btn">Add to Cart</button>
                        </div>
                    </div>
                    
                    <div class="product">
                        <div class="product-header">
                            <div class="product-name">⌚ Smartwatch</div>
                        </div>
                        <div class="product-body">
                            <p class="product-description">Feature-rich smartwatch with health monitoring</p>
                            <div class="product-price">$300</div>
                            <button class="btn">Add to Cart</button>
                        </div>
                    </div>
                </div>
                
                <footer>
                    <p>Powered by Docker, MongoDB, Node.js, Nginx & Ansible</p>
                    <p>ITeam University DevOps Lab 2025-2026</p>
                </footer>
            </div>
        </body>
        </html>
    `);
});

// API endpoint - Get products
app.get('/api/products', (req, res) => {
    res.json(PRODUCTS);
});

// API endpoint - Get single product
app.get('/api/products/:id', (req, res) => {
    const product = PRODUCTS.find(p => p.id === parseInt(req.params.id));
    if (product) {
        res.json(product);
    } else {
        res.status(404).json({ error: 'Product not found' });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`E-Commerce API running on port ${PORT}`);
});
