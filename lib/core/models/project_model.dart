import 'package:mongo_dart/mongo_dart.dart';

enum ProjectStatus { planned, ongoing, completed, delayed }

enum ProjectType { road, drainage, lighting, waste, park, building, other }

class MilestoneModel {
  final String id;
  final String title;
  final String targetDate; // e.g. "Jun '25"
  final MilestoneState state; // completed, current, pending

  const MilestoneModel({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.state,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetDate': targetDate,
      'state': state.name,
    };
  }

  factory MilestoneModel.fromMap(Map<String, dynamic> map) {
    return MilestoneModel(
      id: map['id'] as String,
      title: map['title'] as String,
      targetDate: map['targetDate'] as String,
      state: MilestoneState.values.firstWhere((e) => e.name == map['state']),
    );
  }}

enum MilestoneState { completed, current, pending }

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String wardId;
  final String wardName;
  final String location;
  final double latitude;
  final double longitude;
  final double geofenceRadius; // meters
  final double budgetLakh;     // in lakhs for display
  final String deadlineLabel;  // e.g. "Dec '25"
  final ProjectStatus status;
  final ProjectType type;
  final int progressPercent;
  final String contractorName;
  final String startDate;
  final String deadlineDate;
  final String priority;
  final List<MilestoneModel> milestones;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.wardId,
    required this.wardName,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.geofenceRadius = 500,
    required this.budgetLakh,
    required this.deadlineLabel,
    required this.status,
    required this.type,
    required this.progressPercent,
    this.contractorName = '',
    this.startDate = '',
    this.deadlineDate = '',
    this.priority = 'Medium',
    this.milestones = const [],
  });

  // Format budget for display: e.g., 240 -> ₹2.4 Cr, 85 -> ₹85 L
  String get budgetFormatted {
    if (budgetLakh >= 100) {
      final cr = budgetLakh / 100;
      return '₹${cr % 1 == 0 ? cr.toInt() : cr.toStringAsFixed(1)} Cr';
    }
    return '₹${budgetLakh.toInt()} L';
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    double? geofenceRadius,
    double? budgetLakh,
    String? deadlineLabel,
    String? deadlineDate,
    ProjectStatus? status,
    ProjectType? type,
    int? progressPercent,
    String? contractorName,
    String? priority,
    List<MilestoneModel>? milestones,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      wardId: wardId,
      wardName: wardName,
      location: location ?? this.location,
      latitude: latitude,
      longitude: longitude,
      geofenceRadius: geofenceRadius ?? this.geofenceRadius,
      budgetLakh: budgetLakh ?? this.budgetLakh,
      deadlineLabel: deadlineLabel ?? this.deadlineLabel,
      status: status ?? this.status,
      type: type ?? this.type,
      progressPercent: progressPercent ?? this.progressPercent,
      contractorName: contractorName ?? this.contractorName,
      startDate: startDate,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      priority: priority ?? this.priority,
      milestones: milestones ?? this.milestones,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'wardId': wardId,
      'wardName': wardName,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'geofenceRadius': geofenceRadius,
      'budgetLakh': budgetLakh,
      'deadlineLabel': deadlineLabel,
      'status': status.name,
      'type': type.name,
      'progressPercent': progressPercent,
      'contractorName': contractorName,
      'startDate': startDate,
      'deadlineDate': deadlineDate,
      'priority': priority,
      'milestones': milestones.map((m) => m.toMap()).toList(),
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: (map['_id'] as ObjectId).toHexString(),
      name: map['name'] as String,
      description: map['description'] as String,
      wardId: map['wardId'] as String,
      wardName: map['wardName'] as String,
      location: map['location'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      geofenceRadius: (map['geofenceRadius'] as num).toDouble(),
      budgetLakh: (map['budgetLakh'] as num).toDouble(),
      deadlineLabel: map['deadlineLabel'] as String,
      status: ProjectStatus.values.firstWhere((e) => e.name == map['status']),
      type: ProjectType.values.firstWhere((e) => e.name == map['type']),
      progressPercent: map['progressPercent'] as int,
      contractorName: map['contractorName'] as String,
      startDate: map['startDate'] as String,
      deadlineDate: map['deadlineDate'] as String,
      priority: map['priority'] as String,
      milestones: (map['milestones'] as List<dynamic>).map((m) => MilestoneModel.fromMap(m as Map<String, dynamic>)).toList(),
    );
  }
}

