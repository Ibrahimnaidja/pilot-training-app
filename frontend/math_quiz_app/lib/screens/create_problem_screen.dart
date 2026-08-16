import 'package:flutter/material.dart';

import '../services/api_client.dart';

class CreateProblemScreen extends StatefulWidget {
  final ApiClient api;
  const CreateProblemScreen({super.key, required this.api});

  @override
  State<CreateProblemScreen> createState() => _CreateProblemScreenState();
}

class _CreateProblemScreenState extends State<CreateProblemScreen> {
  final _num1Controller = TextEditingController();
  final _num2Controller = TextEditingController();
  String _operator = 'Add';
  bool _submitting = false;
  String? _error;
  List<Problem> _myProblems = [];
  bool _loadingList = true;

  // When set, the form is editing this problem instead of creating a new one.
  Problem? _editingProblem;

  static const _operators = {
    'Add': '+',
    'Subtract': '\u2212',
    'Multiply': '\u00d7',
  };

  @override
  void initState() {
    super.initState();
    _loadMyProblems();
  }

  @override
  void dispose() {
    _num1Controller.dispose();
    _num2Controller.dispose();
    super.dispose();
  }

  Future<void> _loadMyProblems() async {
    setState(() => _loadingList = true);
    try {
      final problems = await widget.api.fetchMyProblems();
      if (!mounted) return;
      setState(() {
        _myProblems = problems;
        _loadingList = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingList = false);
    }
  }

  void _startEditing(Problem problem) {
    setState(() {
      _editingProblem = problem;
      _num1Controller.text = '${problem.num1}';
      _num2Controller.text = '${problem.num2}';
      _operator = problem.operatorSymbol;
      _error = null;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingProblem = null;
      _num1Controller.clear();
      _num2Controller.clear();
      _operator = 'Add';
      _error = null;
    });
  }

  Future<void> _submit() async {
    final num1 = int.tryParse(_num1Controller.text.trim());
    final num2 = int.tryParse(_num2Controller.text.trim());
    if (num1 == null || num2 == null) {
      setState(() => _error = 'Enter two numbers');
      return;
    }
    if (num1 < 1 || num1 > 99 || num2 < 1 || num2 > 99) {
      setState(() => _error = 'Numbers must be between 1 and 99');
      return;
    }
    if (_operator == 'Subtract' && num2 > num1) {
      setState(() => _error = "Subtraction can't go negative — first number must be \u2265 second");
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      if (_editingProblem != null) {
        await widget.api.updateProblem(_editingProblem!.id, num1, num2, _operator);
      } else {
        await widget.api.createProblem(num1, num2, _operator);
      }
      _cancelEditing();
      await _loadMyProblems();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = "Couldn't reach the server.");
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete(Problem problem) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete problem?'),
        content: Text('${problem.displayExpression} = ? will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.api.deleteProblem(problem.id);
      if (_editingProblem?.id == problem.id) _cancelEditing();
      await _loadMyProblems();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't reach the server.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingProblem != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit problem' : 'Create a problem')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Others will be quizzed on this. Keep the numbers reasonable.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _num1Controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'First number', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _operator,
                  items: _operators.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 20))))
                      .toList(),
                  onChanged: (value) => setState(() => _operator = value!),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _num2Controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Second number', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _submitting
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEditing ? 'Save changes' : 'Add problem'),
                    ),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: _submitting ? null : _cancelEditing, child: const Text('Cancel')),
                ],
              ],
            ),
            const SizedBox(height: 32),
            Text('Your problems', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_loadingList)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else if (_myProblems.isEmpty)
              Text("You haven't created any yet.", style: TextStyle(color: Colors.grey.shade600))
            else
              ..._myProblems.map((p) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${p.displayExpression} = ?'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Edit',
                          onPressed: () => _startEditing(p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: 'Delete',
                          onPressed: () => _delete(p),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
