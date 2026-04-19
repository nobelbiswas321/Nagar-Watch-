import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../providers/project_provider.dart';

class ProjectCreateScreen extends ConsumerStatefulWidget {
  const ProjectCreateScreen({super.key});

  @override
  ConsumerState<ProjectCreateScreen> createState() =>
      _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends ConsumerState<ProjectCreateScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _locCtrl    = TextEditingController();
  final _contrCtrl  = TextEditingController();

  ProjectType _selectedType = ProjectType.road;
  String _status   = 'Planned';
  String _priority = 'Medium';
  double _budget   = 50; // in lakhs
  double _geofence = 500; // meters
  DateTime _startDate    = DateTime(2025, 11, 1);
  DateTime _deadlineDate = DateTime(2026, 6, 30);
  bool _isLoading = false;
  bool _showSuccess = false;

  static const _typeData = <(ProjectType, String, IconData, Color, Color)>[
    (ProjectType.road,     'Road',     Icons.construction,      Color(0xFF92400E), Color(0xFFFFFBEB)),
    (ProjectType.drainage, 'Drainage', Icons.water_drop_outlined,AppColors.primary, AppColors.primary50),
    (ProjectType.lighting, 'Lighting', Icons.lightbulb_outline, AppColors.accentDark, AppColors.accent50),
    (ProjectType.waste,    'Waste',    Icons.delete_outline,    AppColors.danger,   AppColors.danger50),
    (ProjectType.park,     'Park',     Icons.park_outlined,     Color(0xFF7C3AED),  Color(0xFFF5F3FF)),
    (ProjectType.building, 'Building', Icons.apartment_outlined, Color(0xFF0891B2), Color(0xFFECFEFF)),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    _locCtrl.dispose();  _contrCtrl.dispose();
    super.dispose();
  }

