import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type Profile = {
  id: string;
  full_name: string;
  phone: string | null;
  role: 'farmer' | 'admin';
  location: string | null;
  preferred_language: 'en' | 'hi';
  created_at: string;
  updated_at: string;
};

export type Mandi = {
  id: string;
  name: string;
  city: string;
  state: string;
  latitude: number | null;
  longitude: number | null;
  contact: string | null;
  created_at: string;
};

export type Crop = {
  id: string;
  name_en: string;
  name_hi: string;
  category: 'cereal' | 'pulse' | 'vegetable' | 'fruit' | 'cash_crop' | 'spice';
  season: 'kharif' | 'rabi' | 'zaid' | 'perennial';
  soil_type: string[];
  water_requirement: 'low' | 'medium' | 'high';
  duration_days: number;
  created_at: string;
};

export type MandiPrice = {
  id: string;
  mandi_id: string;
  crop_id: string;
  date: string;
  modal_price: number;
  min_price: number;
  max_price: number;
  arrivals_tonnes: number;
  created_at: string;
  mandi?: Mandi;
  crop?: Crop;
};

export type WeatherData = {
  id: string;
  city: string;
  state: string;
  date: string;
  temperature: number;
  humidity: number;
  rainfall: number;
  wind_speed: number;
  forecast_days: Array<{
    date: string;
    temp: number;
    humidity: number;
    rainfall: number;
    description: string;
  }>;
  created_at: string;
};
