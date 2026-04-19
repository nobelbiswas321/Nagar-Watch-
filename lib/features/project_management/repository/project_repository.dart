// project_repository.dart
// MongoDB integration.
// The UI works fully with the in-memory ProjectsNotifier (project_provider.dart).

import 'package:mongo_dart/mongo_dart.dart';

import '../../../core/models/project_model.dart';

/// MongoDB repository for projects.
class ProjectRepository {
  static const String connectionString = 'mongodb+srv://nirobmahee04_db_user:xMNglekmT9xjlMuB@cluster0.lgvqrva.mongodb.net/nagarwatch?appName=Cluster0';
  static const String collectionName = 'projects';

  late Db _db;
  late DbCollection _collection;

  ProjectRepository() {
    _db = Db(connectionString);
    _collection = _db.collection(collectionName);
  }

  Future<void> connect() async {
    await _db.open();
  }

  Future<void> disconnect() async {
    await _db.close();
  }

  // FR-2.1 – Create
  Future<String> createProject(ProjectModel project) async {
    final doc = project.toMap();
    final result = await _collection.insertOne(doc);
    return result.id?.toHexString() ?? DateTime.now().millisecondsSinceEpoch.toString();
  }

  // FR-2.2 – Update
  Future<void> updateProject(ProjectModel project) async {
    await _collection.updateOne(
      where.id(ObjectId.fromHexString(project.id)),
      modify.set('name', project.name)
          .set('description', project.description)
          .set('status', project.status.name)
          .set('progressPercent', project.progressPercent)
          .set('wardId', project.wardId)
          .set('latitude', project.latitude)
          .set('longitude', project.longitude)
          .set('milestones', project.milestones.map((m) => m.toMap()).toList())
          .set('updatedAt', DateTime.now().toIso8601String()),
    );
  }

  // FR-2.3 – Real-time stream by ward
  Stream<List<ProjectModel>> watchByWard(String wardId) {
    // For simplicity, fetch once. In production, use change streams.
    return Stream.fromFuture(_fetchByWard(wardId));
  }

  Future<List<ProjectModel>> _fetchByWard(String wardId) async {
    final docs = await _collection.find(where.eq('wardId', wardId).sortBy('createdAt', descending: true)).toList();
    return docs.map((doc) => ProjectModel.fromMap(doc)).toList();
  }

  // FR-2.3 – Nearby (lat/lng bounding box)
  Future<List<ProjectModel>> fetchNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    // Approximate bounding box
    final delta = radiusKm / 111.0;
    final docs = await _collection.find(
      where
        .gte('latitude', latitude - delta)
        .lte('latitude', latitude + delta)
        .gte('longitude', longitude - delta)
        .lte('longitude', longitude + delta),
    ).toList();
    return docs.map((doc) => ProjectModel.fromMap(doc)).toList();
  }

  // FR-6.2 – Live project watcher
  Stream<ProjectModel?> watchProject(String id) {
    // For simplicity, fetch once.
    return Stream.fromFuture(_fetchProject(id));
  }

  Future<ProjectModel?> _fetchProject(String id) async {
    final doc = await _collection.findOne(where.id(ObjectId.fromHexString(id)));
    return doc != null ? ProjectModel.fromMap(doc) : null;
  }

  // FR-6.2 – Progress-only update
  Future<void> updateProgress(
      String id, int percent, ProjectStatus status, List<MilestoneModel> milestones) async {
    await _collection.updateOne(
      where.id(ObjectId.fromHexString(id)),
      modify
          .set('progressPercent', percent)
          .set('status', status.name)
          .set('milestones', milestones.map((m) => m.toMap()).toList())
          .set('updatedAt', DateTime.now().toIso8601String()),
    );
  }
}
