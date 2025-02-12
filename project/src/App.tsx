import React from 'react';
import { CartProvider } from './context/CartContext';
import { ProductCard } from './components/ProductCard';
import { Cart } from './components/Cart';
import { ShoppingBag } from 'lucide-react';
import { products } from './data/products';

function App() {
  return (
    <CartProvider>
      <div className="min-h-screen bg-gray-100">
        <header className="bg-white shadow-sm">
          <div className="max-w-7xl mx-auto px-4 py-6">
            <div className="flex items-center">
              <ShoppingBag className="h-8 w-8 text-blue-600" />
              <h1 className="ml-2 text-3xl font-bold text-gray-900">Pretttt met die petttt</h1>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 py-8">
          <h2 className="text-2xl font-semibold mb-6">Onze collectie</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {products.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        </main>

        <Cart />
      </div>
    </CartProvider>
  );
}

export default App;