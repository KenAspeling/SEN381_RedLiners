class Module {
  final int moduleId;
  final String name;
  final String? tag;
  final String? description;

  Module({
    required this.moduleId,
    required this.name,
    this.tag,
    this.description,
  });

  /// Create Module from JSON response (from backend API)
  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      moduleId: json['moduleId'] as int,
      name: json['name'] as String,
      tag: json['tag'] as String?,
      description: json['description'] as String?,
    );
  }

  /// Convert Module to JSON
  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'name': name,
      'tag': tag,
      'description': description,
    };
  }

  /// Get display name (includes tag if available)
  String get displayName {
    if (tag != null && tag!.isNotEmpty) {
      return '$tag - $name';
    }
    return name;
  }

  /// Get short display name (just tag or truncated name)
  String get shortName {
    if (tag != null && tag!.isNotEmpty) {
      return tag!;
    }
    return name.length > 20 ? '${name.substring(0, 17)}...' : name;
  }

  @override
  String toString() {
    return 'Module{moduleId: $moduleId, name: $name, tag: $tag}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Module && other.moduleId == moduleId;
  }

  @override
  int get hashCode => moduleId.hashCode;
}
