import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;

  static const String _musicKey = "music_volume";
  static const String _sfxKey = "sfx_volume";

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _musicVolume = prefs.getDouble(_musicKey) ?? 0.5;
    _sfxVolume = prefs.getDouble(_sfxKey) ?? 0.7;
    
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);
  }

  Future<void> startBGM() async {
    try {
      await _musicPlayer.play(AssetSource('sound/sound_track.mp3'));
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      debugPrint("Erreur BGM: $e");
    }
  }

  Future<void> pauseBGM() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeBGM() async {
    if (_musicVolume > 0) {
      await _musicPlayer.resume();
    }
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    await _musicPlayer.setVolume(volume);
    if (volume == 0) {
      await _musicPlayer.pause();
    } else {
      if (_musicPlayer.state != PlayerState.playing) {
        await _musicPlayer.resume();
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_musicKey, volume);
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sfxKey, volume);
  }

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> playSFX(String fileName) async {
    try {
      if (_sfxVolume > 0) {
        await _sfxPlayer.setVolume(_sfxVolume);
        await _sfxPlayer.stop(); // Stop previous if playing
        await _sfxPlayer.play(AssetSource('sound/$fileName'));
      }
    } catch (e) {
      debugPrint("Erreur SFX ($fileName): $e");
    }
  }

  Future<void> playCorrect() => playSFX('correct.mp3');
  Future<void> playWrong() => playSFX('wrong.mp3');
  Future<void> playGameOver() => playSFX('game_over.mp3');
}
