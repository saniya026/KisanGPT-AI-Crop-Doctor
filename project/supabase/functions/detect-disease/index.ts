import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface RequestBody {
  image?: string;
}

Deno.serve(async (req: Request) => {
  // Handle OPTIONS request
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const { image }: RequestBody = await req.json();

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Fetch all diseases from database
    const { data: diseases, error: dbError } = await supabase
      .from("crop_diseases")
      .select("*");

    if (dbError) {
      console.error("Database error:", dbError);
      throw new Error("Failed to fetch disease data");
    }

    if (!diseases || diseases.length === 0) {
      throw new Error("No disease data available");
    }

    // Simulated AI detection (in production, integrate with actual AI model)
    // For demo purposes, we'll randomly select a disease with weighted confidence
    const randomIndex = Math.floor(Math.random() * diseases.length);
    const confidence = 0.75 + Math.random() * 0.20; // 75-95% confidence

    const detectedDisease = diseases[randomIndex];

    return new Response(
      JSON.stringify({
        success: true,
        disease: detectedDisease,
        confidence: confidence,
        message: "Disease detected successfully",
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || "Detection failed",
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  }
});
