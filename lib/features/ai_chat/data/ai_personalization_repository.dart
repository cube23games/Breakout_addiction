import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/ai_personalization_settings.dart';

class AiPersonalizationRepository {
  static const _key='ai_personalization_settings_v1';
  const AiPersonalizationRepository({FlutterSecureStorage? storage}):_storage=storage??const FlutterSecureStorage();
  final FlutterSecureStorage _storage;
  Future<AiPersonalizationSettings> getSettings()async{
    final raw=await _storage.read(key:_key); if(raw==null||raw.isEmpty)return AiPersonalizationSettings.defaults();
    try{final decoded=jsonDecode(raw);if(decoded is Map)return AiPersonalizationSettings.fromMap(decoded.map((k,v)=>MapEntry(k.toString(),v)));}catch(_){ }
    return AiPersonalizationSettings.defaults();
  }
  Future<void> save(AiPersonalizationSettings settings)=>_storage.write(key:_key,value:jsonEncode(settings.toMap()));
  Future<void> clear()=>_storage.delete(key:_key);
}
