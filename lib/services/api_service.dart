import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class ApiService {
  static const String apiUrl = 'http://nrweb.com.mx/prueba_ws/familia.php';

  Future<List<Usuario>> fetchUsuarios() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['estatus'] == 200 && data['usuarios'] != null) {
          List<dynamic> usuariosJson = data['usuarios'];
          return usuariosJson.map((json) => Usuario.fromJson(json)).toList();
        } else {
          throw Exception('Error en la respuesta de la API');
        }
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}