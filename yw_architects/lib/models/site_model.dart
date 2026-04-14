import 'package:flutter/foundation.dart';

class Site {
  final int id;
  final String siteName;
  final String status;
  final String address;
  final String city;
  final double builtUpArea;
  final int projectId;

  // New aligned fields
  final String? projectCode;
  final String? permanentProjectId;
  final String? projectDetails;
  final String? logoUrl;
  final String? priority;
  final double? latitude;
  final double? longitude;
  final double? plotArea;
  final double? totalCarpetArea;
  final DateTime? projectStartDateTime;
  final DateTime? projectExpectedEndDate;
  final DateTime? projectEndDateTime;
  final DateTime? createdAt;
  final int? postSalesId;
  final List<SiteStructure> structures;
  final List<SiteStage> stages;
  final List<dynamic> team;
  final List<SiteVisit> visits;
  final List<Meeting> meetings;
  final List<ReraProject> reraProjects;

  Site({
    required this.id,
    required this.siteName,
    required this.status,
    required this.address,
    required this.city,
    required this.builtUpArea,
    required this.projectId,
    this.projectCode,
    this.permanentProjectId,
    this.projectDetails,
    this.logoUrl,
    this.priority,
    this.latitude,
    this.longitude,
    this.plotArea,
    this.totalCarpetArea,
    this.projectStartDateTime,
    this.projectExpectedEndDate,
    this.projectEndDateTime,
    this.createdAt,
    this.postSalesId,
    this.structures = const [],
    this.stages = const [],
    this.team = const [],
    this.visits = const [],
    this.meetings = const [],
    this.reraProjects = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteName': siteName,
      'status': status,
      'address': address,
      'city': city,
      'builtUpArea': builtUpArea,
      'projectId': projectId,
      'projectCode': projectCode,
      'permanentProjectId': permanentProjectId,
      'projectDetails': projectDetails,
      'priority': priority,
      'latitude': latitude,
      'longitude': longitude,
      'plotArea': plotArea,
      'totalCarpetArea': totalCarpetArea,
      'postSalesId': postSalesId,
      // Map basic collections as strings to avoid "Method not found" errors
      'structuresCount': structures.length,
      'stagesCount': stages.length,
      'visitsCount': visits.length,
      'meetingsCount': meetings.length,
    };
  }

