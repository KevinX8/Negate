import 'dart:developer';

import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'package:negate/analyser/sentiment_analysis.dart';

class SentimentAnalysisMLKit extends SentimentAnalysis {
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  SentimentAnalysisMLKit.isolate(int iAddress, Map<String, int> dict)
      : super.isolate(iAddress, dict);

  Future<double> classifyMobile(String rawText) async {
    // If translate is enabled, translate the text to english
    // using google ml kit on device translation,
    // source language is detected automatically
      log(rawText);
      final String response =
      await _languageIdentifier.identifyLanguage(rawText);
      log('language is : $response');
      if (response != 'und' && response != 'en') {
        final onDeviceTranslator = OnDeviceTranslator(
            sourceLanguage: TranslateLanguage.values
                .firstWhere((element) => element.bcpCode == response),
            targetLanguage: TranslateLanguage.english);
        rawText = await onDeviceTranslator.translateText(rawText);
        log(rawText);
      }
      return super.classify(rawText);
  }
}
