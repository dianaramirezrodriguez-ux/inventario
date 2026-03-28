##lib/pantalla_inventario.dart

  import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/producto.dart';
import 'services/producto_service.dart';

class PantallaInventario extends StatefulWidget {
  const PantallaInventario({super.key});
  @override
  State<PantallaInventario> createState() => _PantallaInventarioState();
}

class _PantallaInventarioState extends State<PantallaInventario> {
  final _service = ProductoService();
  List<Producto> _productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() => _cargando = true);
    _productos = await _service.listar();
    setState(() => _cargando = false);
  }

  Future<void> _eliminar(String id) async {
    await _service.eliminar(id);
    _cargarProductos();
  }

  void _abrirFormulario() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FormularioProducto(
        onGuardado: () {
          Navigator.pop(context);
          _cargarProductos();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📦 Inventario'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _productos.isEmpty
              ? const Center(child: Text('Sin productos aún'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _productos.length,
                  itemBuilder: (_, i) {
                    final p = _productos[i];
                    return Card(
                      child: ListTile(
                        leading: p.imagenUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  p.imagenUrl!,
                                  width: 56, height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.inventory_2, size: 40),
                        title: Text(p.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '\$${p.precio.toStringAsFixed(2)} · Stock: ${p.stock}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _eliminar(p.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ── Formulario ────────────────────────────────────────────────
class FormularioProducto extends StatefulWidget {
  final VoidCallback onGuardado;
  const FormularioProducto({super.key, required this.onGuardado});
  @override
  State<FormularioProducto> createState() => _FormularioProductoState();
}

class _FormularioProductoState extends State<FormularioProducto> {
  final _nombre = TextEditingController();
  final _precio = TextEditingController();
  final _stock = TextEditingController();
  File? _imagen;
  bool _guardando = false;
  final _service = ProductoService();

  Future<void> _seleccionarImagen() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _imagen = File(picked.path));
  }

  Future<void> _guardar() async {
    if (_nombre.text.isEmpty || _precio.text.isEmpty) return;

    setState(() => _guardando = true);

    String? imagenUrl;
    if (_imagen != null) {
      imagenUrl = await _service.subirImagen(_imagen!);
    }

    await _service.crear(Producto(
      id: '',
      nombre: _nombre.text.trim(),
      precio: double.parse(_precio.text),
      stock: int.tryParse(_stock.text) ?? 0,
      imagenUrl: imagenUrl,
    ));

    widget.onGuardado();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Nuevo Producto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Imagen
          GestureDetector(
            onTap: _seleccionarImagen,
            child: Container(
              height: 120, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: _imagen != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imagen!, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 36, color: Colors.grey),
                        Text('Toca para agregar imagen'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),

          TextField(controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(controller: _precio, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio', border: OutlineInputBorder())),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(controller: _stock, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder())),
            ),
          ]),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Guardar producto'),
            ),
          ),
        ],
      ),
    );
  }
}


