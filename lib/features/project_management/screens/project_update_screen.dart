import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../providers/project_provider.dart';

class ProjectUpdateScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectUpdateScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectUpdateScreen> createState() => _ProjectUpdateScreenState();
}

class _ProjectUpdateScreenState extends ConsumerState<ProjectUpdateScreen> {
  late ProjectModel _project;

  final _formKey   = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locCtrl;
  late TextEditingController _contrCtrl;

  late ProjectType   _type;
  late ProjectStatus _status;
  late String        _priority;
  late double        _budget;
  late double        _geofence;
  late int           _progress;
  late List<MilestoneModel> _milestones;
  late String        _deadlineDate;

  bool _isLoading = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _project = ref.read(projectsProvider)
        .firstWhere((p) => p.id == widget.projectId,
            orElse: () => kSampleProjects.first);

    _nameCtrl  = TextEditingController(text: _project.name);
    _descCtrl  = TextEditingController(text: _project.description);
    _locCtrl   = TextEditingController(text: _project.location);
    _contrCtrl = TextEditingController(text: _project.contractorName);
    _type      = _project.type;
    _status    = _project.status;
    _priority  = _project.priority;
    _budget    = _project.budgetLakh.clamp(5, 500);
    _geofence  = _project.geofenceRadius.clamp(100, 2000);
    _progress  = _project.progressPercent;
    _milestones = List.from(_project.milestones);
    _deadlineDate = _project.deadlineDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    _locCtrl.dispose();  _contrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      children: [
                        _heading(),
                        const SizedBox(height: 20),
                        _sectionLabel('Project Type'),
                        const SizedBox(height: 10),
                        _typeRow(),
                        const SizedBox(height: 14),
                        _textField('Project Name *', _nameCtrl, required: true),
                        const SizedBox(height: 14),
                        _textArea('Description', _descCtrl),
                        const SizedBox(height: 14),
                        _textField('Project Location', _locCtrl,
                            icon: Icons.location_on_outlined),
                        const SizedBox(height: 14),
                        _textField('Assigned Contractor', _contrCtrl,
                            icon: Icons.person_outline),
                        const SizedBox(height: 18),
                        // ── FR-6.2: Progress & Status ──
                        _sectionLabel('Progress Monitoring (FR-6.2)'),
                        const SizedBox(height: 14),
                        _progressSection(),
                        const SizedBox(height: 18),
                        _statusRow(),
                        const SizedBox(height: 18),
                        _sectionLabel('Milestones (FR-6.2)'),
                        const SizedBox(height: 12),
                        _milestonesEditor(),
                        const SizedBox(height: 18),
                        _sectionLabel('Budget'),
                        const SizedBox(height: 12),
                        _budgetSlider(),
                        const SizedBox(height: 18),
                        _sectionLabel('Geofence Radius (FR-3.1)'),
                        const SizedBox(height: 12),
                        _geofenceSlider(),
                        const SizedBox(height: 18),
                        _deadlinePicker(context),
                        const SizedBox(height: 28),
                        _submitButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showSuccess) _successOverlay(context),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          const Text('Update Project',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _heading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Edit Project Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        SizedBox(height: 4),
        Text('Update info, progress & milestones (FR-2.2, FR-6.2)',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary));

