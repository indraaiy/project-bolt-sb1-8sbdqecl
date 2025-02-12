/*
  # E-commerce Database Schema

  1. New Tables
    - `products`
      - `id` (uuid, primary key)
      - `name` (text)
      - `description` (text)
      - `price` (numeric)
      - `image_url` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `product_variants`
      - `id` (uuid, primary key)
      - `product_id` (uuid, foreign key)
      - `color` (text)
      - `stock` (integer)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `orders`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key)
      - `status` (text)
      - `total_amount` (numeric)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `order_items`
      - `id` (uuid, primary key)
      - `order_id` (uuid, foreign key)
      - `product_id` (uuid, foreign key)
      - `variant_id` (uuid, foreign key)
      - `quantity` (integer)
      - `price` (numeric)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  price numeric NOT NULL CHECK (price >= 0),
  image_url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create product variants table
CREATE TABLE IF NOT EXISTS product_variants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products ON DELETE CASCADE,
  color text NOT NULL,
  stock integer NOT NULL DEFAULT 0 CHECK (stock >= 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE SET NULL,
  status text NOT NULL CHECK (status IN ('pending', 'processing', 'completed', 'cancelled')),
  total_amount numeric NOT NULL CHECK (total_amount >= 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create order items table
CREATE TABLE IF NOT EXISTS order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders ON DELETE CASCADE,
  product_id uuid REFERENCES products ON DELETE SET NULL,
  variant_id uuid REFERENCES product_variants ON DELETE SET NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  price numeric NOT NULL CHECK (price >= 0),
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Products are viewable by everyone" 
  ON products FOR SELECT 
  TO public 
  USING (true);

CREATE POLICY "Product variants are viewable by everyone" 
  ON product_variants FOR SELECT 
  TO public 
  USING (true);

CREATE POLICY "Users can view their own orders" 
  ON orders FOR SELECT 
  TO authenticated 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own orders" 
  ON orders FOR INSERT 
  TO authenticated 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their order items" 
  ON order_items FOR SELECT 
  TO authenticated 
  USING (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create order items for their orders" 
  ON order_items FOR INSERT 
  TO authenticated 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

-- Insert initial product data
DO $$ 
BEGIN
  INSERT INTO products (name, description, price, image_url) VALUES
    ('Classic Dad Cap', 'The timeless classic dad hat. Perfect for any casual occasion.', 24.99, 'https://images.unsplash.com/photo-1534215754734-18e55d13e346?auto=format&fit=crop&q=80'),
    ('Vintage Wash Cap', 'Pre-washed for that perfect worn-in look and feel.', 29.99, 'https://images.unsplash.com/photo-1556306535-0f09a537f0a3?auto=format&fit=crop&q=80'),
    ('Premium Cotton Cap', 'Made from premium cotton for ultimate comfort.', 34.99, 'https://images.unsplash.com/photo-1521369909029-2afed882baee?auto=format&fit=crop&q=80');

  -- Insert product variants for Classic Dad Cap
  INSERT INTO product_variants (product_id, color, stock)
  SELECT id, unnest(ARRAY['Black', 'Navy', 'Khaki']), 100
  FROM products WHERE name = 'Classic Dad Cap';

  -- Insert product variants for Vintage Wash Cap
  INSERT INTO product_variants (product_id, color, stock)
  SELECT id, unnest(ARRAY['Washed Blue', 'Washed Black', 'Washed Red']), 100
  FROM products WHERE name = 'Vintage Wash Cap';

  -- Insert product variants for Premium Cotton Cap
  INSERT INTO product_variants (product_id, color, stock)
  SELECT id, unnest(ARRAY['White', 'Gray', 'Olive']), 100
  FROM products WHERE name = 'Premium Cotton Cap';
END $$;