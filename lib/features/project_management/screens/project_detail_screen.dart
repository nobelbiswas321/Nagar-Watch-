import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../providers/project_provider.dart';
import '../../../core/widgets/status_badge.dart';
import 'project_update_screen.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref
        .watch(projectsProvider)
        .firstWhere((p) => p.id == projectId, orElse: () => kSampleProjects.first);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, project),
            SliverToBoxAdapter(child: _buildHero(project)),
            SliverToBoxAdapter(child: _buildStats(project)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDescCard(project),
                    const SizedBox(height: 12),
                    _buildLocationCard(project),
                    const SizedBox(height: 12),
                    _buildMilestonesCard(project),
                    const SizedBox(height: 20),
                    _buildEvidenceBtn(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, ProjectModel project) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white.withOpacity(0.9),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
      title: const Text('Project Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, letterSpacing: -0.3)),
      actions: [
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Report shared!'))),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.share_outlined, size: 18, color: AppColors.textSecondary),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProjectUpdateScreen(projectId: project.id))),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  // ─── Hero card (gradient) ─────────────────────────────────────────────────
  Widget _buildHero(ProjectModel project) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1B3D),
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30, bottom: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(status: project.status, onDark: true),
              const SizedBox(height: 12),
              Text(project.name,
                  style: const TextStyle(
                    fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white,
                  )),
              const SizedBox(height: 6),
              Text(project.location,
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 3-stat row ───────────────────────────────────────────────────────────
  Widget _buildStats(ProjectModel project) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _StatCard(label: 'Budget',   value: project.budgetFormatted),
          const SizedBox(width: 10),
          _StatCard(label: 'Deadline', value: project.deadlineLabel),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Progress',
            value: '${project.progressPercent}%',
            valueColor: _progressColor(project.progressPercent),
          ),
        ],
      ),
    );
  }

  // ─── Description ──────────────────────────────────────────────────────────
  Widget _buildDescCard(ProjectModel project) {
    return _SectionCard(
      title: '📝 Description',
      child: Text(
        project.description.isEmpty ? 'No description provided.' : project.description,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
      ),
    );
  }

  // ─── Location & Geofence ──────────────────────────────────────────────────
  Widget _buildLocationCard(ProjectModel project) {
    return _SectionCard(
      title: '📍 Location & Geofence (FR-3.1)',
      child: Column(
        children: [
          _MapPlaceholder(geofenceSize: 100),
          const SizedBox(height: 10),
          Text(
            'Geofence radius: ${project.geofenceRadius.toInt()}m • Enter zone for notifications',
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
          if (project.contractorName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Text('Contractor: ${project.contractorName}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Milestones ───────────────────────────────────────────────────────────
  Widget _buildMilestonesCard(ProjectModel project) {
    return _SectionCard(
      title: '📊 Milestones',
      child: Column(
        children: project.milestones.isEmpty
            ? [const Text('No milestones defined.',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 13))]
            : project.milestones.map((m) => _MilestoneRow(milestone: m)).toList(),
      ),
    );
  }

  // ─── Evidence button ──────────────────────────────────────────────────────
  Widget _buildEvidenceBtn(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Navigate to evidence upload'))),
      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
      label: const Text('Upload Evidence',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }

  Color _progressColor(int pct) {
    if (pct >= 80) return AppColors.accentDark;
    if (pct >= 40) return AppColors.warning;
    return AppColors.primaryLight;
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatCard({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary, letterSpacing: 0.5,
                )),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
          )),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Map placeholder with animated geofence circle ───────────────────────────
class _MapPlaceholder extends StatefulWidget {
  final double geofenceSize;
  const _MapPlaceholder({required this.geofenceSize});
  @override
  State<_MapPlaceholder> createState() => _MapPlaceholderState();
}

class _MapPlaceholderState extends State<_MapPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.03)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F2FE), Color(0xFFDBEAFE), Color(0xFFE0E7FF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size.infinite, painter: _GridPainter()),
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: widget.geofenceSize,
              height: widget.geofenceSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withOpacity(0.08),
                border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.6), width: 2.5),
              ),
              child: Center(
                child: Container(
                  width: 14, height: 14,
                  decoration: const BoxDecoration(
                      color: AppColors.primaryLight, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Milestone row ────────────────────────────────────────────────────────────
class _MilestoneRow extends StatelessWidget {
  final MilestoneModel milestone;
  const _MilestoneRow({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final (dotColor, dotIcon) = switch (milestone.state) {
      MilestoneState.completed => (AppColors.accent, Icons.check),
      MilestoneState.current   => (AppColors.warning, Icons.sync),
      MilestoneState.pending   => (Colors.transparent, null),
    };
    final isPending = milestone.state == MilestoneState.pending;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPending ? Colors.transparent : dotColor,
              border: isPending
                  ? Border.all(color: AppColors.border, width: 2)
                  : null,
            ),
            child: dotIcon != null
                ? Icon(dotIcon, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              milestone.title,
              style: TextStyle(
                fontSize: 14,
                color: isPending ? AppColors.textTertiary : AppColors.textPrimary,
                fontWeight: milestone.state == MilestoneState.current
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
          Text(
            milestone.targetDate,
            style: TextStyle(
              fontSize: 12,
              color: milestone.state == MilestoneState.current
                  ? AppColors.warning
                  : AppColors.textTertiary,
              fontWeight: milestone.state == MilestoneState.current
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.04)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
