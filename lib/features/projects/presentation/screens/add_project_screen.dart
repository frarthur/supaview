import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supaview/features/projects/domain/entities/project.dart';
import 'package:supaview/features/projects/presentation/providers/project_providers.dart';

class AddProjectScreen extends ConsumerStatefulWidget {
  const AddProjectScreen({super.key, this.project});

  final Project? project;

  @override
  ConsumerState<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends ConsumerState<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _anonKeyController;
  late final TextEditingController _serviceRoleKeyController;
  String _selectedColor = '#6366F1';
  bool _isTesting = false;
  bool? _testResult;

  final _availableColors = [
    '#6366F1',
    '#EF4444',
    '#F59E0B',
    '#10B981',
    '#3B82F6',
    '#8B5CF6',
    '#EC4899',
    '#14B8A6',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _urlController = TextEditingController(
      text: widget.project?.supabaseUrl ?? '',
    );
    _anonKeyController = TextEditingController(
      text: widget.project?.anonKey ?? '',
    );
    _serviceRoleKeyController = TextEditingController(
      text: widget.project?.serviceRoleKey ?? '',
    );
    if (widget.project != null) {
      _selectedColor = widget.project!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _anonKeyController.dispose();
    _serviceRoleKeyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final project = Project(
      id: widget.project?.id ?? '',
      name: _nameController.text,
      supabaseUrl: _urlController.text,
      anonKey: _anonKeyController.text,
      serviceRoleKey: _serviceRoleKeyController.text.isNotEmpty
          ? _serviceRoleKeyController.text
          : null,
      color: _selectedColor,
    );

    final repository = ref.read(projectRepositoryProvider);
    final result = await repository.testConnection(project);

    setState(() {
      _isTesting = false;
      _testResult = result;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final project = Project(
      id: widget.project?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      supabaseUrl: _urlController.text,
      anonKey: _anonKeyController.text,
      serviceRoleKey: _serviceRoleKeyController.text.isNotEmpty
          ? _serviceRoleKeyController.text
          : null,
      color: _selectedColor,
      createdAt: widget.project?.createdAt ?? DateTime.now(),
    );

    final repository = ref.read(projectRepositoryProvider);
    await repository.saveProject(project);
    ref.invalidate(projectListProvider);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Project' : 'Add Project'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'My Supabase Project',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (v) => (v?.isEmpty ?? false) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Supabase URL',
                hintText: 'https://xyz.supabase.co',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v?.isEmpty ?? false) return 'URL is required';
                if (!v!.startsWith('https://')) return 'Must start with https://';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _anonKeyController,
              decoration: const InputDecoration(
                labelText: 'Anon Key',
                hintText: 'eyJhbGciOiJIUzI1NiIs...',
                prefixIcon: Icon(Icons.key),
              ),
              maxLines: 2,
              validator: (v) => (v?.isEmpty ?? false) ? 'Anon key is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceRoleKeyController,
              decoration: const InputDecoration(
                labelText: 'Service Role Key (optional)',
                hintText: 'eyJhbGciOiJIUzI1NiIs...',
                prefixIcon: Icon(Icons.admin_panel_settings),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Text(
              'Project Color',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((colorHex) {
                final isSelected = _selectedColor == colorHex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorHex),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(colorHex.replaceFirst('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _testResult == null
                            ? Icons.wifi_find
                            : _testResult!
                                ? Icons.check_circle
                                : Icons.error,
                        color: _testResult == null
                            ? null
                            : (_testResult ?? false)
                                ? Colors.green
                                : Colors.red,
                      ),
                label: Text(
                  _isTesting
                      ? 'Testing...'
                      : _testResult == null
                          ? 'Test Connection'
                          : (_testResult ?? false)
                              ? 'Connection Successful'
                              : 'Connection Failed',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
