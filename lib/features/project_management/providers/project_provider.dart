import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/project_model.dart';
import '../repository/project_repository.dart';

// ─── Repository provider ──────────────────────────────────────────────────────
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final repo = ProjectRepository();
  ref.onDispose(() => repo.disconnect());
  return repo;
});

// ─── Active ward ──────────────────────────────────────────────────────────────
final activeWardIdProvider = StateProvider<String>((_) => 'ward_12');

// ─── Filter tab ───────────────────────────────────────────────────────────────
enum ProjectFilter { all, ongoing, planned, completed }
final projectFilterProvider = StateProvider<ProjectFilter>((_) => ProjectFilter.all);

// ─── Search query ─────────────────────────────────────────────────────────────
final projectSearchProvider = StateProvider<String>((_) => '');

// ─── Projects list (simulated; replace with Firestore stream in production) ───
final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<ProjectModel>>(
  (ref) => ProjectsNotifier(ref.watch(projectRepositoryProvider)),
);

class ProjectsNotifier extends StateNotifier<List<ProjectModel>> {
  final ProjectRepository _repository;

  ProjectsNotifier(this._repository) : super([]) {
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await _repository.connect();
    // For now, load sample, but in future load from DB
    state = List.from(kSampleProjects);
  }

  /// FR-2.1 Create
  Future<void> addProject(ProjectModel project) async {
    final id = await _repository.createProject(project);
    final newProject = project.copyWith(id: id);
    state = [newProject, ...state];
  }

  /// FR-2.2 Update
  Future<void> updateProject(ProjectModel updated) async {
    await _repository.updateProject(updated);
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p,
    ];
  }

  /// FR-6.2 Update progress & status only
  Future<void> updateProgress(String id, int progress, ProjectStatus status,
      List<MilestoneModel> milestones) async {
    await _repository.updateProgress(id, progress, status, milestones);
    state = [
      for (final p in state)
        if (p.id == id)
          p.copyWith(progressPercent: progress, status: status, milestones: milestones)
        else
          p,
    ];
  }
}

// ─── Filtered projects (for list screen) ─────────────────────────────────────
final filteredProjectsProvider = Provider<List<ProjectModel>>((ref) {
  final all    = ref.watch(projectsProvider);
  final filter = ref.watch(projectFilterProvider);
  final query  = ref.watch(projectSearchProvider).toLowerCase().trim();

  var result = all;

  if (filter != ProjectFilter.all) {
    result = result.where((p) {
      switch (filter) {
        case ProjectFilter.ongoing:   return p.status == ProjectStatus.ongoing;
        case ProjectFilter.planned:   return p.status == ProjectStatus.planned;
        case ProjectFilter.completed: return p.status == ProjectStatus.completed;
        case ProjectFilter.all:       return true;
      }
    }).toList();
  }

  if (query.isNotEmpty) {
    result = result.where((p) =>
      p.name.toLowerCase().contains(query) ||
      p.location.toLowerCase().contains(query) ||
      p.contractorName.toLowerCase().contains(query),
    ).toList();
  }

  return result;
});

// ─── Nearby projects (FR-2.3) ─────────────────────────────────────────────────
final nearbyProjectsProvider = Provider<List<ProjectModel>>((ref) {
  // In production: filter by geolocation radius. Here return all for same ward.
  return ref.watch(projectsProvider).take(2).toList();
});
