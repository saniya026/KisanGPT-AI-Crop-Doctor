/*
  # KisanGPT Database Schema

  1. New Tables
    - `crop_diseases`
      - `id` (uuid, primary key)
      - `disease_name` (text, disease name in English)
      - `disease_name_hi` (text, disease name in Hindi)
      - `crop_type` (text, e.g., rice, wheat, tomato)
      - `crop_type_hi` (text, crop type in Hindi)
      - `symptoms` (text, symptoms in English)
      - `symptoms_hi` (text, symptoms in Hindi)
      - `remedy` (text, remedy in English)
      - `remedy_hi` (text, remedy in Hindi)
      - `severity` (text, low/medium/high)
      - `created_at` (timestamp)
    
    - `scan_history`
      - `id` (uuid, primary key)
      - `image_url` (text, uploaded image URL)
      - `detected_disease_id` (uuid, foreign key to crop_diseases)
      - `confidence` (decimal, detection confidence)
      - `user_id` (uuid, optional user reference)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Crop diseases readable by all (public reference data)
    - Scan history accessible to authenticated users only

  3. Notes
    - Pre-populated with common crop diseases for demo
    - Hindi field suffix `_hi` for Hindi translations
*/

-- Create crop_diseases table
CREATE TABLE IF NOT EXISTS crop_diseases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  disease_name text NOT NULL,
  disease_name_hi text NOT NULL,
  crop_type text NOT NULL,
  crop_type_hi text NOT NULL,
  symptoms text NOT NULL,
  symptoms_hi text NOT NULL,
  remedy text NOT NULL,
  remedy_hi text NOT NULL,
  severity text NOT NULL DEFAULT 'medium',
  created_at timestamptz DEFAULT now()
);

-- Create scan_history table
CREATE TABLE IF NOT EXISTS scan_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url text,
  detected_disease_id uuid REFERENCES crop_diseases(id),
  confidence decimal(5,4),
  user_id uuid,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE crop_diseases ENABLE ROW LEVEL SECURITY;
ALTER TABLE scan_history ENABLE ROW LEVEL SECURITY;

-- Crop diseases policies (public read, no write for now)
CREATE POLICY "Anyone can read crop diseases"
  ON crop_diseases FOR SELECT
  TO authenticated, anon
  USING (true);

-- Scan history policies (authenticated users only)
CREATE POLICY "Users can read own scan history"
  ON scan_history FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own scan history"
  ON scan_history FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Insert sample crop diseases data