  String get _budgetDisplay {
    if (_budget >= 100) {
      final cr = _budget / 100;
      return '₹${cr % 1 == 0 ? cr.toInt() : cr.toStringAsFixed(1)} Cr';
    }
    return '₹${_budget.toInt()} Lakh';
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
                        const SizedBox(height: 12),
                        _typeGrid(),
                        const SizedBox(height: 18),
                        _textField('Project Name *', 'e.g., Road Widening NH-30',
                            _nameCtrl, required: true),
                        const SizedBox(height: 14),
                        _textArea('Description *', 'Describe the project scope...',
                            _descCtrl, required: true),
                        const SizedBox(height: 18),
                        _budgetSlider(),
                        const SizedBox(height: 18),
                        _dateRow(),
                        const SizedBox(height: 14),
                        _locationField(),
                        const SizedBox(height: 18),
                        _geofenceSection(),
                        const SizedBox(height: 14),
                        _textField('Assigned Contractor', 'Contractor name',
                            _contrCtrl, icon: Icons.person_outline),
                        const SizedBox(height: 14),
                        _statusPriorityRow(),
                        const SizedBox(height: 28),
                        _submitButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showSuccess) _successModal(context),
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
          _backBtn(context),
          const SizedBox(width: 14),
          const Text('Add Project',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, letterSpacing: -0.3,
              )),
        ],
      ),
    );
  }

  Widget _backBtn(BuildContext context) {
    return GestureDetector(
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
    );
  }

  Widget _heading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Create New Project',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        SizedBox(height: 4),
        Text('Provide location, budget, deadline & description (FR-2.1)',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary, letterSpacing: 0.2,
        ));
  }

  // ─── Type grid ────────────────────────────────────────────────────────────
  Widget _typeGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: _typeData.map((t) {
        final (type, label, icon, color, bg) = t;
        final selected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary50 : AppColors.card,
              border: Border.all(
                color: selected ? AppColors.primaryLight : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                  blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(label,
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Budget slider ────────────────────────────────────────────────────────
  Widget _budgetSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💰 Estimated Budget',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Center(
            child: RichText(
              text: TextSpan(
                text: _budget >= 100
                    ? '₹${(_budget / 100) % 1 == 0 ? (_budget / 100).toInt() : (_budget / 100).toStringAsFixed(1)} '
                    : '₹${_budget.toInt()} ',
                style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                children: [
                  TextSpan(
                    text: _budget >= 100 ? 'Crore' : 'Lakh',
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Slider(
            value: _budget,
            min: 5, max: 500, divisions: 99,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.borderLight,
            onChanged: (v) => setState(() => _budget = v),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹5 L', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              Text('₹5 Cr', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Date row ────────────────────────────────────────────────────────────
  Widget _dateRow() {
    return Row(
      children: [
        Expanded(child: _datePicker('Start Date', _startDate,
                (d) => setState(() => _startDate = d))),
        const SizedBox(width: 12),
        Expanded(child: _datePicker('Deadline *', _deadlineDate,
                (d) => setState(() => _deadlineDate = d))),
      ],
    );
  }

  Widget _datePicker(String label, DateTime date, ValueChanged<DateTime> onPick) {
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (d != null) onPick(d);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
          )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Text(formatted,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Location field ───────────────────────────────────────────────────────
  Widget _locationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Project Location *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locCtrl,
          validator: (v) => v!.trim().isEmpty ? 'Location is required' : null,
          decoration: _inputDec('e.g., NH-30, Sadar Bazaar',
              prefixIcon: Icons.location_on_outlined),
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  // ─── Geofence section ─────────────────────────────────────────────────────
  Widget _geofenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📍 Geofence Boundary (FR-3.1)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Center(
            child: RichText(
              text: TextSpan(
                text: '${_geofence.toInt()} ',
                style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary,
                ),
                children: const [
                  TextSpan(
                    text: 'meters',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Slider(
            value: _geofence,
            min: 100, max: 2000, divisions: 38,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary200,
            onChanged: (v) => setState(() => _geofence = v),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('100m', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              Text('2km',  style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 12),
          // mini map placeholder
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFDBEAFE), Color(0xFFE0E7FF)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary200),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(size: Size.infinite, painter: _GridPainter()),
                _GeofenceCircle(size: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status & Priority row ────────────────────────────────────────────────
  Widget _statusPriorityRow() {
    return Row(
      children: [
        Expanded(child: _dropdown('Initial Status',
            ['Planned', 'Ongoing'], _status, (v) => setState(() => _status = v!))),
        const SizedBox(width: 12),
        Expanded(child: _dropdown('Priority',
            ['Low', 'Medium', 'High'], _priority, (v) => setState(() => _priority = v!))),
      ],
    );
  }

  Widget _dropdown(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
        )),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((s) =>
              DropdownMenuItem(value: s, child: Text(s))).toList(),
          decoration: _inputDec(''),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          dropdownColor: AppColors.card,
        ),
      ],
    );
  }

  // ─── Submit button ────────────────────────────────────────────────────────
  Widget _submitButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _onSubmit,
      icon: _isLoading
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
      label: Text(_isLoading ? 'Creating...' : 'Create Project',
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

  // ─── Success modal (matches prototype modal-sheet) ────────────────────────
  Widget _successModal(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              const Text('Project Created! 🎉',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                '${_nameCtrl.text.trim()} • ${_budgetDisplay} • Geofence: ${_geofence.toInt()}m',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Citizens can now track progress. Real-time sync active (FR-7.1).',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                label: const Text('Back to Dashboard',
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
  Widget _textField(String label, String hint, TextEditingController ctrl,
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
              ? (v) => v!.trim().isEmpty ? 'This field is required' : null
              : null,
          decoration: _inputDec(hint, prefixIcon: icon),
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _textArea(String label, String hint, TextEditingController ctrl,
      {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          maxLines: 3,
          validator: required
              ? (v) => v!.trim().isEmpty ? 'This field is required' : null
              : null,
          decoration: _inputDec(hint),
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  InputDecoration _inputDec(String hint, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.textTertiary, size: 18)
          : null,
      filled: true, fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final deadlineLabel = "${months[_deadlineDate.month - 1]} '${_deadlineDate.year % 100}";

    final project = ProjectModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      wardId: 'ward_12',
      wardName: 'Ward 12 – Sadar Bazaar',
      location: _locCtrl.text.trim(),
      latitude: 25.6093,
      longitude: 85.1376,
      geofenceRadius: _geofence,
      budgetLakh: _budget,
      deadlineLabel: deadlineLabel,
      deadlineDate: '${_deadlineDate.year}-${_deadlineDate.month.toString().padLeft(2,'0')}-${_deadlineDate.day.toString().padLeft(2,'0')}',
      startDate: '${_startDate.year}-${_startDate.month.toString().padLeft(2,'0')}-${_startDate.day.toString().padLeft(2,'0')}',
      status: _status == 'Ongoing' ? ProjectStatus.ongoing : ProjectStatus.planned,
      type: _selectedType,
      progressPercent: 0,
      contractorName: _contrCtrl.text.trim(),
      priority: _priority,
    );

    await ref.read(projectsProvider.notifier).addProject(project);
    setState(() { _isLoading = false; _showSuccess = true; });
  }
}

// ─── Geofence circle widget ───────────────────────────────────────────────────
class _GeofenceCircle extends StatefulWidget {
  final double size;
  const _GeofenceCircle({required this.size});
  @override
  State<_GeofenceCircle> createState() => _GeofenceCircleState();
}

class _GeofenceCircleState extends State<_GeofenceCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.03).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.size, height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryLight.withOpacity(0.08),
          border: Border.all(
              color: AppColors.primaryLight.withOpacity(0.6), width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 10, height: 10,
            decoration: const BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

// ─── Grid painter for map backgrounds ────────────────────────────────────────
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
