-- E-commerce Shoe Store Database Schema for MCP Tutorial
-- This database represents an athletic shoe retailer with both online and retail store presence

-- Create the database (uncomment if needed)
-- CREATE DATABASE shoe_store_analytics;

-- Connect to the database
-- \c shoe_store_analytics;

-- Create customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    preferred_channel VARCHAR(20) DEFAULT 'online' CHECK (preferred_channel IN ('online', 'retail')),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10)
);

-- Create products table for better normalization
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR(20) UNIQUE NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    product_description TEXT,
    brand VARCHAR(50),
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    created_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Create retail stores table
CREATE TABLE retail_stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    phone VARCHAR(20),
    manager_name VARCHAR(100)
);

-- Create orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    purchase_location VARCHAR(20) NOT NULL CHECK (purchase_location IN ('online', 'retail')),
    store_id INTEGER REFERENCES retail_stores(store_id), -- NULL for online orders
    order_status VARCHAR(20) DEFAULT 'completed' CHECK (order_status IN ('pending', 'completed', 'cancelled', 'returned'))
);

-- Insert sample retail stores
INSERT INTO retail_stores (store_name, address, city, state, zip_code, phone, manager_name) VALUES
('Athletic Footwear Downtown', '123 Main St', 'New York', 'NY', '10001', '555-0101', 'Sarah Johnson'),
('SportShoes Mall Plaza', '456 Oak Ave', 'Los Angeles', 'CA', '90210', '555-0102', 'Mike Chen'),
('RunFast Sports Center', '789 Pine Rd', 'Chicago', 'IL', '60601', '555-0103', 'Jessica Williams'),
('ProStep Athletics', '321 Elm St', 'Houston', 'TX', '77001', '555-0104', 'David Rodriguez'),
('Marathon Gear Store', '654 Maple Dr', 'Phoenix', 'AZ', '85001', '555-0105', 'Emily Davis');

-- Insert sample products (athletic shoes)
INSERT INTO products (sku, product_name, product_description, brand, category, price) VALUES
('NK-AIR-001', 'Nike Air Max 270', 'Lightweight running shoe with Air Max cushioning technology', 'Nike', 'Running', 130.00),
('AD-UB-002', 'Adidas Ultraboost 22', 'Energy-returning running shoe with Boost midsole', 'Adidas', 'Running', 180.00),
('NK-REV-003', 'Nike Revolution 6', 'Comfortable everyday running shoe for beginners', 'Nike', 'Running', 70.00),
('AD-GAZ-004', 'Adidas Gazelle', 'Classic suede sneaker perfect for casual wear', 'Adidas', 'Casual', 80.00),
('NK-AF1-005', 'Nike Air Force 1', 'Iconic basketball shoe with timeless style', 'Nike', 'Basketball', 90.00),
('PU-RS-006', 'Puma RS-X', 'Retro-inspired running shoe with bold design', 'Puma', 'Running', 110.00),
('AD-ST-007', 'Adidas Stan Smith', 'Minimalist tennis shoe with clean design', 'Adidas', 'Tennis', 75.00),
('NK-ZM-008', 'Nike Zoom Pegasus 39', 'Responsive running shoe for daily training', 'Nike', 'Running', 130.00),
('NB-990-009', 'New Balance 990v5', 'Premium running shoe made in USA', 'New Balance', 'Running', 175.00),
('AS-CT-010', 'Converse Chuck Taylor All Star', 'Classic canvas sneaker for casual wear', 'Converse', 'Casual', 55.00),
('VN-OLD-011', 'Vans Old Skool', 'Iconic skate shoe with side stripe', 'Vans', 'Skateboarding', 65.00),
('AD-NMD-012', 'Adidas NMD R1', 'Modern lifestyle shoe with Boost cushioning', 'Adidas', 'Lifestyle', 140.00),
('NK-DK-013', 'Nike Dunk Low', 'Vintage basketball shoe with modern appeal', 'Nike', 'Basketball', 100.00),
('PU-SUE-014', 'Puma Suede Classic', 'Timeless suede sneaker with athletic heritage', 'Puma', 'Casual', 70.00),
('RB-CL-015', 'Reebok Classic Leather', 'Vintage running shoe with premium leather', 'Reebok', 'Casual', 75.00),
('NK-BLZ-016', 'Nike Blazer Mid 77', 'Retro basketball shoe with vintage styling', 'Nike', 'Basketball', 100.00),
('AD-SUP-017', 'Adidas Superstar', 'Shell-toe basketball shoe turned lifestyle icon', 'Adidas', 'Lifestyle', 85.00),
('NB-550-018', 'New Balance 550', 'Basketball-inspired lifestyle shoe', 'New Balance', 'Basketball', 110.00),
('AS-RUN-019', 'ASICS Gel-Kayano 29', 'Stability running shoe with gel cushioning', 'ASICS', 'Running', 160.00),
('BR-GH-020', 'Brooks Ghost 15', 'Neutral running shoe with smooth ride', 'Brooks', 'Running', 140.00);

