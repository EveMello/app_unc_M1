import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CadastroServicoPage extends StatefulWidget {
  const CadastroServicoPage({super.key});

  @override
  State<CadastroServicoPage> createState() => _CadastroServicoPageState();
}

class _CadastroServicoPageState extends State<CadastroServicoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _horasController = TextEditingController();
  final TextEditingController _valorUnitarioController = TextEditingController();
  final TextEditingController _valorTotalController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  late Database _database;
  List<Map<String, dynamic>> _servicos = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'servicos.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE servicos(id INTEGER PRIMARY KEY AUTOINCREMENT, cliente TEXT, descricao TEXT, data TEXT, horas INTEGER, valor_unitario REAL, valor_total REAL)',
        );
      },
    );

    _loadServicos();
  }

  Future<void> _loadServicos() async {
    final List<Map<String, dynamic>> servicos = await _database.query('servicos');
    setState(() {
      _servicos = servicos;
    });
  }

  void _calcularValorTotal() {
    final horas = double.tryParse(_horasController.text) ?? 0;
    final valorUnitario = double.tryParse(_valorUnitarioController.text) ?? 0;
    final total = horas * valorUnitario;

    _valorTotalController.text = total.toStringAsFixed(2);
  }

  Future<void> _salvarCadastro(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final cliente = _clienteController.text;
      final descricao = _descricaoController.text;
      final data = _dataController.text;
      final horas = double.tryParse(_horasController.text) ?? 0;
      final valorUnitario = double.tryParse(_valorUnitarioController.text) ?? 0;
      final valorTotal = horas * valorUnitario;

      await _database.insert('servicos', {
        'cliente': cliente,
        'descricao': descricao,
        'data': data,
        'horas': horas,
        'valor_unitario': valorUnitario,
        'valor_total': valorTotal,
      });

      _exibirMensagem(context, 'Serviço cadastrado com sucesso!');

      _clienteController.clear();
      _descricaoController.clear();
      _dataController.clear();
      _horasController.clear();
      _valorUnitarioController.clear();
      _valorTotalController.clear();

      _loadServicos(); 
    }
  }

  void _exibirMensagem(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _selecionarData(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      _dataController.text = _dateFormat.format(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Cadastro de Serviço'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Informações do Serviço',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _clienteController,
                          decoration: _inputDecoration('Cliente', Icons.person),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Informe o cliente' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descricaoController,
                          decoration: _inputDecoration('Descrição do Serviço', Icons.description),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Informe a descrição' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dataController,
                          readOnly: true,
                          decoration: _inputDecoration('Data', Icons.calendar_today),
                          onTap: () => _selecionarData(context),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Informe a data' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _horasController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Quantidade de Horas', Icons.timer),
                          onChanged: (_) => _calcularValorTotal(),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Informe as horas' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _valorUnitarioController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Valor Unitário', Icons.attach_money),
                          onChanged: (_) => _calcularValorTotal(),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Informe o valor unitário' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _valorTotalController,
                          readOnly: true,
                          decoration: _inputDecoration('Valor Total', Icons.calculate),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _salvarCadastro(context),
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text(
                    'Serviços Cadastrados',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _servicos.isEmpty
                      ? const Text('Nenhum serviço cadastrado.')
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _servicos.length,
                          itemBuilder: (context, index) {
                            final servico = _servicos[index];
                            return ListTile(
                              title: Text(servico['descricao']),
                              subtitle: Text('Cliente: ${servico['cliente']} - Data: ${servico['data']}'),
                              trailing: Text('R\$ ${servico['valor_total']}'),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon),
    );
  }
}