  factory Site.fromJson(Map<String, dynamic> json) {
    // DIAGNOSTIC LOGGING
    debugPrint("--- SITE MAPPING DEBUG ---");
    debugPrint("TOP KEYS: ${json.keys.toList()}");
    final project = json['project'] ?? {};
    final client = json['client'] ?? {};
    if (project.isNotEmpty)
      debugPrint("NESTED PROJECT KEYS: ${project.keys.toList()}");

    var structList = json['structures'] as List?;
    var stageList = json['stages'] as List?;
    var teamList = json['team'] as List? ?? json['employees'] as List?;
    var visitList = json['siteVisits'] as List? ?? json['visits'] as List?;
    var meetingList = json['meetings'] as List?;
    var reraList =
        json['reraProjects'] as List? ?? json['rera_projects'] as List?;

    // FUZZY MAPPING: Search every key in every object for a pattern
    dynamic fuzzyGet(List<String> patterns, {double? defaultValue}) {
      final allObjects = [json, project, client];

      for (var obj in allObjects) {
        if (obj.isEmpty) continue;

        // 1. Try Exact Matches first for performance
        for (var p in patterns) {
          if (obj[p] != null &&
              obj[p].toString().isNotEmpty &&
              obj[p].toString() != 'null') {
            return obj[p];
          }
        }

        // 2. Try Case-Insensitive Regex Search
        for (var key in obj.keys.toList()) {
          final keyLower = key.toString().toLowerCase();
          for (var p in patterns) {
            final pLower = p.toLowerCase();
            // If the key contains our pattern (e.g., 'city' contains 'city')
            if (keyLower.contains(pLower) &&
                obj[key] != null &&
                obj[key].toString().isNotEmpty) {
              return obj[key];
            }
          }
        }
      }
      return defaultValue;
    }

    // Wrapper to keep existing mapping code clean
    dynamic getField(String key, List<String> fallbacks) {
      return fuzzyGet([key, ...fallbacks]);
    }

    final rawId = fuzzyGet(['project_id', 'projectId', 'id']) ?? 0;

    // Safely parse a dynamic value into a double
    double parseDoubleSafely(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Site(
      id: rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0),
      siteName:
          getField('projectName', [
            'project_name',
            'siteName',
            'name',
          ])?.toString() ??
          'Unnamed Site',
      status:
          getField('projectStatus', ['project_status', 'status'])?.toString() ??
          'PLANNING',
      address:
          getField('address', [
            'locationAddress',
            'full_address',
          ])?.toString() ??
          '',
      city:
          getField('city', ['location', 'town', 'district'])?.toString() ?? '',
      builtUpArea: parseDoubleSafely(
        getField('totalBuiltUpArea', ['total_built_up_area', 'builtUpArea']),
      ),
      projectId: rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0),
      projectCode: getField('projectCode', [
        'project_code',
        'code',
      ])?.toString(),
      permanentProjectId: getField('permanentProjectId', [
        'permanent_project_id',
      ])?.toString(),
      projectDetails: getField('projectDetails', [
        'project_details',
        'details',
      ])?.toString(),
      logoUrl: getField('logoUrl', ['logo_url'])?.toString(),
      priority: getField('priority', ['projectPriority'])?.toString(),
      latitude: parseDoubleSafely(getField('latitude', ['lat'])),
      longitude: parseDoubleSafely(getField('longitude', ['lng'])),
      plotArea: parseDoubleSafely(getField('plotArea', ['plot_area', 'area'])),
      totalCarpetArea: parseDoubleSafely(
        getField('totalCarpetArea', ['total_carpet_area', 'carpetArea']),
      ),
      projectStartDateTime:
          getField('projectStartDateTime', ['project_start_date_time']) != null
          ? DateTime.tryParse(
              getField('projectStartDateTime', [
                'project_start_date_time',
              ]).toString(),
            )
          : null,
      projectExpectedEndDate:
          getField('projectExpectedEndDate', ['project_expected_end_date']) !=
              null
          ? DateTime.tryParse(
              getField('projectExpectedEndDate', [
                'project_expected_end_date',
              ]).toString(),
            )
          : null,
      projectEndDateTime:
          getField('projectEndDateTime', ['project_end_date_time']) != null
          ? DateTime.tryParse(
              getField('projectEndDateTime', [
                'project_end_date_time',
              ]).toString(),
            )
          : null,
      createdAt:
          getField('projectCreatedDateTime', [
                'project_created_date_time',
                'createdAt',
              ]) !=
              null
          ? DateTime.tryParse(
              getField('projectCreatedDateTime', [
                'project_created_date_time',
                'createdAt',
              ]).toString(),
            )
          : null,
      postSalesId:
          json['id'] ?? json['postSales']?['id'] ?? json['post_sales']?['id'],
      structures: structList != null
          ? structList.map((s) => SiteStructure.fromJson(s)).toList()
          : [],
      stages: Site.processStages(stageList),
      team: teamList ?? [],
      visits: visitList != null
          ? visitList.map((v) => SiteVisit.fromJson(v)).toList()
          : [],
      meetings: meetingList != null
          ? meetingList.map((m) => Meeting.fromJson(m)).toList()
          : [],
      reraProjects: reraList != null
          ? reraList.map((r) => ReraProject.fromJson(r)).toList()
          : [],
    );
  }

  static List<SiteStage> processStages(List? stageList) {
    // De-duplicate stages by ID/Name to prevent repeating milestones
    final uniqueStages = <String, SiteStage>{};
    if (stageList != null) {
      for (var s in stageList) {
        if (s == null) continue;
        final stage = SiteStage.fromJson(s as Map<String, dynamic>);

        // CRITICAL: Only include stages that are top-level milestones
        // If parentStageId is present and non-zero, it's a sub-stage and should be nested, not at top-level
        if (stage.parentStageId == null || stage.parentStageId == 0) {
          final key =
              stage.id > 0
                  ? stage.id.toString()
                  : SiteStage.normalize(stage.stageName);
          if (!uniqueStages.containsKey(key)) {
            uniqueStages[key] = stage;
          }
        }
      }
    }
    return uniqueStages.values.toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectName': siteName,
      'projectStatus': status,
      'address': address,
      'city': city,
      'totalBuiltUpArea': builtUpArea,
      'projectCode': projectCode,
      'priority': priority,
      'logoUrl': logoUrl,
      // mapping others as needed for create/update
    };
  }

  Site copyWith({
    int? id,
    String? siteName,
    String? status,
    String? address,
    String? city,
    double? builtUpArea,
    int? projectId,
    String? projectCode,
    String? permanentProjectId,
    String? projectDetails,
    String? logoUrl,
    String? priority,
    double? latitude,
    double? longitude,
    double? plotArea,
    double? totalCarpetArea,
    DateTime? projectStartDateTime,
    DateTime? projectExpectedEndDate,
    DateTime? projectEndDateTime,
    DateTime? createdAt,
    int? postSalesId,
    List<SiteStructure>? structures,
    List<SiteStage>? stages,
    List<dynamic>? team,
    List<SiteVisit>? visits,
    List<Meeting>? meetings,
    List<ReraProject>? reraProjects,
  }) {
    return Site(
      id: id ?? this.id,
      siteName: siteName ?? this.siteName,
      status: status ?? this.status,
      address: address ?? this.address,
      city: city ?? this.city,
      builtUpArea: builtUpArea ?? this.builtUpArea,
      projectId: projectId ?? this.projectId,
      projectCode: projectCode ?? this.projectCode,
      permanentProjectId: permanentProjectId ?? this.permanentProjectId,
      projectDetails: projectDetails ?? this.projectDetails,
      logoUrl: logoUrl ?? this.logoUrl,
      priority: priority ?? this.priority,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      plotArea: plotArea ?? this.plotArea,
      totalCarpetArea: totalCarpetArea ?? this.totalCarpetArea,
      projectStartDateTime: projectStartDateTime ?? this.projectStartDateTime,
      projectExpectedEndDate:
          projectExpectedEndDate ?? this.projectExpectedEndDate,
      projectEndDateTime: projectEndDateTime ?? this.projectEndDateTime,
      createdAt: createdAt ?? this.createdAt,
      postSalesId: postSalesId ?? this.postSalesId,
      structures: structures ?? this.structures,
      stages: stages ?? this.stages,
      team: team ?? this.team,
      visits: visits ?? this.visits,
      meetings: meetings ?? this.meetings,
      reraProjects: reraProjects ?? this.reraProjects,
    );
  }
}

