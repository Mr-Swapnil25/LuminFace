import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyCjKpsjq9wE1tBJPK7CFOnBACbCd5lyoiw';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent';

  Future<Map<String, dynamic>> analyzeSkin({
    required String imageBase64,
    required String gender,
    required String ageGroup,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Analyze this facial image for skin health assessment. 
                  The person in the image identifies as $gender and is in the $ageGroup age group.
                  
                  Provide the following information in JSON format:
                  1. Skin tone (specific shade)
                  2. Glow score (0.0 to 1.0)
                  3. Wrinkle zones (areas of face with severity score 0.0 to 1.0)
                  4. Blemish/redness zones (areas with severity score 0.0 to 1.0)
                  5. Facial symmetry score (0.0 to 1.0)
                  6. Personalized skincare suggestions (list of 3-5 recommendations)
                  
                  Return ONLY valid JSON, no additional text.'''
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': imageBase64
                  }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String text = responseData['candidates'][0]['content']['parts'][0]['text'];
        return parseAnalysisResults(jsonDecode(text));
      } else {
        throw Exception('Failed to analyze skin: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      throw Exception('Failed to analyze skin: $e');
    }
  }

  // Parse analysis results into a more structured format
  Map<String, dynamic> parseAnalysisResults(Map<String, dynamic> rawResults) {
    try {
      // Extract skin tone
      final String skinTone = rawResults['skinTone'] ?? 'Unknown';
      
      // Extract glow score (0.0 to 1.0)
      final double glowScore = (rawResults['glowScore'] as num?)?.toDouble() ?? 0.0;
      
      // Extract wrinkle zones
      final Map<String, double> wrinkleZones = 
          Map<String, double>.from(rawResults['wrinkleZones'] ?? {});
      
      // Extract blemish zones
      final Map<String, double> blemishZones = 
          Map<String, double>.from(rawResults['blemishZones'] ?? {});
      
      // Extract facial symmetry score (0.0 to 1.0)
      final double symmetryScore = (rawResults['symmetryScore'] as num?)?.toDouble() ?? 0.0;
      
      // Extract suggestions
      final List<String> suggestions = 
          List<String>.from(rawResults['suggestions'] ?? []);
      
      // Return structured data
      return {
        'skinTone': skinTone,
        'glowScore': glowScore,
        'wrinkleZones': wrinkleZones,
        'blemishZones': blemishZones,
        'symmetryScore': symmetryScore,
        'suggestions': suggestions,
      };
    } catch (e) {
      print('Error parsing analysis results: $e');
      throw Exception('Failed to parse analysis results: $e');
    }
  }

  // Mock analysis for testing or when API is unavailable
  Map<String, dynamic> getMockAnalysis() {
    return {
      'skinTone': 'Medium Warm',
      'glowScore': 0.72,
      'wrinkleZones': {
        'forehead': 0.3,
        'eyesArea': 0.2,
        'mouthArea': 0.1,
        'neckArea': 0.15,
      },
      'blemishZones': {
        'tZone': 0.4,
        'cheeks': 0.2,
        'chin': 0.3,
        'forehead': 0.25,
      },
      'symmetryScore': 0.85,
      'suggestions': [
        'Increase hydration with hyaluronic acid products',
        'Add vitamin C serum to your morning routine for increased glow',
        'Consider using a gentle exfoliant 2-3 times per week',
        'Target the forehead area with anti-aging products',
        'Apply a hydrating mask to give your skin an immediate boost',
      ],
    };
  }
}

// Example Firebase Cloud Function (to be deployed separately)
/*
const functions = require('firebase-functions');
const {GoogleGenerativeAI} = require('@google/generative-ai');

exports.analyzeSkinWithGemini = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Authentication required'
    );
  }

  try {
    // Initialize Gemini API
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

    // Get the model (Gemini Pro Vision for image analysis)
    const model = genAI.getGenerativeModel({
      model: "gemini-pro-vision"
    });

    // Process the input data
    const imageBase64 = data.imageBase64;
    const gender = data.gender;
    const ageGroup = data.ageGroup;

    // Create a prompt for skin analysis
    const prompt = `Analyze this facial image for skin health assessment. 
    The person in the image identifies as ${gender} and is in the ${ageGroup} age group.
    
    Provide the following information in JSON format:
    1. Skin tone (specific shade)
    2. Glow score (0.0 to 1.0)
    3. Wrinkle zones (areas of face with severity score 0.0 to 1.0)
    4. Blemish/redness zones (areas with severity score 0.0 to 1.0)
    5. Facial symmetry score (0.0 to 1.0)
    6. Personalized skincare suggestions (list of 3-5 recommendations)
    
    Return ONLY valid JSON, no additional text.`;

    // Prepare the image for the model
    const imageParts = [{
      inlineData: {
        data: imageBase64,
        mimeType: "image/jpeg"
      }
    }];

    // Generate content with the model
    const result = await model.generateContent([prompt, ...imageParts]);
    const response = await result.response;
    const text = response.text();

    // Parse the JSON result
    const jsonResult = JSON.parse(text);

    return jsonResult;
  } catch (error) {
    console.error("Error processing image with Gemini:", error);
    throw new functions.https.HttpsError(
      'internal',
      'Error analyzing skin',
      error.message
    );
  }
});
*/ 