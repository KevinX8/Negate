import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class SentimentAnalysis {
  // name of the model file
  final _modelFile = 'text_classification.tflite';
  final _vocabFile = 'text_classification_vocab.txt';

  // Maximum length of sentence
  final int _sentenceLen = 256;

  final String start = '<START>';
  final String pad = '<PAD>';
  final String unk = '<UNKNOWN>';

  late Map<String, int> dictionary;

  // TensorFlow Lite Interpreter object
  late Interpreter sInterpreter;

  SentimentAnalysis();

  SentimentAnalysis.isolate(int iAddress, Map<String, int> dict) {
    sInterpreter = Interpreter.fromAddress(iAddress);
    dictionary = dict;
  }

  Future<void> init() async {
    // Load model when the classifier is initialized.
    await _loadModel();
    await _loadDictionary();
  }

  Future<void> _loadModel() async {
    // Creating the interpreter using Interpreter.fromAsset
    sInterpreter = await Interpreter.fromAsset(_modelFile);
    log('Interpreter loaded successfully');
  }

  Future<void> _loadDictionary() async {
    final vocab = await rootBundle.loadString('assets/$_vocabFile');
    var dict = <String, int>{};
    final vocabList = vocab.split('\n');
    for (var i = 0; i < vocabList.length; i++) {
      var entry = vocabList[i].trim().split(' ');
      dict[entry[0]] = int.parse(entry[1]);
    }
    dictionary = dict;
    log('Dictionary loaded successfully');
  }

  double classify(String rawText) {
    // tokenizeInputText returns List<List<double>>
    // of shape [1, 256].
    List<List<double>> input = tokenizeInputText(rawText);

    // output of shape [1,2].
    var output = List<double>.filled(2, 0).reshape([1, 2]);

    // The run method will run inference and
    // store the resulting values in output.
    sInterpreter.run(input, output);

    //return positive score only
    return output[0][1];
  }

  List<List<double>> tokenizeInputText(String text) {
    // Whitespace tokenization
    final tokens = text.split(' ');

    // Create a list of length==_sentenceLen filled with the value <pad>
    var vec = List<double>.filled(_sentenceLen, dictionary[pad]!.toDouble());

    var index = 0;
    if (dictionary.containsKey(start)) {
      vec[index++] = dictionary[start]!.toDouble();
    }

    // For each word in sentence find corresponding index in dict
    for (var tok in tokens) {
      if (index > _sentenceLen) {
        break;
      }
      vec[index++] = dictionary.containsKey(tok)
          ? dictionary[tok]!.toDouble()
          : dictionary[unk]!.toDouble();
    }

    // returning List<List<double>> as our interpreter input tensor expects the shape, [1,256]
    return [vec];
  }
}
