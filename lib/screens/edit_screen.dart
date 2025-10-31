import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../database/database_helper.dart';

class EditScreen extends StatefulWidget {
  final Usuario usuario;

  const EditScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoPaternoController;
  late TextEditingController _apellidoMaternoController;
  late TextEditingController _edadController;
  late TextEditingController _tiosController;
  late TextEditingController _hermanosController;
  late TextEditingController _padresController;
  late TextEditingController _abuelosController;
  late TextEditingController _esposaController;
  late String _estadoCivil;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _apellidoPaternoController = TextEditingController(text: widget.usuario.apellidoPaterno);
    _apellidoMaternoController = TextEditingController(text: widget.usuario.apellidoMaterno);
    _edadController = TextEditingController(text: widget.usuario.edad.toString());
    _tiosController = TextEditingController(text: widget.usuario.tios);
    _hermanosController = TextEditingController(text: widget.usuario.hermanos);
    _padresController = TextEditingController(text: widget.usuario.padres);
    _abuelosController = TextEditingController(text: widget.usuario.abuelos);
    _esposaController = TextEditingController(text: widget.usuario.esposa);
    _estadoCivil = widget.usuario.estadoCivil;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _edadController.dispose();
    _tiosController.dispose();
    _hermanosController.dispose();
    _padresController.dispose();
    _abuelosController.dispose();
    _esposaController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final usuarioActualizado = Usuario(
        id: widget.usuario.id,
        nombre: _nombreController.text,
        apellidoPaterno: _apellidoPaternoController.text,
        apellidoMaterno: _apellidoMaternoController.text,
        edad: int.parse(_edadController.text),
        tios: _tiosController.text,
        hermanos: _hermanosController.text,
        padres: _padresController.text,
        abuelos: _abuelosController.text,
        estadoCivil: _estadoCivil,
        esposa: _esposaController.text,
      );

      await DatabaseHelper.instance.updateUsuario(usuarioActualizado);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado correctamente')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarCambios,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apellidoPaternoController,
              decoration: const InputDecoration(
                labelText: 'Apellido Paterno',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apellidoMaternoController,
              decoration: const InputDecoration(
                labelText: 'Apellido Materno',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _edadController,
              decoration: const InputDecoration(
                labelText: 'Edad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Campo requerido';
                if (int.tryParse(value!) == null) return 'Debe ser un número';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _padresController,
              decoration: const InputDecoration(
                labelText: 'Padres (separados por coma)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hermanosController,
              decoration: const InputDecoration(
                labelText: 'Hermanos (separados por coma)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tiosController,
              decoration: const InputDecoration(
                labelText: 'Tíos (separados por coma)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _abuelosController,
              decoration: const InputDecoration(
                labelText: 'Abuelos (separados por coma)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _estadoCivil,
              decoration: const InputDecoration(
                labelText: 'Estado Civil',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'si', child: Text('Casado')),
                DropdownMenuItem(value: 'no', child: Text('Soltero')),
              ],
              onChanged: (value) {
                setState(() {
                  _estadoCivil = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_estadoCivil == 'si')
              TextFormField(
                controller: _esposaController,
                decoration: const InputDecoration(
                  labelText: 'Esposa/o',
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}