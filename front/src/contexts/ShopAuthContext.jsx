import React, { createContext, useContext, useState } from 'react';

const ShopAuthContext = createContext(null);

export function ShopAuthProvider({ children }) {
  const [shopClient, setShopClient] = useState(() => {
    try {
      const stored = sessionStorage.getItem('negosud_shop_client');
      return stored ? JSON.parse(stored) : null;
    } catch {
      return null;
    }
  });

  const loginShop = (client) => {
    sessionStorage.setItem('negosud_shop_client', JSON.stringify(client));
    setShopClient(client);
  };

  const logoutShop = () => {
    sessionStorage.removeItem('negosud_shop_client');
    setShopClient(null);
  };

  return (
    <ShopAuthContext.Provider value={{ shopClient, loginShop, logoutShop }}>
      {children}
    </ShopAuthContext.Provider>
  );
}

export function useShopAuth() {
  const ctx = useContext(ShopAuthContext);
  if (!ctx) throw new Error('useShopAuth doit être utilisé dans ShopAuthProvider');
  return ctx;
}
