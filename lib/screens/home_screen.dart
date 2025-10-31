import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../database/database_helper.dart';
import '../services/api_service.dart';
import 'edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Usuario> _usuarios = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final usuarios = await DatabaseHelper.instance.getAllUsuarios();
      setState(() {
        _usuarios = usuarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarError('Error al cargar usuarios: $e');
    }
  }

  Future<void> _cargarDesdeAPI() async {
    setState(() => _isLoading = true);
    try {
      final usuarios = await _apiService.fetchUsuarios();
      
      // Limpiar base de datos antes de insertar nuevos datos
      await DatabaseHelper.instance.clearAllUsuarios();
      
      // Insertar usuarios desde la API
      await DatabaseHelper.instance.insertMultipleUsuarios(usuarios);
      
      // Recargar la lista
      await _cargarUsuarios();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${usuarios.length} usuarios cargados desde la API')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarError('Error al cargar desde API: $e');
    }
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _eliminarFamiliar(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Deseas eliminar a ${usuario.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && usuario.id != null) {
      await DatabaseHelper.instance.deleteUsuario(usuario.id!);
      await _cargarUsuarios();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Familiar eliminado correctamente')),
        );
      }
    }
  }

  Future<void> _editarUsuario(Usuario usuario) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(usuario: usuario),
      ),
    );

    if (resultado == true) {
      await _cargarUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Familiar'),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
              ? _buildEmptyState()
              : _buildUserList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cargarDesdeAPI,
        icon: const Icon(Icons.cloud_download),
        label: const Text('Cargar desde API'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No hay usuarios registrados',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _cargarDesdeAPI,
            icon: const Icon(Icons.cloud_download),
            label: const Text('Cargar desde API'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _usuarios.length,
      itemBuilder: (context, index) {
        final usuario = _usuarios[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                usuario.nombre[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              usuario.nombreCompleto,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edad: ${usuario.edad} años'),
                Text('Estado: ${usuario.estadoCivil == "si" ? "Casado" : "Soltero"}'),
                if (usuario.padres.isNotEmpty)
                  Text('Padres: ${usuario.padres}', 
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editarUsuario(usuario),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarFamiliar(usuario),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}