import React, { useState } from 'react';
import { ShoppingCart, X } from 'lucide-react';
import { useCart } from '../context/CartContext';
import { Checkout } from './Checkout';

export const Cart: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [showCheckout, setShowCheckout] = useState(false);
  const { state, dispatch } = useCart();

  const updateQuantity = (id: string, quantity: number) => {
    if (quantity < 1) return;
    dispatch({ type: 'UPDATE_QUANTITY', payload: { id, quantity } });
  };

  const removeItem = (id: string) => {
    dispatch({ type: 'REMOVE_FROM_CART', payload: id });
  };

  if (showCheckout) {
    return <Checkout onClose={() => setShowCheckout(false)} />;
  }

  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="fixed top-4 right-4 bg-blue-600 text-white p-2 rounded-full hover:bg-blue-700 transition-colors"
      >
        <ShoppingCart className="h-6 w-6" />
        {state.items.length > 0 && (
          <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
            {state.items.length}
          </span>
        )}
      </button>

      {isOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 z-50">
          <div className="fixed right-0 top-0 h-full w-96 bg-white shadow-lg">
            <div className="p-4 flex justify-between items-center border-b">
              <h2 className="text-xl font-semibold">Shopping Cart</h2>
              <button onClick={() => setIsOpen(false)}>
                <X className="h-6 w-6" />
              </button>
            </div>

            <div className="p-4 space-y-4 overflow-y-auto" style={{ maxHeight: 'calc(100vh - 180px)' }}>
              {state.items.length === 0 ? (
                <p className="text-gray-500 text-center">Your cart is empty</p>
              ) : (
                state.items.map((item) => (
                  <div key={`${item.id}-${item.selectedColor}`} className="flex items-center space-x-4 border-b pb-4">
                    <img src={item.image} alt={item.name} className="w-20 h-20 object-cover rounded" />
                    <div className="flex-1">
                      <h3 className="font-semibold">{item.name}</h3>
                      <p className="text-sm text-gray-600">Color: {item.selectedColor}</p>
                      <div className="flex items-center mt-2">
                        <button
                          onClick={() => updateQuantity(item.id, item.quantity - 1)}
                          className="px-2 py-1 border rounded"
                        >
                          -
                        </button>
                        <span className="mx-2">{item.quantity}</span>
                        <button
                          onClick={() => updateQuantity(item.id, item.quantity + 1)}
                          className="px-2 py-1 border rounded"
                        >
                          +
                        </button>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="font-semibold">${(item.price * item.quantity).toFixed(2)}</p>
                      <button
                        onClick={() => removeItem(item.id)}
                        className="text-red-500 text-sm mt-2"
                      >
                        Remove
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>

            {state.items.length > 0 && (
              <div className="border-t p-4 bg-gray-50">
                <div className="flex justify-between items-center mb-4">
                  <span className="font-semibold">Total:</span>
                  <span className="text-xl font-bold">${state.total.toFixed(2)}</span>
                </div>
                <button
                  onClick={() => {
                    setIsOpen(false);
                    setShowCheckout(true);
                  }}
                  className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 transition-colors"
                >
                  Proceed to Checkout
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </>
  );
};