class Usuario {
  int? id;
  String nombre;
  String apellidoMaterno;
  String apellidoPaterno;
  int edad;
  String tios;
  String hermanos;
  String padres;
  String abuelos;
  String estadoCivil;
  String esposa;

  Usuario({
    this.id,
    required this.nombre,
    required this.apellidoMaterno,
    required this.apellidoPaterno,
    required this.edad,
    required this.tios,
    required this.hermanos,
    required this.padres,
    required this.abuelos,
    required this.estadoCivil,
    required this.esposa,
  });

  // Convertir de JSON a Usuario
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'] ?? '',
      apellidoMaterno: json['apellido_materno'] ?? '',
      apellidoPaterno: json['apellido_paterno'] ?? '',
      edad: json['edad'] ?? 0,
      tios: (json['familia']['tios'] as List?)?.where((e) => e != null).join(', ') ?? '',
      hermanos: (json['familia']['hermanos'] as List?)?.where((e) => e != null).join(', ') ?? '',
      padres: (json['familia']['padres'] as List?)?.where((e) => e != null).join(', ') ?? '',
      abuelos: (json['familia']['abuelos'] as List?)?.where((e) => e != null).join(', ') ?? '',
      estadoCivil: json['familia']['casado']['estado_civil'] ?? 'no',
      esposa: (json['familia']['casado']['esposa'] as List?)?.where((e) => e != null).join(', ') ?? '',
    );
  }

  // Convertir Usuario a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido_materno': apellidoMaterno,
      'apellido_paterno': apellidoPaterno,
      'edad': edad,
      'tios': tios,
      'hermanos': hermanos,
      'padres': padres,
      'abuelos': abuelos,
      'estado_civil': estadoCivil,
      'esposa': esposa,
    };
  }

  // Convertir Map a Usuario (desde SQLite)
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      apellidoMaterno: map['apellido_materno'],
      apellidoPaterno: map['apellido_paterno'],
      edad: map['edad'],
      tios: map['tios'],
      hermanos: map['hermanos'],
      padres: map['padres'],
      abuelos: map['abuelos'],
      estadoCivil: map['estado_civil'],
      esposa: map['esposa'],
    );
  }

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}