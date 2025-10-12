/*
  # Seed Initial Data for Krishi Saathi Platform

  ## Overview
  This migration populates the database with sample data for testing and demonstration.

  ## Data Added

  ### 1. Sample Crops
  - Major Indian crops across different categories
  - Includes English and Hindi names
  - Season and soil type information

  ### 2. Sample Mandis
  - Agricultural markets across major Indian cities
  - Location data with coordinates
  - Contact information

  ### 3. Sample Mandi Prices
  - Historical price data for crops in various mandis
  - Includes modal, min, and max prices
  - Arrival quantities in tonnes

  ## Important Notes
  - Uses IF NOT EXISTS patterns to avoid duplicate data
  - All data is sample/mock data for demonstration
  - Prices are indicative and for testing purposes only
*/

-- Insert sample crops
INSERT INTO crops (name_en, name_hi, category, season, soil_type, water_requirement, duration_days)
VALUES
  ('Wheat', 'गेहूं', 'cereal', 'rabi', ARRAY['loamy', 'clay'], 'medium', 120),
  ('Rice', 'धान', 'cereal', 'kharif', ARRAY['clay', 'loamy'], 'high', 120),
  ('Cotton', 'कपास', 'cash_crop', 'kharif', ARRAY['black', 'loamy'], 'medium', 180),
  ('Sugarcane', 'गन्ना', 'cash_crop', 'perennial', ARRAY['loamy', 'clay'], 'high', 365),
  ('Maize', 'मक्का', 'cereal', 'kharif', ARRAY['loamy', 'sandy'], 'medium', 90),
  ('Chickpea', 'चना', 'pulse', 'rabi', ARRAY['loamy', 'black'], 'low', 120),
  ('Mustard', 'सरसों', 'cash_crop', 'rabi', ARRAY['loamy', 'sandy'], 'low', 90),
  ('Soybean', 'सोयाबीन', 'pulse', 'kharif', ARRAY['black', 'loamy'], 'medium', 100),
  ('Groundnut', 'मूंगफली', 'cash_crop', 'kharif', ARRAY['sandy', 'loamy'], 'medium', 120),
  ('Potato', 'आलू', 'vegetable', 'rabi', ARRAY['loamy', 'sandy'], 'medium', 90),
  ('Onion', 'प्याज', 'vegetable', 'rabi', ARRAY['loamy', 'clay'], 'medium', 120),
  ('Tomato', 'टमाटर', 'vegetable', 'kharif', ARRAY['loamy', 'sandy'], 'medium', 75),
  ('Mango', 'आम', 'fruit', 'perennial', ARRAY['loamy', 'sandy'], 'medium', 365),
  ('Banana', 'केला', 'fruit', 'perennial', ARRAY['loamy', 'clay'], 'high', 365),
  ('Turmeric', 'हल्दी', 'spice', 'kharif', ARRAY['loamy', 'clay'], 'medium', 240)
ON CONFLICT DO NOTHING;

-- Insert sample mandis
INSERT INTO mandis (name, city, state, latitude, longitude, contact)
VALUES
  ('Azadpur Mandi', 'Delhi', 'Delhi', 28.7041, 77.1025, '+91-11-2765-4321'),
  ('Vashi APMC', 'Mumbai', 'Maharashtra', 19.0760, 72.8777, '+91-22-2765-8900'),
  ('Koyambedu Market', 'Chennai', 'Tamil Nadu', 13.0827, 80.2707, '+91-44-2345-6789'),
  ('Yeshwanthpur APMC', 'Bangalore', 'Karnataka', 13.0299, 77.5431, '+91-80-2345-1234'),
  ('Gaddiannaram Mandi', 'Hyderabad', 'Telangana', 17.3850, 78.4867, '+91-40-2456-7890'),
  ('Koyambedu Wholesale Market', 'Kolkata', 'West Bengal', 22.5726, 88.3639, '+91-33-2234-5678'),
  ('Jalandhar Mandi', 'Jalandhar', 'Punjab', 31.3260, 75.5762, '+91-181-234-5678'),
  ('Krishi Upaj Mandi', 'Jaipur', 'Rajasthan', 26.9124, 75.7873, '+91-141-234-5678'),
  ('Lasalgaon APMC', 'Nashik', 'Maharashtra', 20.1330, 74.2350, '+91-253-234-5678'),
  ('Alwar Mandi', 'Alwar', 'Rajasthan', 27.5530, 76.6346, '+91-144-234-5678'),
  ('Ambala Grain Market', 'Ambala', 'Haryana', 30.3782, 76.7767, '+91-171-234-5678'),
  ('Guntur Mirchi Yard', 'Guntur', 'Andhra Pradesh', 16.3067, 80.4365, '+91-863-234-5678')
ON CONFLICT DO NOTHING;

-- Insert sample mandi prices
WITH crop_data AS (
  SELECT id, name_en FROM crops LIMIT 5
),
mandi_data AS (
  SELECT id, name FROM mandis LIMIT 5
),
date_series AS (
  SELECT generate_series(
    CURRENT_DATE - INTERVAL '30 days',
    CURRENT_DATE,
    INTERVAL '1 day'
  )::date AS date
)
INSERT INTO mandi_prices (mandi_id, crop_id, date, modal_price, min_price, max_price, arrivals_tonnes)
SELECT
  m.id,
  c.id,
  d.date,
  2000 + (random() * 3000)::numeric(10,2),
  1500 + (random() * 2000)::numeric(10,2),
  2500 + (random() * 4000)::numeric(10,2),
  50 + (random() * 200)::numeric(10,2)
FROM mandi_data m
CROSS JOIN crop_data c
CROSS JOIN date_series d
ON CONFLICT (mandi_id, crop_id, date) DO NOTHING;

-- Insert sample weather data
INSERT INTO weather_data (city, state, date, temperature, humidity, rainfall, wind_speed, forecast_days)
SELECT
  'Delhi',
  'Delhi',
  CURRENT_DATE,
  28.5,
  65.0,
  0.0,
  12.5,
  jsonb_build_array(
    jsonb_build_object('date', (CURRENT_DATE + 1)::text, 'temp', 29.0, 'humidity', 63.0, 'rainfall', 0.0, 'description', 'Partly Cloudy'),
    jsonb_build_object('date', (CURRENT_DATE + 2)::text, 'temp', 30.5, 'humidity', 60.0, 'rainfall', 0.0, 'description', 'Sunny'),
    jsonb_build_object('date', (CURRENT_DATE + 3)::text, 'temp', 28.0, 'humidity', 68.0, 'rainfall', 5.0, 'description', 'Rainy'),
    jsonb_build_object('date', (CURRENT_DATE + 4)::text, 'temp', 27.5, 'humidity', 70.0, 'rainfall', 2.0, 'description', 'Cloudy'),
    jsonb_build_object('date', (CURRENT_DATE + 5)::text, 'temp', 29.5, 'humidity', 62.0, 'rainfall', 0.0, 'description', 'Sunny')
  )
ON CONFLICT (city, state, date) DO UPDATE
SET
  temperature = EXCLUDED.temperature,
  humidity = EXCLUDED.humidity,
  rainfall = EXCLUDED.rainfall,
  wind_speed = EXCLUDED.wind_speed,
  forecast_days = EXCLUDED.forecast_days;