-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, registration_date, preferred_channel, city, state, zip_code) VALUES
('John', 'Smith', 'john.smith@email.com', '555-1001', '1985-03-15', '2023-01-15', 'online', 'New York', 'NY', '10001'),
('Sarah', 'Johnson', 'sarah.johnson@email.com', '555-1002', '1990-07-22', '2023-02-01', 'retail', 'Los Angeles', 'CA', '90210'),
('Michael', 'Brown', 'michael.brown@email.com', '555-1003', '1988-11-08', '2023-01-20', 'online', 'Chicago', 'IL', '60601'),
('Emily', 'Davis', 'emily.davis@email.com', '555-1004', '1992-05-12', '2023-03-10', 'retail', 'Houston', 'TX', '77001'),
('David', 'Wilson', 'david.wilson@email.com', '555-1005', '1987-09-30', '2023-02-15', 'online', 'Phoenix', 'AZ', '85001'),
('Lisa', 'Anderson', 'lisa.anderson@email.com', '555-1006', '1991-12-05', '2023-04-01', 'retail', 'Philadelphia', 'PA', '19101'),
('James', 'Taylor', 'james.taylor@email.com', '555-1007', '1989-04-18', '2023-03-20', 'online', 'San Antonio', 'TX', '78201'),
('Jennifer', 'Martinez', 'jennifer.martinez@email.com', '555-1008', '1993-08-25', '2023-05-15', 'retail', 'San Diego', 'CA', '92101'),
('Robert', 'Garcia', 'robert.garcia@email.com', '555-1009', '1986-01-10', '2023-02-28', 'online', 'Dallas', 'TX', '75201'),
('Jessica', 'Rodriguez', 'jessica.rodriguez@email.com', '555-1010', '1994-06-14', '2023-04-20', 'retail', 'San Jose', 'CA', '95101'),
('Christopher', 'Lopez', 'christopher.lopez@email.com', '555-1011', '1990-10-03', '2023-03-05', 'online', 'Austin', 'TX', '73301'),
('Amanda', 'Hernandez', 'amanda.hernandez@email.com', '555-1012', '1992-02-28', '2023-05-01', 'retail', 'Jacksonville', 'FL', '32099'),
('Matthew', 'Lee', 'matthew.lee@email.com', '555-1013', '1988-07-16', '2023-01-30', 'online', 'San Francisco', 'CA', '94101'),
('Ashley', 'Gonzalez', 'ashley.gonzalez@email.com', '555-1014', '1991-11-20', '2023-04-10', 'retail', 'Columbus', 'OH', '43085'),
('Joshua', 'Perez', 'joshua.perez@email.com', '555-1015', '1987-05-07', '2023-02-20', 'online', 'Charlotte', 'NC', '28105'),
('Megan', 'Turner', 'megan.turner@email.com', '555-1016', '1993-09-12', '2023-05-30', 'retail', 'Seattle', 'WA', '98101'),
('Daniel', 'Phillips', 'daniel.phillips@email.com', '555-1017', '1989-12-25', '2023-03-15', 'online', 'Denver', 'CO', '80014'),
('Brittany', 'Campbell', 'brittany.campbell@email.com', '555-1018', '1990-03-08', '2023-04-25', 'retail', 'Boston', 'MA', '02101'),
('Andrew', 'Parker', 'andrew.parker@email.com', '555-1019', '1986-08-19', '2023-02-10', 'online', 'El Paso', 'TX', '79901'),
('Stephanie', 'Evans', 'stephanie.evans@email.com', '555-1020', '1992-04-02', '2023-05-20', 'retail', 'Nashville', 'TN', '37201'),
('Kevin', 'Edwards', 'kevin.edwards@email.com', '555-1021', '1988-10-15', '2023-01-25', 'online', 'Baltimore', 'MD', '21201'),
('Rachel', 'Collins', 'rachel.collins@email.com', '555-1022', '1991-01-30', '2023-04-15', 'retail', 'Louisville', 'KY', '40201'),
('Brian', 'Stewart', 'brian.stewart@email.com', '555-1023', '1987-06-24', '2023-03-01', 'online', 'Portland', 'OR', '97201'),
('Nicole', 'Sanchez', 'nicole.sanchez@email.com', '555-1024', '1994-11-11', '2023-05-10', 'retail', 'Oklahoma City', 'OK', '73101'),
('Justin', 'Morris', 'justin.morris@email.com', '555-1025', '1989-02-14', '2023-02-25', 'online', 'Las Vegas', 'NV', '89101'),
('Samantha', 'Rogers', 'samantha.rogers@email.com', '555-1026', '1993-07-29', '2023-04-30', 'retail', 'Albuquerque', 'NM', '87101'),
('Tyler', 'Reed', 'tyler.reed@email.com', '555-1027', '1990-12-17', '2023-03-20', 'online', 'Tucson', 'AZ', '85701'),
('Kayla', 'Cook', 'kayla.cook@email.com', '555-1028', '1992-05-03', '2023-05-25', 'retail', 'Atlanta', 'GA', '30301'),
('Nathan', 'Bailey', 'nathan.bailey@email.com', '555-1029', '1986-09-26', '2023-01-10', 'online', 'Virginia Beach', 'VA', '23451'),
('Tiffany', 'Rivera', 'tiffany.rivera@email.com', '555-1030', '1991-03-21', '2023-04-05', 'retail', 'Omaha', 'NE', '68101'),
('Zachary', 'Cooper', 'zachary.cooper@email.com', '555-1031', '1988-08-13', '2023-02-15', 'online', 'Miami', 'FL', '33101'),
('Alexis', 'Richardson', 'alexis.richardson@email.com', '555-1032', '1990-04-06', '2023-03-30', 'retail', 'Oakland', 'CA', '94601'),
('Brandon', 'Cox', 'brandon.cox@email.com', '555-1033', '1987-11-18', '2023-01-05', 'online', 'Minneapolis', 'MN', '55401'),
('Danielle', 'Ward', 'danielle.ward@email.com', '555-1034', '1993-06-09', '2023-05-15', 'retail', 'Tulsa', 'OK', '74101'),
('Aaron', 'Torres', 'aaron.torres@email.com', '555-1035', '1989-01-22', '2023-02-20', 'online', 'Arlington', 'TX', '76001'),
('Courtney', 'Peterson', 'courtney.peterson@email.com', '555-1036', '1992-10-04', '2023-04-20', 'retail', 'New Orleans', 'LA', '70112'),
('Jordan', 'Gray', 'jordan.gray@email.com', '555-1037', '1986-12-31', '2023-03-10', 'online', 'Wichita', 'KS', '67201'),
('Vanessa', 'Ramirez', 'vanessa.ramirez@email.com', '555-1038', '1994-05-27', '2023-05-05', 'retail', 'Cleveland', 'OH', '44101'),
('Jeremy', 'James', 'jeremy.james@email.com', '555-1039', '1991-07-15', '2023-02-28', 'online', 'Tampa', 'FL', '33601'),
('Kimberly', 'Watson', 'kimberly.watson@email.com', '555-1040', '1988-03-11', '2023-04-12', 'retail', 'Bakersfield', 'CA', '93301'),
('Sean', 'Brooks', 'sean.brooks@email.com', '555-1041', '1990-09-07', '2023-01-20', 'online', 'Aurora', 'CO', '80010'),
('Michelle', 'Kelly', 'michelle.kelly@email.com', '555-1042', '1992-11-23', '2023-03-25', 'retail', 'Anaheim', 'CA', '92801'),
('Derek', 'Sanders', 'derek.sanders@email.com', '555-1043', '1987-04-16', '2023-02-08', 'online', 'Santa Ana', 'CA', '92701'),
('Crystal', 'Price', 'crystal.price@email.com', '555-1044', '1993-08-01', '2023-05-18', 'retail', 'St. Louis', 'MO', '63101'),
('Marcus', 'Bennett', 'marcus.bennett@email.com', '555-1045', '1989-12-08', '2023-03-02', 'online', 'Riverside', 'CA', '92501'),
('Amber', 'Wood', 'amber.wood@email.com', '555-1046', '1991-02-19', '2023-04-28', 'retail', 'Corpus Christi', 'TX', '78401'),
('Travis', 'Barnes', 'travis.barnes@email.com', '555-1047', '1986-06-12', '2023-01-15', 'online', 'Lexington', 'KY', '40501'),
('Heather', 'Ross', 'heather.ross@email.com', '555-1048', '1994-10-25', '2023-05-08', 'retail', 'Pittsburgh', 'PA', '15201'),
('Adam', 'Henderson', 'adam.henderson@email.com', '555-1049', '1988-01-07', '2023-02-18', 'online', 'Anchorage', 'AK', '99501'),
('Julie', 'Coleman', 'julie.coleman@email.com', '555-1050', '1990-05-20', '2023-04-03', 'retail', 'Stockton', 'CA', '95201'),
('Eric', 'Jenkins', 'eric.jenkins@email.com', '555-1051', '1987-09-14', '2023-03-12', 'online', 'Cincinnati', 'OH', '45201'),
('Monica', 'Perry', 'monica.perry@email.com', '555-1052', '1992-07-08', '2023-05-22', 'retail', 'St. Paul', 'MN', '55101'),
('Ryan', 'Powell', 'ryan.powell@email.com', '555-1053', '1989-11-02', '2023-02-05', 'online', 'Toledo', 'OH', '43601'),
('Laura', 'Long', 'laura.long@email.com', '555-1054', '1993-03-28', '2023-04-18', 'retail', 'Newark', 'NJ', '07101'),
('Keith', 'Hughes', 'keith.hughes@email.com', '555-1055', '1986-08-21', '2023-01-28', 'online', 'Greensboro', 'NC', '27401'),
('Erica', 'Flores', 'erica.flores@email.com', '555-1056', '1991-04-14', '2023-03-08', 'retail', 'Plano', 'TX', '75023'),
('Carl', 'Washington', 'carl.washington@email.com', '555-1057', '1988-12-18', '2023-02-12', 'online', 'Henderson', 'NV', '89002'),
('Melanie', 'Butler', 'melanie.butler@email.com', '555-1058', '1990-06-05', '2023-04-22', 'retail', 'Lincoln', 'NE', '68501'),
('Victor', 'Simmons', 'victor.simmons@email.com', '555-1059', '1987-10-09', '2023-01-12', 'online', 'Buffalo', 'NY', '14201'),
('Allison', 'Foster', 'allison.foster@email.com', '555-1060', '1994-01-16', '2023-05-12', 'retail', 'Jersey City', 'NJ', '07302'),
('Stephen', 'Gonzales', 'stephen.gonzales@email.com', '555-1061', '1992-08-29', '2023-03-18', 'online', 'Chula Vista', 'CA', '91910'),
('Jacqueline', 'Bryant', 'jacqueline.bryant@email.com', '555-1062', '1989-05-13', '2023-02-22', 'retail', 'Orlando', 'FL', '32801'),
('Patrick', 'Alexander', 'patrick.alexander@email.com', '555-1063', '1986-11-26', '2023-04-08', 'online', 'Norfolk', 'VA', '23501'),
('Diana', 'Russell', 'diana.russell@email.com', '555-1064', '1993-02-17', '2023-05-28', 'retail', 'Chandler', 'AZ', '85224'),
('Wayne', 'Griffin', 'wayne.griffin@email.com', '555-1065', '1990-07-04', '2023-01-22', 'online', 'Laredo', 'TX', '78040'),
('Cheryl', 'Diaz', 'cheryl.diaz@email.com', '555-1066', '1988-09-11', '2023-03-28', 'retail', 'Madison', 'WI', '53701'),
('Gary', 'Hayes', 'gary.hayes@email.com', '555-1067', '1991-12-24', '2023-02-14', 'online', 'Lubbock', 'TX', '79401'),
('Sharon', 'Myers', 'sharon.myers@email.com', '555-1068', '1987-03-19', '2023-04-26', 'retail', 'Winston-Salem', 'NC', '27101'),
('Jose', 'Ford', 'jose.ford@email.com', '555-1069', '1994-06-07', '2023-05-14', 'online', 'Garland', 'TX', '75040'),
('Donna', 'Hamilton', 'donna.hamilton@email.com', '555-1070', '1992-10-12', '2023-03-06', 'retail', 'Glendale', 'AZ', '85301'),
('Harold', 'Graham', 'harold.graham@email.com', '555-1071', '1989-01-25', '2023-02-26', 'online', 'Hialeah', 'FL', '33010'),
('Janet', 'Sullivan', 'janet.sullivan@email.com', '555-1072', '1986-04-30', '2023-04-16', 'retail', 'Virginia Beach', 'VA', '23451'),
('Frank', 'Wallace', 'frank.wallace@email.com', '555-1073', '1993-08-17', '2023-01-18', 'online', 'Raleigh', 'NC', '27601'),
('Carolyn', 'Woods', 'carolyn.woods@email.com', '555-1074', '1990-11-14', '2023-05-02', 'retail', 'Chesapeake', 'VA', '23320'),
('Willie', 'Cole', 'willie.cole@email.com', '555-1075', '1988-05-08', '2023-03-14', 'online', 'Irving', 'TX', '75014'),
('Marie', 'West', 'marie.west@email.com', '555-1076', '1991-07-21', '2023-04-29', 'retail', 'Scottsdale', 'AZ', '85251'),
('Eugene', 'Jordan', 'eugene.jordan@email.com', '555-1077', '1987-12-06', '2023-02-16', 'online', 'North Las Vegas', 'NV', '89030'),
('Teresa', 'Owens', 'teresa.owens@email.com', '555-1078', '1994-09-23', '2023-05-26', 'retail', 'Richmond', 'VA', '23218'),
('Albert', 'Reynolds', 'albert.reynolds@email.com', '555-1079', '1992-02-09', '2023-01-30', 'online', 'Birmingham', 'AL', '35203'),
('Catherine', 'Fisher', 'catherine.fisher@email.com', '555-1080', '1989-06-16', '2023-03-22', 'retail', 'Spokane', 'WA', '99201'),
('Louis', 'Ellis', 'louis.ellis@email.com', '555-1081', '1986-10-01', '2023-02-08', 'online', 'Rochester', 'NY', '14603'),
('Beverly', 'Harrison', 'beverly.harrison@email.com', '555-1082', '1993-04-24', '2023-04-14', 'retail', 'Des Moines', 'IA', '50309'),
('Arthur', 'Gibson', 'arthur.gibson@email.com', '555-1083', '1990-08-18', '2023-01-26', 'online', 'Modesto', 'CA', '95354'),
('Christine', 'Mcdonald', 'christine.mcdonald@email.com', '555-1084', '1988-11-05', '2023-05-20', 'retail', 'Tacoma', 'WA', '98402'),
('Henry', 'Cruz', 'henry.cruz@email.com', '555-1085', '1991-01-12', '2023-03-16', 'online', 'Fontana', 'CA', '92335'),
('Deborah', 'Marshall', 'deborah.marshall@email.com', '555-1086', '1987-05-28', '2023-02-24', 'retail', 'Santa Clarita', 'CA', '91321'),
('Lawrence', 'Ortiz', 'lawrence.ortiz@email.com', '555-1087', '1994-12-15', '2023-04-06', 'online', 'Sioux Falls', 'SD', '57104'),
('Joyce', 'Gomez', 'joyce.gomez@email.com', '555-1088', '1992-07-03', '2023-05-18', 'retail', 'Knoxville', 'TN', '37902'),
('Ralph', 'Murray', 'ralph.murray@email.com', '555-1089', '1989-03-20', '2023-01-14', 'online', 'Montgomery', 'AL', '36104'),
('Diane', 'Freeman', 'diane.freeman@email.com', '555-1090', '1986-09-07', '2023-03-26', 'retail', 'Shreveport', 'LA', '71101'),
('Gerald', 'Wells', 'gerald.wells@email.com', '555-1091', '1993-11-30', '2023-02-18', 'online', 'Mobile', 'AL', '36602'),
('Gloria', 'Webb', 'gloria.webb@email.com', '555-1092', '1990-04-13', '2023-04-24', 'retail', 'Brownsville', 'TX', '78520'),
('Roger', 'Simpson', 'roger.simpson@email.com', '555-1093', '1988-06-26', '2023-01-08', 'online', 'Bridgeport', 'CT', '06604'),
('Judith', 'Stevens', 'judith.stevens@email.com', '555-1094', '1991-10-19', '2023-03-04', 'retail', 'Grand Rapids', 'MI', '49503'),
('Harold', 'Tucker', 'harold.tucker@email.com', '555-1095', '1987-01-04', '2023-05-16', 'online', 'Akron', 'OH', '44301'),
('Marilyn', 'Porter', 'marilyn.porter@email.com', '555-1096', '1994-08-11', '2023-02-02', 'retail', 'Huntington Beach', 'CA', '92647'),
('Eugene', 'Hunter', 'eugene.hunter@email.com', '555-1097', '1992-12-28', '2023-04-11', 'online', 'Glendale', 'CA', '91204'),
('Debra', 'Hicks', 'debra.hicks@email.com', '555-1098', '1989-05-15', '2023-01-24', 'retail', 'Columbus', 'GA', '31901'),
('Gregory', 'Crawford', 'gregory.crawford@email.com', '555-1099', '1986-07-08', '2023-03-30', 'online', 'Tallahassee', 'FL', '32301'),
('Ruth', 'Henry', 'ruth.henry@email.com', '555-1100', '1993-09-22', '2023-05-12', 'retail', 'Thousand Oaks', 'CA', '91360');

