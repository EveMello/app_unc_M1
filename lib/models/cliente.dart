class Cliente {
  final int? id;
  final String nome;
  final String telefone;
  final String endereco;

  Cliente({
    this.id,
    required this.nome,
    required this.telefone,
    required this.endereco,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'endereco': endereco,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nome: map['nome'],
      telefone: map['telefone'],
      endereco: map['endereco'],
    );
  }
}
