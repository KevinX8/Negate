import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:negate/analyser/sentiment_analysis.dart';

void main() {
  test('Sentiment Analysis Test', () async {
    WidgetsFlutterBinding.ensureInitialized();
    SentimentAnalysis analyser = SentimentAnalysis();
    await analyser.init();
    double score = analyser.classify("I love this so much!");
    expect(score, greaterThan(0.5));

    score = analyser.classify("I hate you so much");
    expect(score, lessThan(0.5));

    score = analyser.classify("I don't like this very much, but it has some good points");
    expect(score, greaterThan(0.5));
    expect(score, lessThan(0.6));

    score = analyser.classify("This is an absolute masterpiece");
    expect(score, greaterThan(0.6));

    score = analyser.classify("This is a complete disaster");
    expect(score, lessThan(0.4));
  });
}
