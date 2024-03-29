import 'dart:async';
import 'dart:io';

import 'package:file/local.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class AudioRecorder {
  static const MethodChannel _channel = const MethodChannel('audio_recorder');

  /// use [LocalFileSystem] to permit widget testing
  static LocalFileSystem fs = LocalFileSystem();

  static Future start(
      {String path, AudioOutputFormat audioOutputFormat}) async {
    String extension="amr";
    return _channel
        .invokeMethod('start', {"path": path, "extension": extension});
  }

  static Future<bool> pause()async{
    bool result=await await _channel.invokeMethod('pause');
    return result;
  }

  static Future<bool> resume()async{
    bool result=await await _channel.invokeMethod('resume');
    return result;
  }

  static Future<Recording> stop() async {
    Map<String, Object> response =
    Map.from(await _channel.invokeMethod('stop'));
    Recording recording = new Recording(
        duration: new Duration(milliseconds: response['duration']),
        path: response['path'],
        audioOutputFormat:
        _convertStringInAudioOutputFormat(response['audioOutputFormat']),
        extension: response['audioOutputFormat']);
    return recording;
  }

  static Future<bool> get isRecording async {
    bool isRecording = await _channel.invokeMethod('isRecording');
    return isRecording;
  }

  static Future<bool> get hasPermissions async {
    bool hasPermission = await _channel.invokeMethod('hasPermissions');
    return hasPermission;
  }

  static AudioOutputFormat _convertStringInAudioOutputFormat(String extension) {
    switch (extension) {
      case ".wav":
        return AudioOutputFormat.WAV;
      case ".mp4":
      case ".aac":
      case ".m4a":
        return AudioOutputFormat.AAC;
      default:
        return null;
    }
  }

  static bool _isAudioOutputFormat(String extension) {
    switch (extension) {
      case ".wav":
      case ".mp4":
      case ".aac":
      case ".m4a":
        return true;
      default:
        return false;
    }
  }

  static String _convertAudioOutputFormatInString(
      AudioOutputFormat outputFormat) {
    switch (outputFormat) {
      case AudioOutputFormat.WAV:
        return ".wav";
      case AudioOutputFormat.AAC:
        return ".m4a";
      default:
        return ".m4a";
    }
  }
}

enum AudioOutputFormat { AAC, WAV }

class Recording {
  // File path
  String path;
  // File extension
  String extension;
  // Audio duration in milliseconds
  Duration duration;
  // Audio output format
  AudioOutputFormat audioOutputFormat;

  Recording({this.duration, this.path, this.audioOutputFormat, this.extension});
}