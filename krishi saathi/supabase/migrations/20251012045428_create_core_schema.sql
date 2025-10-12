/*
  # Krishi Saathi - Agriculture Platform Core Schema

  ## Overview
  This migration creates the complete database structure for an agriculture platform
  with mandi prices, weather data, crop recommendations, user management, and analytics.

  ## Tables Created

  ### 1. profiles
  User profiles for farmers and admins
  - `id` (uuid, references auth.users)
  - `full_name` (text)
  - `phone` (text)
  - `role` (text: farmer/admin)
  - `location` (text)
  - `preferred_language` (text: en/hi)
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 2. mandis
  Mandi (market) locations and information
  - `id` (uuid, primary key)
  - `name` (text)
  - `city` (text)
  - `state` (text)
  - `latitude` (numeric)
  - `longitude` (numeric)
  - `contact` (text)
  - `created_at` (timestamptz)

  ### 3. crops
  Crop master data
  - `id` (uuid, primary key)
  - `name_en` (text)
  - `name_hi` (text)
  - `category` (text: cereal/pulse/vegetable/fruit)
  - `season` (text: kharif/rabi/zaid)
  - `soil_type` (text[])
  - `water_requirement` (text: low/medium/high)
  - `duration_days` (integer)
  - `created_at` (timestamptz)

  ### 4. mandi_prices
  Historical and current mandi price data
  - `id` (uuid, primary key)
  - `mandi_id` (uuid, references mandis)
  - `crop_id` (uuid, references crops)
  - `date` (date)
  - `modal_price` (numeric)
  - `min_price` (numeric)
  - `max_price` (numeric)
  - `arrivals_tonnes` (numeric)
  - `created_at` (timestamptz)

  ### 5. weather_data
  Weather information by location
  - `id` (uuid, primary key)
  - `city` (text)
  - `state` (text)
  - `date` (date)
  - `temperature` (numeric)
  - `humidity` (numeric)
  - `rainfall` (numeric)
  - `wind_speed` (numeric)
  - `forecast_days` (jsonb)
  - `created_at` (timestamptz)

  ### 6. crop_recommendations
  ML-based crop recommendation history
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `region` (text)
  - `soil_type` (text)
  - `season` (text)
  - `recommended_crops` (jsonb)
  - `created_at` (timestamptz)

  ### 7. price_predictions
  Future price predictions
  - `id` (uuid, primary key)
  - `crop_id` (uuid, references crops)
  - `mandi_id` (uuid, references mandis)
  - `prediction_date` (date)
  - `predicted_price` (numeric)
  - `confidence_score` (numeric)
  - `created_at` (timestamptz)

  ### 8. disease_detections
  Crop disease detection results
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `crop_id` (uuid, references crops)
  - `image_url` (text)
  - `disease_name` (text)
  - `confidence` (numeric)
  - `treatment` (text)
  - `created_at` (timestamptz)

  ### 9. soil_tests
  Farmer soil test uploads
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `location` (text)
  - `ph_level` (numeric)
  - `nitrogen` (numeric)
  - `phosphorus` (numeric)
  - `potassium` (numeric)
  - `organic_carbon` (numeric)
  - `report_url` (text)
  - `created_at` (timestamptz)

  ### 10. chatbot_conversations
  AI chatbot conversation history
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `messages` (jsonb)
  - `context` (jsonb)
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 11. analytics_events
  Platform analytics tracking
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `event_type` (text)
  - `event_data` (jsonb)
  - `created_at` (timestamptz)

  ## Security
  - RLS enabled on all tables
  - Authenticated users can read public data (mandis, crops, mandi_prices, weather_data)
  - Users can manage their own profile, recommendations, detections, soil tests, and conversations
  - Admins have full access to all tables
  - Analytics events are insert-only for authenticated users
*/

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  phone text,
  role text NOT NULL DEFAULT 'farmer' CHECK (role IN ('farmer', 'admin')),
  location text,
  preferred_language text DEFAULT 'en' CHECK (preferred_language IN ('en', 'hi')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can read all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Create mandis table
CREATE TABLE IF NOT EXISTS mandis (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  city text NOT NULL,
  state text NOT NULL,
  latitude numeric,
  longitude numeric,
  contact text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE mandis ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read mandis"
  ON mandis FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert mandis"
  ON mandis FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update mandis"
  ON mandis FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete mandis"
  ON mandis FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Create crops table
CREATE TABLE IF NOT EXISTS crops (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name_en text NOT NULL,
  name_hi text NOT NULL,
  category text NOT NULL CHECK (category IN ('cereal', 'pulse', 'vegetable', 'fruit', 'cash_crop', 'spice')),
  season text NOT NULL CHECK (season IN ('kharif', 'rabi', 'zaid', 'perennial')),
  soil_type text[] NOT NULL,
  water_requirement text NOT NULL CHECK (water_requirement IN ('low', 'medium', 'high')),
  duration_days integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE crops ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read crops"
  ON crops FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert crops"
  ON crops FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update crops"
  ON crops FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete crops"
  ON crops FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Create mandi_prices table
CREATE TABLE IF NOT EXISTS mandi_prices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mandi_id uuid NOT NULL REFERENCES mandis(id) ON DELETE CASCADE,
  crop_id uuid NOT NULL REFERENCES crops(id) ON DELETE CASCADE,
  date date NOT NULL,
  modal_price numeric NOT NULL,
  min_price numeric NOT NULL,
  max_price numeric NOT NULL,
  arrivals_tonnes numeric DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(mandi_id, crop_id, date)
);

ALTER TABLE mandi_prices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read mandi prices"
  ON mandi_prices FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert mandi prices"
  ON mandi_prices FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update mandi prices"
  ON mandi_prices FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Create weather_data table
CREATE TABLE IF NOT EXISTS weather_data (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  city text NOT NULL,
  state text NOT NULL,
  date date NOT NULL,
  temperature numeric NOT NULL,
  humidity numeric NOT NULL,
  rainfall numeric DEFAULT 0,
  wind_speed numeric DEFAULT 0,
  forecast_days jsonb DEFAULT '[]',
  created_at timestamptz DEFAULT now(),
  UNIQUE(city, state, date)
);

ALTER TABLE weather_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read weather data"
  ON weather_data FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert weather data"
  ON weather_data FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update weather data"
  ON weather_data FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Create crop_recommendations table
CREATE TABLE IF NOT EXISTS crop_recommendations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  region text NOT NULL,
  soil_type text NOT NULL,
  season text NOT NULL,
  recommended_crops jsonb NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE crop_recommendations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own recommendations"
  ON crop_recommendations FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recommendations"
  ON crop_recommendations FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can read all recommendations"
  ON crop_recommendations FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Create price_predictions table
CREATE TABLE IF NOT EXISTS price_predictions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  crop_id uuid NOT NULL REFERENCES crops(id) ON DELETE CASCADE,
  mandi_id uuid NOT NULL REFERENCES mandis(id) ON DELETE CASCADE,
  prediction_date date NOT NULL,
  predicted_price numeric NOT NULL,
  confidence_score numeric DEFAULT 0.5,
  created_at timestamptz DEFAULT now(),
  UNIQUE(crop_id, mandi_id, prediction_date)
);

ALTER TABLE price_predictions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read price predictions"
  ON price_predictions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert price predictions"
  ON price_predictions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Create disease_detections table
CREATE TABLE IF NOT EXISTS disease_detections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  crop_id uuid REFERENCES crops(id) ON DELETE SET NULL,
  image_url text NOT NULL,
  disease_name text,
  confidence numeric,
  treatment text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE disease_detections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own disease detections"
  ON disease_detections FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own disease detections"
  ON disease_detections FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can read all disease detections"
  ON disease_detections FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Create soil_tests table
CREATE TABLE IF NOT EXISTS soil_tests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  location text NOT NULL,
  ph_level numeric,
  nitrogen numeric,
  phosphorus numeric,
  potassium numeric,
  organic_carbon numeric,
  report_url text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE soil_tests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own soil tests"
  ON soil_tests FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own soil tests"
  ON soil_tests FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can read all soil tests"
  ON soil_tests FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Create chatbot_conversations table
CREATE TABLE IF NOT EXISTS chatbot_conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  messages jsonb DEFAULT '[]',
  context jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE chatbot_conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own conversations"
  ON chatbot_conversations FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations"
  ON chatbot_conversations FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own conversations"
  ON chatbot_conversations FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create analytics_events table
CREATE TABLE IF NOT EXISTS analytics_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  event_type text NOT NULL,
  event_data jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own analytics events"
  ON analytics_events FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Admins can read all analytics events"
  ON analytics_events FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_mandi_prices_mandi_crop ON mandi_prices(mandi_id, crop_id);
CREATE INDEX IF NOT EXISTS idx_mandi_prices_date ON mandi_prices(date DESC);
CREATE INDEX IF NOT EXISTS idx_weather_city_date ON weather_data(city, state, date DESC);
CREATE INDEX IF NOT EXISTS idx_price_predictions_crop_mandi ON price_predictions(crop_id, mandi_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_events_created ON analytics_events(created_at DESC);