// ─── Sample data matching the prototype exactly ───────────────────────────────
final kSampleProjects = <ProjectModel>[
  ProjectModel(
    id: '1',
    name: 'Road Widening – NH 30',
    description:
        'Road widening covering 3.2 km along NH-30. Includes footpath construction, drainage alignment, utility shifting.',
    wardId: 'ward_12',
    wardName: 'Ward 12 – Sadar Bazaar',
    location: 'NH-30, Sadar Bazaar Area, Ward 12',
    latitude: 25.6093,
    longitude: 85.1376,
    geofenceRadius: 500,
    budgetLakh: 240,
    deadlineLabel: "Dec '25",
    deadlineDate: '2025-12-31',
    startDate: '2025-05-01',
    status: ProjectStatus.ongoing,
    type: ProjectType.road,
    progressPercent: 65,
    contractorName: 'ABC Construction Pvt. Ltd.',
    priority: 'High',
    milestones: [
      MilestoneModel(id: 'm1', title: 'Site survey completed', targetDate: "Jun '25", state: MilestoneState.completed),
      MilestoneModel(id: 'm2', title: 'Utility shifting done', targetDate: "Aug '25", state: MilestoneState.completed),
      MilestoneModel(id: 'm3', title: 'Road laying in progress', targetDate: 'Now', state: MilestoneState.current),
      MilestoneModel(id: 'm4', title: 'Footpath construction', targetDate: "Nov '25", state: MilestoneState.pending),
    ],
  ),
  ProjectModel(
    id: '2',
    name: 'Drainage System Ward 12',
    description: 'New underground drainage system for Ward 12 covering all major lanes and sectors.',
    wardId: 'ward_12',
    wardName: 'Ward 12 – Sadar Bazaar',
    location: 'Ward 12, Sadar Bazaar',
    latitude: 25.6110,
    longitude: 85.1390,
    geofenceRadius: 400,
    budgetLakh: 85,
    deadlineLabel: "Mar '26",
    deadlineDate: '2026-03-31',
    startDate: '2025-11-01',
    status: ProjectStatus.planned,
    type: ProjectType.drainage,
    progressPercent: 10,
    contractorName: 'XYZ Infra Ltd.',
    priority: 'Medium',
    milestones: [
      MilestoneModel(id: 'm1', title: 'Survey & design', targetDate: "Nov '25", state: MilestoneState.current),
      MilestoneModel(id: 'm2', title: 'Excavation work', targetDate: "Jan '26", state: MilestoneState.pending),
      MilestoneModel(id: 'm3', title: 'Pipe laying', targetDate: "Feb '26", state: MilestoneState.pending),
    ],
  ),
  ProjectModel(
    id: '3',
    name: 'LED Street Lights',
    description: 'Replacement of old sodium lamps with energy-efficient LED streetlights across Ward 12.',
    wardId: 'ward_12',
    wardName: 'Ward 12 – Sadar Bazaar',
    location: 'All lanes, Ward 12',
    latitude: 25.6075,
    longitude: 85.1355,
    geofenceRadius: 600,
    budgetLakh: 42,
    deadlineLabel: "Oct '25",
    deadlineDate: '2025-10-31',
    startDate: '2025-06-01',
    status: ProjectStatus.completed,
    type: ProjectType.lighting,
    progressPercent: 100,
    contractorName: 'Bright Solutions Ltd.',
    priority: 'Low',
    milestones: [
      MilestoneModel(id: 'm1', title: 'Procurement done', targetDate: "Jul '25", state: MilestoneState.completed),
      MilestoneModel(id: 'm2', title: 'Installation complete', targetDate: "Sep '25", state: MilestoneState.completed),
      MilestoneModel(id: 'm3', title: 'Testing & handover', targetDate: "Oct '25", state: MilestoneState.completed),
    ],
  ),
  ProjectModel(
    id: '4',
    name: 'Waste Management System',
    description: 'Modern waste segregation and collection system for Ward 12 with dedicated bins and collection schedules.',
    wardId: 'ward_12',
    wardName: 'Ward 12 – Sadar Bazaar',
    location: 'Ward 12, Rajendra Nagar',
    latitude: 25.6055,
    longitude: 85.1420,
    geofenceRadius: 350,
    budgetLakh: 120,
    deadlineLabel: "Jun '26",
    deadlineDate: '2026-06-30',
    startDate: '2025-11-01',
    status: ProjectStatus.ongoing,
    type: ProjectType.waste,
    progressPercent: 30,
    contractorName: 'Green Earth Services',
    priority: 'High',
    milestones: [
      MilestoneModel(id: 'm1', title: 'Bin installation', targetDate: "Dec '25", state: MilestoneState.current),
      MilestoneModel(id: 'm2', title: 'Route planning', targetDate: "Feb '26", state: MilestoneState.pending),
    ],
  ),
];
