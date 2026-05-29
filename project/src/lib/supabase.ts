import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type CropDisease = {
  id: string;
  disease_name: string;
  disease_name_hi: string;
  crop_type: string;
  crop_type_hi: string;
  symptoms: string;
  symptoms_hi: string;
  remedy: string;
  remedy_hi: string;
  severity: string;
  created_at: string;
};

export type ScanResult = {
  id: string;
  image_url: string | null;
  detected_disease_id: string | null;
  confidence: number | null;
  user_id: string | null;
  created_at: string;
  crop_diseases?: CropDisease;
};
