import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _sttAvailable = false;
  final ValueNotifier<bool> isListening = ValueNotifier(false);
  final ValueNotifier<String> transcript = ValueNotifier('');

  /// Initialize TTS and STT
  Future<void> init() async {
    await _initTts();
    _sttAvailable = await _stt.initialize(
      onStatus: (status) {
        if (status == 'listening') {
          isListening.value = true;
        } else if (status == 'notListening' || status == 'done') {
          isListening.value = false;
        }
      },
      onError: (error) {
        isListening.value = false;
        if (kDebugMode) {
          print('STT Error: $error');
        }
      },
    );
  }

  /// Configure TTS
  Future<void> _initTts() async {
    try {
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setSharedInstance(true);
      }
    } catch (e) {
      if (kDebugMode) print('TTS Init Error: $e');
    }
  }

  /// Speak text
  Future<void> speak(String text) async {
    try {
      await stopTts();
      await _tts.speak(text);
    } catch (e) {
      if (kDebugMode) print('TTS Speak Error: $e');
    }
  }

  /// Stop TTS
  Future<void> stopTts() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Start listening
  Future<Object> startListening({String localeId = 'en_US'}) async {
    if (!_sttAvailable) {
      _sttAvailable = await _stt.initialize();
      if (!_sttAvailable) return false;
    }

    transcript.value = '';
    isListening.value = true;

    try {
      return _stt.listen(
        localeId: localeId,
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        onResult: (result) {
          transcript.value = result.recognizedWords;
        },
      );
    } catch (e) {
      isListening.value = false;
      if (kDebugMode) print('STT Listen Error: $e');
      return false;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {}
    isListening.value = false;
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      await _stt.cancel();
    } catch (_) {}
    isListening.value = false;
  }

  /// Dispose resources
  void dispose() {
    _tts.stop();
    _stt.cancel();
    isListening.dispose();
    transcript.dispose();
  }
}
