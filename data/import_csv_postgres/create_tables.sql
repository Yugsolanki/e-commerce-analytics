CREATE TABLE raw_customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city VARCHAR(50),
    customer_state VARCHAR(2)
);

CREATE TABLE raw_geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR(50),
    geolocation_state VARCHAR(2)
);

CREATE TABLE raw_orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32) REFERENCES raw_customers(customer_id),
    order_status VARCHAR(15),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE raw_order_items (
    order_id VARCHAR(32) REFERENCES raw_orders(order_id),
    order_item_id INT,
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE raw_order_payments (
    order_id VARCHAR(32) REFERENCES raw_orders(order_id),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value NUMERIC(10, 2)
);

CREATE TABLE raw_order_reviews (
    review_id VARCHAR(32),
    order_id VARCHAR(32) REFERENCES raw_orders(order_id),
    review_score INT,
    review_comment_title VARCHAR(50),
    review_comment_message VARCHAR(255),
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE raw_products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(50),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE raw_sellers (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(50),
    seller_state VARCHAR(2)
);

CREATE TABLE raw_product_category_translation (
    product_category_name VARCHAR(50),
    product_category_name_en VARCHAR(50)
);