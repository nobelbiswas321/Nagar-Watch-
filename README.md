# NagarWatch – Project Management Module (Nobel)

## Feature Requirements Covered

| FR     | Description               | Screen / File                             |
|--------|--------------------------|-------------------------------------------|
| FR-2.1 | Project Creation          | `project_create_screen.dart`              |
| FR-2.2 | Project Update            | `project_update_screen.dart`              |
| FR-2.3 | Nearby Project Listing    | `project_list_screen.dart`                |
| FR-6.2 | Project Monitoring        | `project_detail_screen.dart` + update     |

---

## File Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          ← Exact CSS vars from prototype
│   │   └── app_text_styles.dart     ← Inter-based text styles
│   ├── models/
│   │   └── project_model.dart       ← ProjectModel + MilestoneModel + sample data
│   └── widgets/
│       ├── project_type_icon.dart   ← Reusable type icon (road/drainage/…)
│       └── status_badge.dart        ← Planned / Ongoing / Completed badge
│
└── features/project_management/
    ├── screens/
    │   ├── project_list_screen.dart   ← FR-2.3
    │   ├── project_create_screen.dart ← FR-2.1
    │   ├── project_update_screen.dart ← FR-2.2 + FR-6.2
    │   └── project_detail_screen.dart ← FR-2.3 detail + FR-6.2
    ├── providers/
    │   └── project_provider.dart      ← Riverpod state (filter, search, CRUD)
    └── repository/
        └── project_repository.dart    ← Firestore stubs (uncomment to activate)
```

---

## Dependencies

```yaml
flutter_riverpod: ^2.5.1
google_fonts: ^6.2.1
intl: ^0.19.0
```

---

## How to Navigate to Nobel's Screens

```dart
// Project list (FR-2.3)
Navigator.push(context,
  MaterialPageRoute(builder: (_) => const ProjectListScreen()));

// Create project (FR-2.1)
Navigator.push(context,
  MaterialPageRoute(builder: (_) => const ProjectCreateScreen()));

// Detail (FR-2.3, FR-6.2)
Navigator.push(context,
  MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: project.id)));

// Update (FR-2.2, FR-6.2)
Navigator.push(context,
  MaterialPageRoute(builder: (_) => ProjectUpdateScreen(projectId: project.id)));
```

---

## Team Integration

| Team Member | Hook                                                        |
|-------------|-------------------------------------------------------------|
| **Shafia**  | Set `activeWardIdProvider` after login                      |
| **Deloar**  | Read `project.geofenceRadius`, `latitude`, `longitude`      |
| **Dipta**   | Use `projectId` when creating an `IssueModel`               |
| **Mukit**   | `projectsProvider` and `filteredProjectsProvider` available |

## Firestore Collection: `projects`

```
name, description, wardId, wardName, location,
latitude, longitude, geofenceRadius,
budgetLakh, deadlineLabel, deadlineDate, startDate,
status, type, progressPercent, contractorName,
priority, milestones[], createdAt, updatedAt, createdBy
```

Uncomment the Firestore lines in `project_repository.dart` to activate.
