import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';

const CartContext = createContext(null);
const STORAGE_KEY = 'negosud_cart';

export function CartProvider({ children }) {
  const [items, setItems] = useState(() => {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      return stored ? JSON.parse(stored) : [];
    } catch {
      return [];
    }
  });
  const [drawerOpen, setDrawerOpen] = useState(false);

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
  }, [items]);

  const addItem = useCallback((article, quantite = 1) => {
    setItems((prev) => {
      const existing = prev.find((i) => i.article.id === article.id);
      if (existing) {
        return prev.map((i) =>
          i.article.id === article.id
            ? { ...i, quantite: i.quantite + quantite }
            : i
        );
      }
      return [...prev, { article, quantite }];
    });
    setDrawerOpen(true);
  }, []);

  const removeItem = useCallback((articleId) => {
    setItems((prev) => prev.filter((i) => i.article.id !== articleId));
  }, []);

  const updateQty = useCallback((articleId, quantite) => {
    if (quantite <= 0) {
      setItems((prev) => prev.filter((i) => i.article.id !== articleId));
    } else {
      setItems((prev) =>
        prev.map((i) => (i.article.id === articleId ? { ...i, quantite } : i))
      );
    }
  }, []);

  const clearCart = useCallback(() => setItems([]), []);

  const cartCount = items.reduce((acc, i) => acc + i.quantite, 0);
  const cartTotal = items.reduce(
    (acc, i) => acc + Number(i.article.prixUnitaire) * i.quantite,
    0
  );

  return (
    <CartContext.Provider
      value={{
        items,
        addItem,
        removeItem,
        updateQty,
        clearCart,
        cartCount,
        cartTotal,
        drawerOpen,
        setDrawerOpen,
      }}
    >
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  const ctx = useContext(CartContext);
  if (!ctx) throw new Error('useCart doit être utilisé dans CartProvider');
  return ctx;
}