-- Insert sample orders with realistic distribution
INSERT INTO orders (customer_id, product_id, order_date, quantity, unit_price, total_amount, purchase_location, store_id, order_status) VALUES
(1, 1, '2024-01-15', 1, 130.00, 130.00, 'online', NULL, 'completed'),
(2, 5, '2024-01-18', 1, 90.00, 90.00, 'retail', 1, 'completed'),
(3, 8, '2024-01-20', 1, 130.00, 130.00, 'online', NULL, 'completed'),
(4, 12, '2024-01-22', 1, 140.00, 140.00, 'retail', 2, 'completed'),
(5, 2, '2024-01-25', 1, 180.00, 180.00, 'online', NULL, 'completed'),
(6, 7, '2024-01-28', 1, 75.00, 75.00, 'retail', 3, 'completed'),
(7, 3, '2024-02-01', 1, 70.00, 70.00, 'online', NULL, 'completed'),
(8, 14, '2024-02-03', 1, 70.00, 70.00, 'retail', 4, 'completed'),
(9, 9, '2024-02-05', 1, 175.00, 175.00, 'online', NULL, 'completed'),
(10, 4, '2024-02-08', 1, 80.00, 80.00, 'retail', 5, 'completed'),
(11, 6, '2024-02-10', 1, 110.00, 110.00, 'online', NULL, 'completed'),
(12, 15, '2024-02-12', 1, 75.00, 75.00, 'retail', 1, 'completed'),
(13, 1, '2024-02-15', 1, 130.00, 130.00, 'online', NULL, 'completed'),
(14, 11, '2024-02-18', 1, 65.00, 65.00, 'retail', 2, 'completed'),
(15, 19, '2024-02-20', 1, 160.00, 160.00, 'online', NULL, 'completed'),
(16, 13, '2024-02-22', 1, 100.00, 100.00, 'retail', 3, 'completed'),
(17, 20, '2024-02-25', 1, 140.00, 140.00, 'online', NULL, 'completed'),
(18, 10, '2024-02-28', 1, 55.00, 55.00, 'retail', 4, 'completed'),
(19, 2, '2024-03-01', 1, 180.00, 180.00, 'online', NULL, 'completed'),
(20, 17, '2024-03-03', 1, 85.00, 85.00, 'retail', 5, 'completed'),
(21, 18, '2024-03-05', 1, 110.00, 110.00, 'online', NULL, 'completed'),
(22, 3, '2024-03-08', 1, 70.00, 70.00, 'retail', 1, 'completed'),
(23, 16, '2024-03-10', 1, 100.00, 100.00, 'online', NULL, 'completed'),
(24, 8, '2024-03-12', 1, 130.00, 130.00, 'retail', 2, 'completed'),
(25, 4, '2024-03-15', 1, 80.00, 80.00, 'online', NULL, 'completed'),
(26, 12, '2024-03-18', 1, 140.00, 140.00, 'retail', 3, 'completed'),
(27, 5, '2024-03-20', 1, 90.00, 90.00, 'online', NULL, 'completed'),
(28, 7, '2024-03-22', 1, 75.00, 75.00, 'retail', 4, 'completed'),
(29, 1, '2024-03-25', 1, 130.00, 130.00, 'online', NULL, 'completed'),
(30, 14, '2024-03-28', 1, 70.00, 70.00, 'retail', 5, 'completed'),
(31, 9, '2024-04-01', 1, 175.00, 175.00, 'online', NULL, 'completed'),
(32, 6, '2024-04-03', 1, 110.00, 110.00, 'retail', 1, 'completed'),
(33, 15, '2024-04-05', 1, 75.00, 75.00, 'online', NULL, 'completed'),
(34, 11, '2024-04-08', 1, 65.00, 65.00, 'retail', 2, 'completed'),
(35, 19, '2024-04-10', 1, 160.00, 160.00, 'online', NULL, 'completed'),
(36, 13, '2024-04-12', 1, 100.00, 100.00, 'retail', 3, 'completed'),
(37, 20, '2024-04-15', 1, 140.00, 140.00, 'online', NULL, 'completed'),
(38, 10, '2024-04-18', 1, 55.00, 55.00, 'retail', 4, 'completed'),
(39, 2, '2024-04-20', 1, 180.00, 180.00, 'online', NULL, 'completed'),
(40, 17, '2024-04-22', 1, 85.00, 85.00, 'retail', 5, 'completed'),
(41, 18, '2024-04-25', 1, 110.00, 110.00, 'online', NULL, 'completed'),
(42, 3, '2024-04-28', 1, 70.00, 70.00, 'retail', 1, 'completed'),
(43, 16, '2024-05-01', 1, 100.00, 100.00, 'online', NULL, 'completed'),
(44, 8, '2024-05-03', 1, 130.00, 130.00, 'retail', 2, 'completed'),
(45, 4, '2024-05-05', 1, 80.00, 80.00, 'online', NULL, 'completed'),
(46, 12, '2024-05-08', 1, 140.00, 140.00, 'retail', 3, 'completed'),
(47, 5, '2024-05-10', 1, 90.00, 90.00, 'online', NULL, 'completed'),
(48, 7, '2024-05-12', 1, 75.00, 75.00, 'retail', 4, 'completed'),
(49, 1, '2024-05-15', 1, 130.00, 130.00, 'online', NULL, 'completed'),
(50, 14, '2024-05-18', 1, 70.00, 70.00, 'retail', 5, 'completed'),
(51, 9, '2024-05-20', 1, 175.00, 175.00, 'online', NULL, 'completed'),
(52, 6, '2024-05-22', 1, 110.00, 110.00, 'retail', 1, 'completed'),
(53, 15, '2024-05-25', 1, 75.00, 75.00, 'online', NULL, 'completed'),
(54, 11, '2024-05-28', 1, 65.00, 65.00, 'retail', 2, 'completed'),
(55, 19, '2024-06-01', 1, 160.00, 160.00, 'online', NULL, 'completed'),
(56, 13, '2024-06-03', 1, 100.00, 100.00, 'retail', 3, 'completed'),
(57, 20, '2024-06-05', 1, 140.00, 140.00, 'online', NULL, 'completed'),
(58, 10, '2024-06-08', 1, 55.00, 55.00, 'retail', 4, 'completed'),
(59, 2, '2024-06-10', 1, 180.00, 180.00, 'online', NULL, 'completed'),
(60, 17, '2024-06-12', 1, 85.00, 85.00, 'retail', 5, 'completed'),
(61, 18, '2024-06-15', 1, 110.00, 110.00, 'online', NULL, 'completed'),
(62, 3, '2024-06-18', 1, 70.00, 70.00, 'retail', 1, 'completed'),
(63, 16, '2024-06-20', 1, 100.00, 100.00, 'online', NULL, 'completed'),
(64, 8, '2024-06-22', 1, 130.00, 130.00, 'retail', 2, 'completed'),
(65, 4, '2024-06-25', 1, 80.00, 80.00, 'online', NULL, 'completed'),
(66, 12, '2024-06-28', 1, 140.00, 140.00, 'retail', 3, 'completed'),
(67, 5, '2024-07-01', 1, 90.00, 90.00, 'online', NULL, 'completed'),
(68, 7, '2024-07-03', 1, 75.00, 75.00, 'retail', 4, 'completed'),
(69, 1, '2024-07-05', 1, 130.00, 130.00, 'online', NULL, 'completed'),
(70, 14, '2024-07-08', 1, 70.00, 70.00, 'retail', 5, 'completed'),
(71, 9, '2024-07-10', 1, 175.00, 175.00, 'online', NULL, 'completed'),
(72, 6, '2024-07-12', 1, 110.00, 110.00, 'retail', 1, 'completed'),
(73, 15, '2024-07-15', 1, 75.00, 75.00, 'online', NULL, 'completed'),
(74, 11, '2024-07-18', 1, 65.00, 65.00, 'retail', 2, 'completed'),
(75, 19, '2024-07-20', 1, 160.00, 160.00, 'online', NULL, 'completed'),
(76, 13, '2024-07-22', 1, 100.00, 100.00, 'retail', 3, 'completed'),
(77, 20, '2024-07-25', 1, 140.00, 140.00, 'online', NULL, 'completed'),
(78, 10, '2024-07-28', 1, 55.00, 55.00, 'retail', 4, 'completed'),
(79, 2, '2024-08-01', 1, 180.00, 180.00, 'online', NULL, 'completed'),
(80, 17, '2024-08-03', 1, 85.00, 85.00, 'retail', 5, 'completed'),
(81, 18, '2024-08-05', 1, 110.00, 110.00, 'online', NULL, 'completed'),
(82, 3, '2024-08-08', 1, 70.00, 70.00, 'retail', 1, 'completed'),
(83, 16, '2024-08-10', 1, 100.00, 100.00, 'online', NULL, 'completed'),
(84, 8, '2024-08-12', 1, 130.00, 130.00, 'retail', 2, 'completed'),
(85, 4, '2024-08-15', 1, 80.00, 80.00, 'online', NULL, 'completed'),
(86, 12, '2024-08-18', 1, 140.00, 140.00, 'retail', 3, 'completed'),
(87, 5, '2024-08-20', 1, 90.00, 90.00, 'online', NULL, 'completed'),
(88, 7, '2024-08-22', 1, 75.00, 75.00, 'retail', 4, 'completed'),
(89, 1, '2024-08-25', 1, 130.00, 130.00, 'online', NULL, 'completed'),
(90, 14, '2024-08-28', 1, 70.00, 70.00, 'retail', 5, 'completed'),
(91, 9, '2024-09-01', 1, 175.00, 175.00, 'online', NULL, 'completed'),
(92, 6, '2024-09-03', 1, 110.00, 110.00, 'retail', 1, 'completed'),
(93, 15, '2024-09-05', 1, 75.00, 75.00, 'online', NULL, 'completed'),
(94, 11, '2024-09-08', 1, 65.00, 65.00, 'retail', 2, 'completed'),
(95, 19, '2024-09-10', 1, 160.00, 160.00, 'online', NULL, 'completed'),
(96, 13, '2024-09-12', 1, 100.00, 100.00, 'retail', 3, 'completed'),
(97, 20, '2024-09-15', 1, 140.00, 140.00, 'online', NULL, 'completed'),
(98, 10, '2024-09-18', 1, 55.00, 55.00, 'retail', 4, 'completed'),
(99, 2, '2024-09-20', 1, 180.00, 180.00, 'online', NULL, 'completed'),
(100, 17, '2024-09-22', 1, 85.00, 85.00, 'retail', 5, 'completed');

