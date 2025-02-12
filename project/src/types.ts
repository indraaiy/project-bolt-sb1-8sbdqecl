export interface Product {
  id: string;
  name: string;
  price: number;
  image: string;
  description: string;
  colors: string[];
}

export interface CartItem extends Product {
  quantity: number;
  selectedColor: string;
}