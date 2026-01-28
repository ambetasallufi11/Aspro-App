-- Users
INSERT INTO users (name,email,password,phone,role) VALUES
('Admin', 'admin@aspro.app', '$2b$10$Gs2HWv0R.PQv8esuuVPbHeJ2YLR4yclRLlBxqKIw8WhYa1h0bu0XS', '+0000000000', 'admin'),
('Merchant Owner', 'merchant@aspro.app', '$2b$10$/DLwSTPvJoQFe2r9AmIGM.4aWeBsrQuEVN4VUGdrEBGkbSukIAsl6', '+355690000000', 'merchant'),
('Alkida Isaku', 'alkida@aspro.app', '$2b$10$8yQSjNPxIywg4ELLubON9uQot.0EaWBCNON6U8jc.0glqmvYQgLca', '+355685552211', 'user');

-- Addresses
INSERT INTO addresses (user_id, address) VALUES
(3, 'Bulevardi Zogu I, Tirana'),
(3, 'Rruga Dëshmorët e 4 Shkurtit, Tirana');

-- Merchants
INSERT INTO merchants (owner_user_id, name, latitude, longitude, rating, price_range, eta, image_url, hours) VALUES
(2, 'FreshFold Laundry Co.', 41.3297, 19.8186, 4.8, '$$', 'Same day', 'assets/Merchant1.png', '09:00-19:00'),
(2, 'Sunrise Suds', 41.3239, 19.8128, 4.6, '$$', '24 hrs', 'assets/Merchant2.png', '09:00-19:00'),
(2, 'CloudClean Express', 41.3346, 19.8264, 4.9, '$$$', '8 hrs', 'assets/Merchant3.png', '09:00-19:00');

-- Services
INSERT INTO services (merchant_id, name, description, price) VALUES
(1, 'Wash & Fold', 'Everyday laundry with gentle detergent.', 18.00),
(1, 'Dry Clean', 'Professional dry cleaning for delicates.', 28.00),
(1, 'Express', 'Priority turnaround within 8 hours.', 12.00),
(1, 'Premium Care', 'Hand-finished premium garments.', 32.00),
(2, 'Wash & Fold', 'Everyday laundry with gentle detergent.', 18.00),
(2, 'Eco Wash', 'Eco-friendly wash with gentle products.', 20.00),
(3, 'Dry Clean', 'Professional dry cleaning for delicates.', 28.00),
(3, 'Steam Press', 'Steam press for crisp finish.', 15.00),
(3, 'Premium Care', 'Hand-finished premium garments.', 32.00);

-- Orders (sample)
INSERT INTO orders (user_id, merchant_id, status, total) VALUES
(3, 1, 'washing', 42.50),
(3, 2, 'ready', 32.00),
(3, 3, 'delivered', 58.00);

-- Order items (sample)
INSERT INTO order_items (order_id, service_id, qty, price) VALUES
(1, 1, 1, 18.00),
(1, 2, 1, 28.00),
(2, 1, 1, 18.00),
(2, 3, 1, 12.00),
(3, 2, 1, 28.00),
(3, 4, 1, 32.00);
