DROP TABLE IF EXISTS warranty;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS stores;

-- STORES
CREATE TABLE stores (
    store_id VARCHAR(5) PRIMARY KEY,
    store_name VARCHAR(30) NOT NULL,
    city VARCHAR(25) NOT NULL,
    country VARCHAR(25) NOT NULL
);

-- CATEGORY
CREATE TABLE category (
    category_id VARCHAR(10) PRIMARY KEY,
    category_name VARCHAR(20) NOT NULL
);

-- PRODUCTS
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(35) NOT NULL,
    category_id VARCHAR(10) NOT NULL,
    launch_date DATE,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_category 
        FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- SALES
CREATE TABLE sales (
    sale_id VARCHAR(15) PRIMARY KEY,
    sale_date DATE NOT NULL,
    store_id VARCHAR(5) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT fk_store 
        FOREIGN KEY (store_id) REFERENCES stores(store_id),
    CONSTRAINT fk_product 
        FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- WARRANTY
CREATE TABLE warranty (
    claim_id VARCHAR(10) PRIMARY KEY,
    claim_date DATE NOT NULL,
    sale_id VARCHAR(15) NOT NULL,
    repair_status VARCHAR(15) NOT NULL,
    CONSTRAINT fk_sales 
        FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);
