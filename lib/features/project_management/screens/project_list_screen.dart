import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../providers/project_provider.dart';
import 'project_create_screen.dart';
import 'project_detail_screen.dart';
import '../../../core/widgets/project_type_icon.dart';
import '../../../core/widgets/status_badge.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects     = ref.watch(filteredProjectsProvider);
    final currentFilter = ref.watch(projectFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildSearchBar(),
            _buildFilterTabs(currentFilter),
            Expanded(
              child: projects.isEmpty
                  ? _buildEmptyState()
                  : _buildList(projects),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'All Projects',
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Map view coming soon'))),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.map_outlined,
                  color: AppColors.textSecondary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    ref.read(projectSearchProvider.notifier).state = v,
                decoration: const InputDecoration(
                  hintText: 'Search projects...',
                  hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
            if (_searchCtrl.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  ref.read(projectSearchProvider.notifier).state = '';
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.close, size: 18, color: AppColors.textTertiary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Filter tabs (All / Ongoing / Planned / Completed) ───────────────────
  Widget _buildFilterTabs(ProjectFilter current) {
    const tabs = [
      (ProjectFilter.all,       'All'),
      (ProjectFilter.ongoing,   'Ongoing'),
      (ProjectFilter.planned,   'Planned'),
      (ProjectFilter.completed, 'Completed'),
    ];
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: tabs.map((t) {
          final (filter, label) = t;
          final active = current == filter;
          return GestureDetector(
            onTap: () =>
                ref.read(projectFilterProvider.notifier).state = filter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Text(label,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textSecondary,
                )),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Project list ────────────────────────────────────────────────────────
  Widget _buildList(List<ProjectModel> projects) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _ProjectListCard(
        project: projects[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(projectId: projects[i].id),
          ),
        ),
      ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined,
              size: 72, color: AppColors.textTertiary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('No projects found',
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              )),
        ],
      ),
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProjectCreateScreen()),
      ),
      backgroundColor: AppColors.accent,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Add Project',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }
}

// ─── Individual project card ──────────────────────────────────────────────────
class _ProjectListCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  const _ProjectListCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ProjectTypeIcon(type: project.type, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        '${project.budgetFormatted} • ${project.deadlineLabel}',
                        style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: project.status),
              ],
            ),
            const SizedBox(height: 12),
            _ProgressBar(percent: project.progressPercent, status: project.status),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int percent;
  final ProjectStatus status;
  const _ProgressBar({required this.percent, required this.status});

  Color get _color {
    if (status == ProjectStatus.completed) return AppColors.accentDark;
    if (percent >= 60) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: percent / 100,
        minHeight: 6,
        backgroundColor: AppColors.borderLight,
        valueColor: AlwaysStoppedAnimation<Color>(_color),
      ),
    );
  }
}
