##services/producto_service.dart

  import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto.dart';

class ProductoService {
  final _db = Supabase.instance.client.from('productos');
  final _storage = Supabase.instance.client.storage.from('productos');

  // ── Listar todos ──────────────────────────────
  Future<List<Producto>> listar() async {
    final data = await _db.select().order('created_at', ascending: false);
    return (data as List).map((e) => Producto.fromMap(e)).toList();
  }

  // ── Subir imagen ──────────────────────────────
  Future<String?> subirImagen(File imagen) async {
    final nombre = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _storage.upload(nombre, imagen);
    return _storage.getPublicUrl(nombre);
  }

  // ── Crear producto ────────────────────────────
  Future<void> crear(Producto producto) async {
    await _db.insert(producto.toMap());
  }

  // ── Eliminar producto ─────────────────────────
  Future<void> eliminar(String id) async {
    await _db.delete().eq('id', id);
  }
}