INSERT INTO crop_diseases (disease_name, disease_name_hi, crop_type, crop_type_hi, symptoms, symptoms_hi, remedy, remedy_hi, severity) VALUES
(
  'Leaf Blight',
  'पत्ती झुलसा',
  'Rice',
  'धान',
  'Brown lesions on leaves, yellowing, wilting of leaf tips',
  'पत्तियों पर भूरे धब्बे, पीलापन, पत्तियों के सिरों का मुरझाना',
  'Apply copper-based fungicide spray every 7-10 days. Remove and destroy infected plant debris. Ensure proper drainage and avoid overhead irrigation.',
  'हर 7-10 दिनों में तांबे आधारित फफूंदनाशक का छिड़काव करें। संक्रमित पौधों को हटाकर नष्ट करें। उचित जल निकासी सुनिश्चित करें और ऊपर से सिंचाई न करें।',
  'high'
),
(
  'Powdery Mildew',
  'फफूंदी',
  'Wheat',
  'गेहूं',
  'White powdery growth on leaves and stems, stunted growth',
  'पत्तियों और तनों पर सफेद चूर्ण जैसा विकास, बौना विकास',
  'Apply sulfur-based fungicide. Improve air circulation. Avoid excessive nitrogen fertilization. Use resistant varieties.',
  'सल्फर आधारित फफूंदनाशक का प्रयोग करें। हवा के संचार में सुधार करें। अत्यधिक नाइट्रोजन उर्वरक से बचें। प्रतिरोधी किस्मों का उपयोग करें।',
  'medium'
),
(
  'Bacterial Leaf Spot',
  'जीवाणु पत्ती धब्बा',
  'Tomato',
  'टमाटर',
  'Small water-soaked spots on leaves, turning brown with yellow halos',
  'पत्तियों पर छोटे पानी भरे धब्बे, पीले हालो के साथ भूरे हो जाते हैं',
  'Remove infected leaves. Apply copper bactericide spray. Avoid working in wet fields. Practice crop rotation.',
  'संक्रमित पत्तियां हटाएं। तांबा जीवाणुनाशक स्प्रे लगाएं। गीले खेतों में काम न करें। फसल चक्र का अभ्यास करें।',
  'medium'
),
(
  'Rust Disease',
  'रस्ट रोग',
  'Maize',
  'मक्का',
  'Orange-brown pustules on leaves, premature drying',
  'पत्तियों पर नारंगी-भूरे छाले, समय से पहले सूखना',
  'Apply triazole fungicide. Plant resistant hybrids. Remove volunteer plants. Ensure proper nutrition.',
  'ट्रायजोल फफूंदनाशक लगाएं। प्रतिरोधी संकर लगाएं। स्वयं उगे पौधे हटाएं। उचित पोषण सुनिश्चित करें।',
  'high'
),
(
  'Downy Mildew',
  'अवसाद फफूंदी',
  'Sorghum',
  'ज्वार',
  'Yellow patches on upper leaf surface, white growth underneath',
  'पत्ती की ऊपरी सतह पर पीले धब्बे, नीचे सफेद विकास',
  'Apply metalaxyl-based fungicide. Improve drainage. Use disease-free seeds. Rotate crops.',
  'मेटालैक्सिल आधारित फफूंदनाशक लगाएं। जल निकासी में सुधार करें। रोग मुक्त बीज का उपयोग करें। फसलों का चक्र बदलें।',
  'medium'
),
(
  'Early Blight',
  'प्रारंभिक झुलसा',
  'Potato',
  'आलू',
  'Dark brown spots with concentric rings on lower leaves',
  'निचली पत्तियों पर संकेंद्रित छल्लों वाले गहरे भूरे धब्बे',
  'Apply chlorothalonil or mancozeb fungicide. Remove infected plant material. Maintain proper plant spacing. Avoid overhead watering.',
  'क्लोरोथालोनिल या मैनकोजेब फफूंदनाशक लगाएं। संक्रमित पौधे की सामग्री हटाएं। उचित पौधे की दूरी बनाए रखें। ऊपर से पानी देने से बचें।',
  'medium'
),
(
  'Anthracnose',
  'एंथ्रेक्नोज',
  'Soybean',
  'सोयाबीन',
  'Sunken dark lesions on stems, pods, and leaves',
  'तनों, फलियों और पत्तियों पर धंसे हुए गहरे घाव',
  'Apply approved fungicides before pod development. Use certified disease-free seeds. Rotate crops with non-host plants. Destroy crop residue.',
  'फली विकास से पहले मंजूरा फफूंदनाशक लगाएं। प्रमाणित रोग मुक्त बीज का उपयोग करें। गैर-मेजबान पौधों के साथ फसल चक्र करें। फसल अवशेष नष्ट करें।',
  'high'
),
(
  'Bacterial Wilt',
  'जीवाणुवत विल्ट',
  'Brinjal',
  'बैंगन',
  'Wilting of leaves, vascular discoloration, plant collapse',
  'पत्तियों का मुरझाना, संवहनी बिरंजन, पौधे का गिरना',
  'Remove and destroy infected plants. Soil solarization before planting. Use resistant varieties. Avoid injuring roots during cultivation.',
  'संक्रमित पौधों को हटाकर नष्ट करें। रोपण से पहले मिट्ती सूर्यांकन करें। प्रतिरोधी किस्मों का उपयोग करें। खेती के दौरान जड़ों को नुकसान से बचें।',
  'high'
),
(
  'Leaf Curl Virus',
  'पत्ती मोड़ वायरस',
  'Cotton',
  'कपास',
  'Upward curling of leaves, thickening of veins, yellowing',
  'पत्तियों का ऊपर की ओर मुड़ना, शिराओं का मोटा होना, पीलापन',
  'Control whitefly vectors with insecticides. Remove infected plants early. Use tolerant varieties. Practice barrier crops.',
  'सफेद मक्खी वैक्टर को कीटनाशक से नियंत्रित करें। संक्रमित पौधों को जल्दी हटाएं। सहनशील किस्मों का उपयोग करें। अवरोधक फसलें लगाएं।',
  'high'
),
(
  'Root Rot',
  'जड़ सड़न',
  'Chickpea',
  'चना',
  'Yellowing of leaves, wilting, root discoloration, poor growth',
  'पत्तियों का पीलापन, मुरझाना, जड़ों का बिरंजन, कमजोर विकास',
  'Apply trichoderma-based biofungicides. Improve soil drainage. Treat seeds with fungicide. Rotate crops every 2-3 years.',
  'ट्राइकोडर्मा आधारित जैव फफूंदनाशक लगाएं। मिट्टी की जल निकासी में सुधार करें। बीजों को फफूंदनाशक से उपचारित करें। हर 2-3 वर्ष में फसलें बदलें।',
  'high'
),
(
  'Spot Blotch',
  'स्पॉट ब्लॉच',
  'Barley',
  'जौ',
  'Brown to black spots on leaves, blotching of leaf sheath',
  'पत्तियों पर भूरे से काले धब्बे, पत्ती म्यान का धब्बेदार होना',
  'Apply propiconazole fungicide. Use resistant varieties. Improve crop residue management. Ensure balanced nutrition.',
  'प्रोपिकोनाजोल फफूंदनाशक लगाएं। प्रतिरोधी किस्मों का उपयोग करें। फसल अवशेष प्रबंधन में सुधार करें। संतुलित पोषण सुनिश्चित करें।',
  'medium'
),
(
  'Yellow Mosaic Virus',
  'पीत मोज़ेइक वायरस',
  'Mung Bean',
  'मूंग',
  'Yellow and green mosaic pattern on leaves, stunted growth',
  'पत्तियों पर पीले और हरे मोज़ेइक पैटर्न, बौना विकास',
  'Control whitefly population with yellow sticky traps and insecticides. Remove infected plants. Use resistant varieties. Destroy weed hosts.',
  'पीले चिपकने वाले जाल और कीटनाशक से सफेद मक्खी की आबादी नियंत्रित करें। संक्रमित पौधों को हटाएं। प्रतिरोधी किस्मों का उपयोग करें। खरपतवार मेजबानों को नष्ट करें।',
  'high'
);

-- Create index for crop_type lookups
CREATE INDEX IF NOT EXISTS idx_crop_diseases_crop_type ON crop_diseases(crop_type);
CREATE INDEX IF NOT EXISTS idx_scan_history_user ON scan_history(user_id);
