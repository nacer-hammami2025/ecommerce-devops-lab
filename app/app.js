const express = require('express');
const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URL = process.env.MONGO_URL || 'mongodb://localhost:27017/ecommerce';

app.disable('x-powered-by');
app.use(bodyParser.json());
// Sample product catalog
const PRODUCTS = [
    { id: 1, name: 'Laptop', price: 1200, description: 'High-performance laptop with latest processor and graphics' },
    { id: 2, name: 'Phone', price: 800, description: 'Latest flagship smartphone with amazing camera' },
    { id: 3, name: 'Tablet', price: 500, description: 'Portable tablet' },
    { id: 4, name: 'Smartwatch', price: 300, description: 'Feature-rich smartwatch with health monitoring' },
    { id: 5, name: 'Headphones', price: 150, description: 'Noise-cancelling headphones' }
];

let db;
let carts = {}; // In-memory cart storage (Session-based)

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
                body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; color: #1f2937; }
                .container { max-width: 1200px; margin: 0 auto; }
                header { text-align: center; color: white; margin-bottom: 28px; }
                h1 { font-size: 3em; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
                .subtitle { font-size: 1.2em; opacity: 0.9; }
                .toolbar { display: flex; justify-content: center; margin: 18px 0 24px; }
                .toolbar-actions { display: flex; gap: 12px; align-items: center; }
                .cart-button { background: rgba(255,255,255,0.18); color: white; border: 1px solid rgba(255,255,255,0.25); padding: 12px 18px; border-radius: 999px; cursor: pointer; font-size: 1em; backdrop-filter: blur(6px); }
                .cart-button:hover { background: rgba(255,255,255,0.25); }
                .cart-badge { display: inline-flex; align-items: center; justify-content: center; min-width: 28px; height: 28px; margin-left: 8px; padding: 0 8px; border-radius: 999px; background: white; color: #6d28d9; font-weight: 700; }
                .cart-info { background: rgba(0,255,0,0.18); color: #d1fae5; padding: 10px 14px; border-radius: 12px; margin-bottom: 20px; text-align: center; font-weight: bold; border: 1px solid rgba(255,255,255,0.18); }
                .products { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
                .product { background: white; border-radius: 14px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.2); transition: transform 0.3s, box-shadow 0.3s; }
                .product:hover { transform: translateY(-5px); box-shadow: 0 15px 40px rgba(0,0,0,0.3); }
                .product-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; }
                .product-name { font-size: 1.5em; font-weight: bold; margin-bottom: 5px; }
                .product-body { padding: 20px; }
                .product-description { color: #666; margin-bottom: 15px; line-height: 1.6; min-height: 52px; }
                .product-price { font-size: 2em; color: #667eea; font-weight: bold; margin-bottom: 15px; }
                .btn { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-size: 1em; transition: opacity 0.3s, transform 0.2s; }
                .btn:hover { opacity: 0.93; transform: translateY(-1px); }
                .btn-secondary { background: #e5e7eb; color: #111827; }
                .btn-danger { background: #ef4444; color: white; }
                footer { text-align: center; color: white; margin-top: 40px; padding: 20px; border-top: 1px solid rgba(255,255,255,0.2); }
                .status { background: rgba(0,255,0,0.2); color: #eaffea; padding: 10px; border-radius: 12px; margin-bottom: 20px; text-align: center; border: 1px solid rgba(255,255,255,0.16); }
                .notification { position: fixed; top: 20px; right: 20px; background: rgba(17, 24, 39, 0.95); color: white; padding: 14px 18px; border-radius: 10px; box-shadow: 0 12px 30px rgba(0,0,0,0.25); animation: slideIn 0.3s ease-out; z-index: 2000; }
                @keyframes slideIn { from { transform: translateX(400px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
                .overlay { position: fixed; inset: 0; background: rgba(15, 23, 42, 0.45); opacity: 0; pointer-events: none; transition: opacity 0.25s ease; z-index: 1500; }
                .overlay.open { opacity: 1; pointer-events: auto; }
                .cart-drawer { position: fixed; top: 0; right: 0; width: 380px; max-width: 100%; height: 100vh; background: #ffffff; box-shadow: -20px 0 50px rgba(0,0,0,0.28); transform: translateX(100%); transition: transform 0.25s ease; z-index: 1600; display: flex; flex-direction: column; }
                .cart-drawer.open { transform: translateX(0); }
                .cart-header { display: flex; justify-content: space-between; align-items: center; padding: 20px; border-bottom: 1px solid #e5e7eb; }
                .cart-header h2 { font-size: 1.4em; color: #111827; }
                .cart-close { border: none; background: #f3f4f6; color: #111827; width: 36px; height: 36px; border-radius: 50%; cursor: pointer; }
                .cart-items { padding: 10px 20px 20px; overflow-y: auto; flex: 1; }
                .cart-empty { color: #6b7280; text-align: center; padding: 36px 10px; }
                .cart-item { border: 1px solid #e5e7eb; border-radius: 12px; padding: 14px; margin-bottom: 12px; }
                .cart-item-top { display: flex; justify-content: space-between; gap: 12px; }
                .cart-item-name { font-weight: 700; color: #111827; }
                .cart-item-price { color: #667eea; font-weight: 700; }
                .cart-item-actions { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-top: 12px; }
                .qty-controls { display: inline-flex; align-items: center; gap: 8px; }
                .qty-btn { width: 32px; height: 32px; border-radius: 8px; border: 1px solid #d1d5db; background: white; cursor: pointer; }
                .qty-value { min-width: 24px; text-align: center; font-weight: 700; }
                .cart-footer { border-top: 1px solid #e5e7eb; padding: 18px 20px; background: #f9fafb; }
                .cart-total { display: flex; justify-content: space-between; align-items: center; font-size: 1.1em; margin-bottom: 14px; }
                .cart-total strong { color: #111827; }
                .cart-actions { display: flex; gap: 10px; }
                .cart-actions .btn { flex: 1; }
            </style>
        </head>
        <body>
            <div class="container">
                <header>
                    <h1>🛍️ E-Commerce Store</h1>
                    <p class="subtitle">Premium Products at Great Prices</p>
                    <div class="status">✅ Service is running successfully</div>
                </header>

                <div class="toolbar">
                    <div class="toolbar-actions">
                        <button class="cart-button" id="openCartBtn">🛒 Open Cart <span class="cart-badge" id="cartCount">0</span></button>
                    </div>
                </div>

                <div class="cart-info" id="cartSummary">Your cart is empty. Add products to start shopping.</div>
                
                <div class="products">
                    <div class="product" data-id="1" data-name="Laptop" data-price="1200" data-description="High-performance laptop with latest processor and graphics">
                        <div class="product-header">
                            <div class="product-name">💻 Laptop</div>
                        </div>
                        <div class="product-body">
                            <p class="product-description">High-performance laptop with latest processor and graphics</p>
                            <div class="product-price">$1,200</div>
                            <button class="btn add-to-cart">Add to Cart</button>
                        </div>
                    </div>
                    
                    <div class="product" data-id="2" data-name="Phone" data-price="800" data-description="Latest flagship smartphone with amazing camera">
                        <div class="product-header">
                            <div class="product-name">📱 Phone</div>
                        </div>
                        <div class="product-body">
                            <p class="product-description">Latest flagship smartphone with amazing camera</p>
                            <div class="product-price">$800</div>
                            <button class="btn add-to-cart">Add to Cart</button>
                        </div>
                    </div>
                    
                    <div class="product" data-id="4" data-name="Smartwatch" data-price="300" data-description="Feature-rich smartwatch with health monitoring">
                        <div class="product-header">
                            <div class="product-name">⌚ Smartwatch</div>
                        </div>
                        <div class="product-body">
                            <p class="product-description">Feature-rich smartwatch with health monitoring</p>
                            <div class="product-price">$300</div>
                            <button class="btn add-to-cart">Add to Cart</button>
                        </div>
                    </div>
                </div>
                
                <footer>
                    <p>Powered by Docker, MongoDB, Node.js, Nginx & Ansible</p>
                    <p>ITeam University DevOps Lab 2025-2026</p>
                </footer>
            </div>

            <div class="overlay" id="cartOverlay"></div>
            <aside class="cart-drawer" id="cartDrawer" aria-label="Shopping cart">
                <div class="cart-header">
                    <h2>🛒 Your Cart</h2>
                    <button class="cart-close" id="closeCartBtn" aria-label="Close cart">✕</button>
                </div>
                <div class="cart-items" id="cartItems"></div>
                <div class="cart-footer">
                    <div class="cart-total">
                        <span>Total</span>
                        <strong id="cartTotal">$0</strong>
                    </div>
                    <div class="cart-actions">
                        <button class="btn btn-secondary" id="clearCartBtn">Clear</button>
                        <button class="btn" id="checkoutBtn">Checkout</button>
                    </div>
                </div>
            </aside>

            <script>
                const cartCountElement = document.getElementById('cartCount');
                const cartItemsElement = document.getElementById('cartItems');
                const cartTotalElement = document.getElementById('cartTotal');
                const cartSummaryElement = document.getElementById('cartSummary');
                const cartDrawer = document.getElementById('cartDrawer');
                const cartOverlay = document.getElementById('cartOverlay');
                const openCartBtn = document.getElementById('openCartBtn');
                const closeCartBtn = document.getElementById('closeCartBtn');
                const clearCartBtn = document.getElementById('clearCartBtn');
                const checkoutBtn = document.getElementById('checkoutBtn');
                const STORAGE_KEY = 'ecommerce-cart';
                let cart = [];

                function loadCart() {
                    try {
                        const saved = localStorage.getItem(STORAGE_KEY);
                        cart = saved ? JSON.parse(saved) : [];
                    } catch (error) {
                        cart = [];
                    }
                }

                function saveCart() {
                    localStorage.setItem(STORAGE_KEY, JSON.stringify(cart));
                }

                function formatPrice(value) {
                    return '$' + Number(value).toLocaleString('en-US');
                }

                function getCartCount() {
                    return cart.reduce((sum, item) => sum + item.quantity, 0);
                }

                function getCartTotal() {
                    return cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
                }

                function updateCartCount() {
                    cartCountElement.textContent = getCartCount();
                }

                function updateCartSummary() {
                    const count = getCartCount();
                    if (count === 0) {
                        cartSummaryElement.textContent = 'Your cart is empty. Add products to start shopping.';
                    } else {
                        cartSummaryElement.textContent = count + ' item(s) in your cart. Total: ' + formatPrice(getCartTotal());
                    }
                }

                function showNotification(message) {
                    const notif = document.createElement('div');
                    notif.className = 'notification';
                    notif.textContent = message;
                    document.body.appendChild(notif);
                    setTimeout(() => notif.remove(), 2200);
                }

                function openCart() {
                    cartDrawer.classList.add('open');
                    cartOverlay.classList.add('open');
                }

                function closeCart() {
                    cartDrawer.classList.remove('open');
                    cartOverlay.classList.remove('open');
                }

                function addToCart(product) {
                    const existing = cart.find(item => item.id === product.id);
                    if (existing) {
                        existing.quantity += 1;
                    } else {
                        cart.push({
                            id: product.id,
                            name: product.name,
                            price: product.price,
                            description: product.description,
                            quantity: 1
                        });
                    }
                    saveCart();
                    renderCart();
                    showNotification('✅ ' + product.name + ' added to cart');
                }

                function increaseQuantity(id) {
                    const item = cart.find(entry => entry.id === id);
                    if (item) {
                        item.quantity += 1;
                        saveCart();
                        renderCart();
                    }
                }

                function decreaseQuantity(id) {
                    const item = cart.find(entry => entry.id === id);
                    if (!item) {
                        return;
                    }

                    item.quantity -= 1;
                    if (item.quantity <= 0) {
                        cart = cart.filter(entry => entry.id !== id);
                    }

                    saveCart();
                    renderCart();
                }

                function removeItem(id) {
                    cart = cart.filter(item => item.id !== id);
                    saveCart();
                    renderCart();
                    showNotification('Item removed from cart');
                }

                function clearCart() {
                    cart = [];
                    saveCart();
                    renderCart();
                    showNotification('Cart cleared');
                }

                function renderCart() {
                    updateCartCount();
                    updateCartSummary();

                    if (cart.length === 0) {
                        cartItemsElement.innerHTML = '<div class="cart-empty">No products in your cart yet.</div>';
                        cartTotalElement.textContent = formatPrice(0);
                        return;
                    }

                    cartTotalElement.textContent = formatPrice(getCartTotal());
                    cartItemsElement.innerHTML = cart.map(item => {
                        return '<div class="cart-item">' +
                            '<div class="cart-item-top">' +
                                '<div>' +
                                    '<div class="cart-item-name">' + item.name + '</div>' +
                                    '<div style="color:#6b7280; font-size:0.92em; margin-top:4px;">' + item.description + '</div>' +
                                '</div>' +
                                '<div class="cart-item-price">' + formatPrice(item.price * item.quantity) + '</div>' +
                            '</div>' +
                            '<div class="cart-item-actions">' +
                                '<div class="qty-controls">' +
                                    '<button class="qty-btn" data-action="decrease" data-id="' + item.id + '">-</button>' +
                                    '<span class="qty-value">' + item.quantity + '</span>' +
                                    '<button class="qty-btn" data-action="increase" data-id="' + item.id + '">+</button>' +
                                '</div>' +
                                '<button class="btn btn-danger" data-action="remove" data-id="' + item.id + '">Remove</button>' +
                            '</div>' +
                        '</div>';
                    }).join('');

                    cartItemsElement.querySelectorAll('[data-action]').forEach(button => {
                        button.addEventListener('click', function () {
                            const action = this.dataset.action;
                            const id = parseInt(this.dataset.id, 10);

                            if (action === 'increase') {
                                increaseQuantity(id);
                            } else if (action === 'decrease') {
                                decreaseQuantity(id);
                            } else if (action === 'remove') {
                                removeItem(id);
                            }
                        });
                    });
                }

                document.querySelectorAll('.add-to-cart').forEach(button => {
                    button.addEventListener('click', function () {
                        const product = this.closest('.product');
                        addToCart({
                            id: parseInt(product.dataset.id, 10),
                            name: product.dataset.name,
                            price: parseFloat(product.dataset.price),
                            description: product.dataset.description
                        });
                    });
                });

                openCartBtn.addEventListener('click', openCart);
                closeCartBtn.addEventListener('click', closeCart);
                cartOverlay.addEventListener('click', closeCart);
                clearCartBtn.addEventListener('click', clearCart);
                checkoutBtn.addEventListener('click', function () {
                    if (cart.length === 0) {
                        showNotification('Your cart is empty');
                        return;
                    }

                    showNotification('✅ Order placed successfully');
                    clearCart();
                    closeCart();
                });

                loadCart();
                renderCart();
            </script>
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
    const product = PRODUCTS.find(p => p.id === Number.parseInt(req.params.id, 10));
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
