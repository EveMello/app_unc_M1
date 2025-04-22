import 'package:flutter/material.dart';
import 'package:app_m1/helpers/db_helper.dart';
import 'package:app_m1/models/cliente.dart';

class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({super.key});

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();

  List<Cliente> _clientes = [];
  Cliente? _clienteEditando;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final clientes = await DBHelper().getClientes();
    setState(() {
      _clientes = clientes;
    });
  }

  Future<void> _salvarCadastro() async {
    if (_formKey.currentState!.validate()) {
      if (_clienteEditando != null) {
        final clienteAtualizado = Cliente(
          id: _clienteEditando!.id,
          nome: _nomeController.text,
          telefone: _telefoneController.text,
          endereco: _enderecoController.text,
        );
        await DBHelper().atualizarCliente(clienteAtualizado);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente atualizado com sucesso!')),
        );
      } else {
        final novoCliente = Cliente(
          nome: _nomeController.text,
          telefone: _telefoneController.text,
          endereco: _enderecoController.text,
        );
        await DBHelper().inserirCliente(novoCliente);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente cadastrado com sucesso!')),
        );
      }

      _limparFormulario();
      _carregarClientes();
    }
  }

  void _editarCliente(Cliente cliente) {
    setState(() {
      _clienteEditando = cliente;
      _nomeController.text = cliente.nome;
      _telefoneController.text = cliente.telefone;
      _enderecoController.text = cliente.endereco;
    });
  }

  Future<void> _excluirCliente(int id) async {
    await DBHelper().deletarCliente(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cliente excluído com sucesso!')),
    );
    _limparFormulario();
    _carregarClientes();
  }

  void _limparFormulario() {
    _clienteEditando = null;
    _nomeController.clear();
    _telefoneController.clear();
    _enderecoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Cadastro de Cliente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Informações do Cliente',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o nome do cliente';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefoneController,
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o telefone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _enderecoController,
                        decoration: InputDecoration(
                          labelText: 'Endereço',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o endereço';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _salvarCadastro,
                        icon: Icon(_clienteEditando != null
                            ? Icons.save_as
                            : Icons.check),
                        label: Text(
                          _clienteEditando != null ? 'Atualizar' : 'Salvar',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (_clienteEditando != null)
                        TextButton(
                          onPressed: _limparFormulario,
                          child: const Text('Cancelar edição'),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            if (_clientes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clientes Cadastrados',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = _clientes[index];
                      return Card(
                        child: ListTile(
                          title: Text(cliente.nome),
                          subtitle: Text(
                            'Telefone: ${cliente.telefone}\nEndereço: ${cliente.endereco}',
                          ),
                          isThreeLine: true,
                          leading: const Icon(Icons.person),
                          trailing: Wrap(
                            spacing: 12,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editarCliente(cliente),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _excluirCliente(cliente.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            else
              const Text(
                'Nenhum cliente cadastrado.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
