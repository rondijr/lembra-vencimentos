import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/categories.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/domain/entities/user.dart' as app_user;
import '../../domain/entities/deadline.dart';
import '../../data/repositories/deadlines_sync_repository.dart';
import '../../../../core/services/supabase_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storageService = StorageService();
  final _userService = UserService();
  late final DeadlinesSyncRepository _repository;

  app_user.User? _user;
  List<Deadline> _deadlines = [];
  bool _isLoading = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _repository = DeadlinesSyncRepository(
      storageService: _storageService,
      supabaseService: SupabaseService(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Carrega usuário
      final userId = await _storageService.getString('user_id');
      if (userId != null) {
        final user = await _userService.getUser(userId);
        if (user != null) {
          setState(() => _user = user);
        }
      }

      // Carrega prazos
      final deadlines = await _repository.loadDeadlines();
      setState(() => _deadlines = deadlines);
    } catch (e) {
      print('❌ Erro ao carregar dados do perfil: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null && _user != null) {
        setState(() => _imageFile = File(pickedFile.path));

        // Atualiza usuário com o caminho local da foto
        // NOTA: Upload no Supabase Storage requer configuração do bucket "user-photos"
        // Para habilitar: criar bucket público no Supabase Dashboard > Storage

        final updatedUser = _user!.copyWith(
          photoUrl: pickedFile.path,
        );

        await _userService.updateUser(updatedUser);
        setState(() => _user = updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto atualizada!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        /* CÓDIGO PARA UPLOAD NO SUPABASE STORAGE (quando configurado):
        try {
          final supabase = Supabase.instance.client;
          final userId = _user!.id;
          final fileExt = pickedFile.path.split('.').last;
          final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          final filePath = '$userId/$fileName';
          
          await supabase.storage
              .from('user-photos')
              .upload(filePath, File(pickedFile.path));
          
          final photoUrl = supabase.storage
              .from('user-photos')
              .getPublicUrl(filePath);
          
          final updatedUser = _user!.copyWith(photoUrl: photoUrl);
          await _userService.updateUser(updatedUser);
          setState(() => _user = updatedUser);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto atualizada no Supabase!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          print('❌ Erro no upload Supabase: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao fazer upload: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        */
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    if (_user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const Text(
          'Remover Foto',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deseja realmente remover sua foto de perfil?',
          style: TextStyle(color: AppColors.onSlate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _imageFile = null;
      });

      // Atualiza o usuário removendo a foto
      final updatedUser = _user!.copyWith(clearPhoto: true);
      await _userService.updateUser(updatedUser);
      setState(() => _user = updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto removida'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.blue),
              title: const Text(
                'Tirar Foto',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.blue),
              title: const Text(
                'Escolher da Galeria',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imageFile != null || _user?.photoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remover Foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.slate,
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: AppColors.blue,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.blue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.slate,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              if (_user != null) {
                final result = await Navigator.push<app_user.User>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(user: _user!),
                  ),
                );

                if (result != null && mounted) {
                  setState(() => _user = result);
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.blue,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Foto do perfil
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.blue,
                            AppColors.blue.withValues(alpha: 0.6)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: _imageFile != null
                          ? ClipOval(
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                          : _user?.photoUrl != null
                              ? ClipOval(
                                  child: _user!.photoUrl!.startsWith('http')
                                      ? Image.network(
                                          _user!.photoUrl!,
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.white,
                                            );
                                          },
                                        )
                                      : Image.file(
                                          File(_user!.photoUrl!),
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.white,
                                            );
                                          },
                                        ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nome e idade
            Center(
              child: Column(
                children: [
                  Text(
                    _user?.name ?? 'Usuário',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_user?.age ?? 0} anos',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onSlate.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Estatísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  icon: Icons.calendar_today,
                  label: 'Prazos\nAtivos',
                  value: '${_deadlines.length}',
                  color: AppColors.blue,
                ),
                _buildStatCard(
                  icon: Icons.warning_amber,
                  label: 'Vencendo\nHoje',
                  value: '${_getExpiringToday()}',
                  color: Colors.orange,
                ),
                _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Em\nDia',
                  value: '${_getUpcoming()}',
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Prazos por Categoria
            const Text(
              'Prazos por Categoria',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            ..._buildCategoryStats(),

            const SizedBox(height: 32),

            // Título dos lembretes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meus Lembretes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${_deadlines.length} total',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSlate.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Lista de lembretes
            if (_deadlines.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 48,
                      color: AppColors.onSlate.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum lembrete cadastrado',
                      style: TextStyle(
                        color: AppColors.onSlate.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._deadlines.map((deadline) => _buildDeadlineCard(deadline)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.onSlate.withValues(alpha: 0.7),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineCard(Deadline deadline) {
    final now = DateTime.now();
    final difference = deadline.date.difference(now).inDays;

    // Busca categoria e cor
    final category = Categories.findBySubcategory(deadline.category);
    final categoryColor = category?.color ?? Colors.grey;
    final categoryIcon = category?.icon ?? Icons.description;

    Color urgencyColor;
    String urgencyText;

    if (difference < 0) {
      urgencyColor = Colors.red;
      urgencyText = 'VENCIDO';
    } else if (difference == 0) {
      urgencyColor = Colors.orange;
      urgencyText = 'HOJE';
    } else if (difference <= 7) {
      urgencyColor = Colors.yellow;
      urgencyText = '$difference dias';
    } else {
      urgencyColor = Colors.green;
      urgencyText = '$difference dias';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.2),
            categoryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: categoryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        categoryIcon,
                        size: 12,
                        color: categoryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        deadline.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: urgencyColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              urgencyText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: urgencyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryStats() {
    if (_deadlines.isEmpty) return [];

    // Agrupar prazos por categoria
    final Map<String, int> categoryCounts = {};
    for (final deadline in _deadlines) {
      final cat = Categories.findBySubcategory(deadline.category);
      if (cat != null) {
        categoryCounts[cat.id] = (categoryCounts[cat.id] ?? 0) + 1;
      }
    }

    // Ordenar por quantidade (decrescente)
    final sortedEntries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Criar lista de widgets
    return sortedEntries.map((entry) {
      final cat = Categories.getById(entry.key);
      final count = entry.value;
      final percentage = (count / _deadlines.length * 100).toStringAsFixed(0);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cat.color.withValues(alpha: 0.15),
              cat.color.withValues(alpha: 0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cat.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(cat.icon, color: cat.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: count / _deadlines.length,
                            child: Container(
                              decoration: BoxDecoration(
                                color: cat.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cat.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cat.color,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  int _getExpiringToday() {
    final now = DateTime.now();
    return _deadlines.where((d) {
      final difference = d.date.difference(now).inDays;
      return difference == 0;
    }).length;
  }

  int _getUpcoming() {
    final now = DateTime.now();
    return _deadlines.where((d) {
      final difference = d.date.difference(now).inDays;
      return difference > 0;
    }).length;
  }
}