class ReraProject {
  final int id;
  final String reraNumber;
  final DateTime registrationDate;
  final DateTime expectedCompletionDate;
  final String status; // ACTIVE, INACTIVE
  final DateTime createdAt;
  final DateTime lastUpdated;
  final List<ReraCertificate> certificates;
  final List<ReraQuarterUpdate> quarterUpdates;

  ReraProject({
    required this.id,
    required this.reraNumber,
    required this.registrationDate,
    required this.expectedCompletionDate,
    this.status = 'INACTIVE',
    required this.createdAt,
    required this.lastUpdated,
    this.certificates = const [],
    this.quarterUpdates = const [],
  });

  factory ReraProject.fromJson(Map<String, dynamic> json) {
    return ReraProject(
      id: json['id'] ?? 0,
      reraNumber: json['reraNumber'] ?? json['rera_number'] ?? '',
      registrationDate:
          DateTime.tryParse(
            json['registrationDate'] ?? json['registration_date'] ?? '',
          ) ??
          DateTime.now(),
      expectedCompletionDate:
          DateTime.tryParse(
            json['expectedCompletionDate'] ??
                json['expected_completion_date'] ??
                '',
          ) ??
          DateTime.now(),
      status: (json['active'] == true || json['status'] == 'ACTIVE')
          ? 'ACTIVE'
          : 'INACTIVE',
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ??
          DateTime.now(),
      lastUpdated:
          DateTime.tryParse(
            json['lastUpdated'] ?? json['last_updated'] ?? '',
          ) ??
          DateTime.now(),
      certificates:
          (json['certificates'] as List?)
              ?.map((e) => ReraCertificate.fromJson(e))
              .toList() ??
          [],
      quarterUpdates:
          (json['quarterUpdates'] as List?)
              ?.map((e) => ReraQuarterUpdate.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ReraCertificate {
  final int id;
  final DateTime certificateDate;
  final String? certifiedBy;
  final String? remarks;
  final String? certificateFileUrl;
  final DateTime createdAt;

  ReraCertificate({
    required this.id,
    required this.certificateDate,
    this.certifiedBy,
    this.remarks,
    this.certificateFileUrl,
    required this.createdAt,
  });

  factory ReraCertificate.fromJson(Map<String, dynamic> json) {
    return ReraCertificate(
      id: json['id'] ?? 0,
      certificateDate:
          DateTime.tryParse(
            json['certificateDate'] ?? json['certificate_date'] ?? '',
          ) ??
          DateTime.now(),
      certifiedBy: json['certifiedBy'] ?? json['certified_by'],
      remarks: json['remarks'],
      certificateFileUrl:
          json['certificateFileUrl'] ?? json['certificate_file_url'],
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ??
          DateTime.now(),
    );
  }
}

class ReraQuarterUpdate {
  final int id;
  final DateTime quarterDate;
  final String? constructionStatus;
  final String? salesStatus;

  ReraQuarterUpdate({
    required this.id,
    required this.quarterDate,
    this.constructionStatus,
    this.salesStatus,
  });

  factory ReraQuarterUpdate.fromJson(Map<String, dynamic> json) {
    return ReraQuarterUpdate(
      id: json['id'] ?? 0,
      quarterDate:
          DateTime.tryParse(
            json['quarterDate'] ?? json['quarter_date'] ?? '',
          ) ??
          DateTime.now(),
      constructionStatus:
          json['constructionStatus'] ?? json['construction_status'],
      salesStatus: json['salesStatus'] ?? json['sales_status'],
    );
  }
}

class Meeting {
  final int id;
  final String title;
  final String agenda;
  final String type; // CALL, ZOOM, GOOGLE_MEET, FACE_TO_FACE, TEAMS
  final String status; // SCHEDULED, ONGOING, COMPLETED, CANCELLED
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? meetingLink;
  final String? mom;

  Meeting({
    required this.id,
    required this.title,
    required this.agenda,
    required this.type,
    required this.status,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.meetingLink,
    this.mom,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'New Meeting',
      agenda: json['agenda'] ?? '',
      type: json['type'] ?? 'FACE_TO_FACE',
      status: json['status'] ?? 'SCHEDULED',
      scheduledAt:
          DateTime.tryParse(
            json['scheduledAt'] ?? json['scheduled_at'] ?? '',
          ) ??
          DateTime.now(),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'])
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'])
          : null,
      meetingLink: json['meetingLink'] ?? json['meeting_link'],
      mom: json['mom'],
    );
  }
}

class SiteVisit {
  final int id;
  final String title;
  final String description;
  final String? locationNote;
  final DateTime visitDate;
  final List<SiteVisitPhoto> photos;
  final List<SiteVisitDocument> documents;

  SiteVisit({
    required this.id,
    required this.title,
    required this.description,
    this.locationNote,
    required this.visitDate,
    this.photos = const [],
    this.documents = const [],
  });

  factory SiteVisit.fromJson(Map<String, dynamic> json) {
    return SiteVisit(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Site Visit',
      description: json['description'] ?? '',
      locationNote: json['locationNote'] ?? json['location_note'],
      visitDate:
          DateTime.tryParse(json['visitDate'] ?? json['visit_date'] ?? '') ??
          DateTime.now(),
      photos:
          (json['photos'] as List?)
              ?.map((p) => SiteVisitPhoto.fromJson(p))
              .toList() ??
          [],
      documents:
          (json['documents'] as List?)
              ?.map((d) => SiteVisitDocument.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class SiteVisitPhoto {
  final int id;
  final String imageUrl;
  final String? caption;
  final DateTime? uploadedAt;

  SiteVisitPhoto({
    required this.id,
    required this.imageUrl,
    this.caption,
    this.uploadedAt,
  });

  factory SiteVisitPhoto.fromJson(Map<String, dynamic> json) {
    return SiteVisitPhoto(
      id: json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      caption: json['caption'],
      uploadedAt: DateTime.tryParse(
        json['uploadedAt'] ?? json['uploaded_at'] ?? '',
      ),
    );
  }
}

class SiteVisitDocument {
  final int id;
  final String documentUrl;
  final String documentName;
  final DateTime? uploadedAt;

  SiteVisitDocument({
    required this.id,
    required this.documentUrl,
    required this.documentName,
    this.uploadedAt,
  });

  factory SiteVisitDocument.fromJson(Map<String, dynamic> json) {
    return SiteVisitDocument(
      id: json['id'] ?? 0,
      documentUrl: json['documentUrl'] ?? json['document_url'] ?? '',
      documentName: json['documentName'] ?? json['document_name'] ?? 'document',
      uploadedAt: DateTime.tryParse(
        json['uploadedAt'] ?? json['uploaded_at'] ?? '',
      ),
    );
  }
}

class SiteStructure {
  final int id;
  final String structureName;
  final String structureType;
  final String usageType;
  final int? totalFloors;
  final double? builtUpArea;

  SiteStructure({
    required this.id,
    required this.structureName,
    required this.structureType,
    required this.usageType,
    this.totalFloors,
    this.builtUpArea,
  });

  factory SiteStructure.fromJson(Map<String, dynamic> json) {
    return SiteStructure(
      id: json['id'] ?? 0,
      structureName: json['structureName'] ?? '',
      structureType: json['structureType'] ?? '',
      usageType: json['usageType'] ?? '',
      totalFloors: json['totalFloors'],
      builtUpArea: json['builtUpArea']?.toDouble(),
    );
  }
}

class StageDocument {
  final int id;
  final String? fileName;
  final String? filePath;
  final String? documentType;
  final String? description;
  final DateTime? uploadedAt;

  StageDocument({
    required this.id,
    this.fileName,
    this.filePath,
    this.documentType,
    this.description,
    this.uploadedAt,
  });

  factory StageDocument.fromJson(Map<String, dynamic> json) {
    return StageDocument(
      id: json['id'] ?? 0,
      fileName: json['fileName'] ?? json['documentName'],
      filePath: json['filePath'] ?? json['documentUrl'],
      documentType: json['documentType'],
      description: json['description'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'])
          : null,
    );
  }
}

class SiteStage {
  final int id;
  final String stageName;
  final String? customStageName;
  final String status;
  final double progressPercentage;
  final DateTime? startedAt;
  final DateTime? targetCompletionDate;
  final DateTime? actualCompletionDate;
  final List<SiteStage> childStages;
  final List<StageDocument> documents;
  final int? parentStageId;
  final int? displayOrder;

  SiteStage({
    required this.id,
    required this.stageName,
    this.customStageName,
    this.status = 'NOT_STARTED',
    this.progressPercentage = 0.0,
    this.startedAt,
    this.targetCompletionDate,
    this.actualCompletionDate,
    this.childStages = const [],
    this.documents = const [],
    this.parentStageId,
    this.displayOrder,
  });

  factory SiteStage.fromJson(Map<String, dynamic> json) {
    var children = json['childStages'] as List?;
    var docs = json['documents'] as List?;
    return SiteStage(
      id: json['id'] ?? 0,
      stageName: json['stageName'] ?? '',
      customStageName: json['customStageName'],
      status: json['status'] ?? 'NOT_STARTED',
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'])
          : null,
      targetCompletionDate: json['targetCompletionDate'] != null
          ? DateTime.tryParse(json['targetCompletionDate'])
          : null,
      actualCompletionDate: json['actualCompletionDate'] != null
          ? DateTime.tryParse(json['actualCompletionDate'])
          : null,
      childStages: children != null
          ? children.map((c) => SiteStage.fromJson(c)).toList()
          : [],
      documents: docs != null
          ? docs.map((d) => StageDocument.fromJson(d)).toList()
          : [],
      parentStageId: json['parentStageId'] is int 
          ? json['parentStageId'] 
          : int.tryParse(json['parentStageId']?.toString() ?? ''),
      displayOrder: json['displayOrder'] is int
          ? json['displayOrder']
          : int.tryParse(json['displayOrder']?.toString() ?? ''),
    );
  }

  // Standardized 11 Phases as provided by the user
  static const List<String> standardPhases = [
    "Concept Design",
    "Final Drawings",
    "Documentation Stage",
    "Building Permission",
    "Survey Land Records",
    "Building Permission Scrutiny",
    "Setback Approval",
    "Plinth Checking",
    "TDR FSI Stage",
    "Construction Execution",
    "Completion Process",
  ];

  static String normalize(String name) {
    return name.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  bool matchesStandard(String standardName) {
    final normName = normalize(stageName);
    final normCustom = customStageName != null ? normalize(customStageName!) : "";
    final normStandard = normalize(standardName);
    return normName == normStandard || normCustom == normStandard;
  }

  // Explicit getters to help Dart Internal lookups avoid "Lookup failed" errors
  int? get getParentStageId => parentStageId;
  int? get getDisplayOrder => displayOrder;
}
