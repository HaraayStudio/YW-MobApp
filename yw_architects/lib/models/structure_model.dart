import 'package:flutter/foundation.dart';

class SiteLevel {
  final int id;
  final String levelLabel;
  final int levelNumber;
  final String levelType; // BASEMENT, GROUND_FLOOR, TYPICAL_FLOOR, etc.
  final String usageType; // RESIDENTIAL, COMMERCIAL, etc.
  final double? builtUpArea;
  final double? carpetArea;
  final double? floorHeight;
  final String? constructionStatus;
  final double progressPercentage;

  SiteLevel({
    required this.id,
    required this.levelLabel,
    required this.levelNumber,
    required this.levelType,
    required this.usageType,
    this.builtUpArea,
    this.carpetArea,
    this.floorHeight,
    this.constructionStatus,
    this.progressPercentage = 0.0,
  });

  factory SiteLevel.fromJson(Map<String, dynamic> json) {
    return SiteLevel(
      id: json['id'] ?? 0,
      levelLabel: json['levelLabel'] ?? json['label'] ?? '',
      levelNumber: json['levelNumber'] ?? 0,
      levelType: json['levelType']?.toString().toUpperCase() ?? 'TYPICAL_FLOOR',
      usageType: json['usageType']?.toString().toUpperCase() ?? 'MIXED',
      builtUpArea: (json['builtUpArea'] as num?)?.toDouble(),
      carpetArea: (json['carpetArea'] as num?)?.toDouble(),
      floorHeight: (json['floorHeight'] as num?)?.toDouble(),
      constructionStatus: json['constructionStatus']?.toString(),
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelLabel': levelLabel,
      'levelNumber': levelNumber,
      'levelType': levelType,
      'usageType': usageType,
      'builtUpArea': builtUpArea,
      'carpetArea': carpetArea,
      'floorHeight': floorHeight,
      'constructionStatus': constructionStatus,
      'progressPercentage': progressPercentage,
    };
  }
}

class SiteStructure {
  final int id;
  final String structureName;
  final String structureType; // TOWER, WING, BUNGALOW, etc.
  final String usageType;
  final int? totalFloors;
  final int? totalBasements;
  final double? builtUpArea;
  final List<SiteLevel> levels;

  SiteStructure({
    required this.id,
    required this.structureName,
    required this.structureType,
    required this.usageType,
    this.totalFloors,
    this.totalBasements,
    this.builtUpArea,
    this.levels = const [],
  });

  factory SiteStructure.fromJson(Map<String, dynamic> json) {
    var levelList = json['levels'] as List?;
    return SiteStructure(
      id: json['id'] ?? 0,
      structureName: json['structureName'] ?? '',
      structureType: json['structureType']?.toString().toUpperCase() ?? '',
      usageType: json['usageType']?.toString().toUpperCase() ?? '',
      totalFloors: json['totalFloors'],
      totalBasements: json['totalBasements'],
      builtUpArea: (json['builtUpArea'] as num?)?.toDouble(),
      levels: levelList != null
          ? levelList.map((l) => SiteLevel.fromJson(l)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'structureName': structureName,
      'structureType': structureType,
      'usageType': usageType,
      'totalFloors': totalFloors,
      'totalBasements': totalBasements,
      'builtUpArea': builtUpArea,
      'levels': levels.map((l) => l.toJson()).toList(),
    };
  }
}
