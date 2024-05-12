import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

var headers = {'Content-Type': 'application/json'};

Future<String> talkWithGemini(
    {String resumeText = "", String jobDescription = ""}) async {
  try {
    var client = http.Client();
    var body = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "This is my CV. $resumeText and here is the job description: $jobDescription, give me tips on how to improve my CV to match the job description."
            }
          ]
        }
      ]
    };
    var response = await client.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0-pro:generateContent?key=AIzaSyCqARFd0JhquEC13dp5e1RBe0Dvefqrr4U'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      debugPrint(response.body);
      return jsonString["candidates"][0]["content"]["parts"][0]["text"]
          .toString();
    } else {
      debugPrint(response.reasonPhrase);
      return response.reasonPhrase.toString();
    }
  } catch (e) {
    debugPrint(e.toString());
    return e.toString();
  }
}