  // ─── Type selector (horizontal scroll) ────────────────────────────────────
  Widget _typeRow() {
    const types = <(ProjectType, String, IconData)>[
      (ProjectType.road,     'Road',     Icons.construction),
      (ProjectType.drainage, 'Drainage', Icons.water_drop_outlined),
      (ProjectType.lighting, 'Lighting', Icons.lightbulb_outline),
      (ProjectType.waste,    'Waste',    Icons.delete_outline),
      (ProjectType.park,     'Park',     Icons.park_outlined),
      (ProjectType.building, 'Building', Icons.apartment_outlined),
    ];
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: types.map((t) {
          final (type, label, icon) = t;
          final active = _type == type;
          return GestureDetector(
            onTap: () => setState(() => _type = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.card,
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16,
                      color: active ? Colors.white : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(label, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.textSecondary,
                  )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Progress slider + percentage ─────────────────────────────────────────
  Widget _progressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Progress',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              Text('$_progress%',
                  style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: _progressColor(_progress),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 10,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(_progressColor(_progress)),
            ),
          ),
          Slider(
            value: _progress.toDouble(),
            min: 0, max: 100, divisions: 20,
            activeColor: _progressColor(_progress),
            inactiveColor: AppColors.borderLight,
            onChanged: (v) => setState(() => _progress = v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0%', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              Text('100%', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Status row ────────────────────────────────────────────────────────────
  Widget _statusRow() {
    const statuses = <(ProjectStatus, String, IconData)>[
      (ProjectStatus.planned,   'Planned',   Icons.schedule),
      (ProjectStatus.ongoing,   'Ongoing',   Icons.construction),
      (ProjectStatus.completed, 'Completed', Icons.check_circle_outline),
      (ProjectStatus.delayed,   'Delayed',   Icons.warning_amber_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Project Status'),
        const SizedBox(height: 10),
        Row(
          children: statuses.map((s) {
            final (st, label, icon) = s;
            final active = _status == st;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _status = st),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.card,
                    border: Border.all(
                        color: active ? AppColors.primary : AppColors.border,
                        width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, size: 18,
                          color: active ? Colors.white : AppColors.textSecondary),
                      const SizedBox(height: 4),
                      Text(label,
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: active ? Colors.white : AppColors.textSecondary,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Milestones editor ────────────────────────────────────────────────────
  Widget _milestonesEditor() {
    return Column(
      children: [
        ..._milestones.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final next = {
                        MilestoneState.pending:   MilestoneState.current,
                        MilestoneState.current:   MilestoneState.completed,
                        MilestoneState.completed: MilestoneState.pending,
                      }[m.state]!;
                      _milestones[i] = MilestoneModel(
                        id: m.id, title: m.title,
                        targetDate: m.targetDate, state: next,
                      );
                    });
                  },
                  child: _milestoneDot(m.state),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(m.title,
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: m.state == MilestoneState.pending
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                        decoration: m.state == MilestoneState.completed
                            ? TextDecoration.lineThrough
                            : null,
                      )),
                ),
                Text(m.targetDate,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _milestones.removeAt(i)),
                  child: const Icon(Icons.close, size: 16, color: AppColors.textTertiary),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _addMilestone,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              border: Border.all(color: AppColors.primary200, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Add Milestone',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _milestoneDot(MilestoneState state) {
    switch (state) {
      case MilestoneState.completed:
        return Container(
          width: 24, height: 24,
          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        );
      case MilestoneState.current:
        return Container(
          width: 24, height: 24,
          decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
          child: const Icon(Icons.sync, size: 14, color: Colors.white),
        );
      case MilestoneState.pending:
        return Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 2),
          ),
        );
    }
  }

  void _addMilestone() async {
    final ctrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Milestone',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Site survey completed',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true, fillColor: AppColors.background,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                setState(() => _milestones.add(MilestoneModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: ctrl.text.trim(),
                  targetDate: 'TBD',
                  state: MilestoneState.pending,
                )));
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Add', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Budget & Geofence sliders ─────────────────────────────────────────────
  Widget _budgetSlider() {
    final display = _budget >= 100
        ? '₹${(_budget / 100) % 1 == 0 ? (_budget / 100).toInt() : (_budget / 100).toStringAsFixed(1)} Cr'
        : '₹${_budget.toInt()} L';
    return _sliderCard(
      value: _budget, min: 5, max: 500, divisions: 99,
      label: display,
      color: AppColors.primary,
      suffix: _budget >= 100 ? 'Crore' : 'Lakh',
      onChanged: (v) => setState(() => _budget = v),
      rangeMin: '₹5 L', rangeMax: '₹5 Cr',
    );
  }

  Widget _geofenceSlider() {
    return _sliderCard(
      value: _geofence, min: 100, max: 2000, divisions: 38,
      label: '${_geofence.toInt()}',
      color: AppColors.accentDark,
      suffix: 'meters',
      onChanged: (v) => setState(() => _geofence = v),
      rangeMin: '100m', rangeMax: '2km',
    );
  }

  Widget _sliderCard({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required String suffix,
    required Color color,
    required ValueChanged<double> onChanged,
    required String rangeMin,
    required String rangeMax,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Center(
            child: RichText(
              text: TextSpan(
                text: '$label ',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color),
                children: [
                  TextSpan(
                    text: suffix,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          Slider(
            value: value, min: min, max: max, divisions: divisions,
            activeColor: color,
            inactiveColor: AppColors.borderLight,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rangeMin, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              Text(rangeMax, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Deadline picker ──────────────────────────────────────────────────────
  Widget _deadlinePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Deadline'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final parts = _deadlineDate.split('-');
            final initial = DateTime(
              int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]),
            );
            final d = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (d != null) {
              setState(() {
                _deadlineDate = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.textTertiary),
                const SizedBox(width: 12),
                Text(_deadlineDate,
                    style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Submit ───────────────────────────────────────────────────────────────
  Widget _submitButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _onSave,
      icon: _isLoading
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.save_outlined, color: Colors.white, size: 20),
      label: Text(_isLoading ? 'Saving...' : 'Save Changes',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
              color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }

  Widget _successOverlay(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              const Text('Project Updated! ✅',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                'Changes synced in real-time (FR-7.1)',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                label: const Text('Back',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Widget _textField(String label, TextEditingController ctrl,
      {bool required = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          validator: required
              ? (v) => v!.trim().isEmpty ? 'Required' : null
              : null,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textTertiary, size: 18)
                : null,
            filled: true, fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5)),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _textArea(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl, maxLines: 3,
          decoration: InputDecoration(
            filled: true, fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5)),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Color _progressColor(int p) {
    if (p >= 80) return AppColors.accentDark;
    if (p >= 40) return AppColors.warning;
    return AppColors.primaryLight;
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final parts = _deadlineDate.split('-');
    final dl = "${months[int.parse(parts[1]) - 1]} '${int.parse(parts[0]) % 100}";

    final updated = _project.copyWith(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locCtrl.text.trim(),
      contractorName: _contrCtrl.text.trim(),
      type: _type,
      status: _status,
      priority: _priority,
      budgetLakh: _budget,
      geofenceRadius: _geofence,
      progressPercent: _progress,
      deadlineLabel: dl,
      deadlineDate: _deadlineDate,
      milestones: _milestones,
    );

    await ref.read(projectsProvider.notifier).updateProject(updated);
    setState(() { _isLoading = false; _showSuccess = true; });
  }
}
