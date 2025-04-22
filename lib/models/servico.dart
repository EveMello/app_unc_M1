class Servico {
  final int? id;
  final int clienteId;
  final String descricao;
  final String data;
  final double horas;
  final double valorUnitario;
  final double valorTotal;

  Servico({
    this.id,
    required this.clienteId,
    required this.descricao,
    required this.data,
    required this.horas,
    required this.valorUnitario,
    required this.valorTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'descricao': descricao,
      'data': data,
      'horas': horas,
      'valor_unitario': valorUnitario,
      'valor_total': valorTotal,
    };
  }

  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'],
      clienteId: map['cliente_id'],
      descricao: map['descricao'],
      data: map['data'],
      horas: map['horas'],
      valorUnitario: map['valor_unitario'],
      valorTotal: map['valor_total'],
    );
  }
}