-- Create indexes for better query performance
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_product_id ON orders(product_id);
CREATE INDEX idx_orders_purchase_location ON orders(purchase_location);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_customers_preferred_channel ON customers(preferred_channel);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_brand ON products(brand);

-- Create views for common queries
CREATE VIEW sales_by_location AS
SELECT 
    purchase_location,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value
FROM orders
GROUP BY purchase_location;

CREATE VIEW customer_purchase_behavior AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.preferred_channel,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    STRING_AGG(DISTINCT o.purchase_location, ', ') as purchase_locations
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.preferred_channel;

CREATE VIEW popular_products AS
SELECT 
    p.product_id,
    p.sku,
    p.product_name,
    p.brand,
    p.category,
    p.price,
    COUNT(o.order_id) as times_ordered,
    SUM(o.total_amount) as total_revenue
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.sku, p.product_name, p.brand, p.category, p.price
ORDER BY times_ordered DESC;

-- Sample queries for testing MCP interactions
/* 
Example natural language questions you can ask:

1. "How many customers prefer online shopping vs retail stores?"
2. "What's the total revenue from online sales compared to retail sales?"
3. "Which products are most popular in retail stores?"
4. "Show me customers who prefer online shopping but have made purchases in retail stores"
5. "What's the average order value for each purchase location?"
6. "Which Nike products have generated the most revenue?"
7. "How many orders were placed in the last 30 days?"
8. "What's the distribution of customers across different states?"
9. "Which retail store has the highest sales volume?"
10. "Show me the top 5 customers by total spending"
*/

-- Display summary statistics
SELECT 'Database Setup Complete' as status;
SELECT 'Total Customers' as metric, COUNT(*) as value FROM customers
UNION ALL
SELECT 'Total Products' as metric, COUNT(*) as value FROM products
UNION ALL
SELECT 'Total Orders' as metric, COUNT(*) as value FROM orders
UNION ALL
SELECT 'Total Retail Stores' as metric, COUNT(*) as value FROM retail_stores
UNION ALL
SELECT 'Online Orders' as metric, COUNT(*) as value FROM orders WHERE purchase_location = 'online'
UNION ALL
SELECT 'Retail Orders' as metric, COUNT(*) as value FROM orders WHERE purchase_location = 'retail';