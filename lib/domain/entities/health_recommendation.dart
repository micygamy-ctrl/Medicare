enum RecommendationCategory { food, avoidFood, exercise, lifestyle }

class HealthRecommendationEntity {
  final String id;
  final String patientId;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final RecommendationCategory category;
  final String relatedConditionOrTest; // e.g. "Diabetes", "HbA1c High", "Hypertension"
  final DateTime createdAt;

  const HealthRecommendationEntity({
    required this.id,
    required this.patientId,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.category,
    required this.relatedConditionOrTest,
    required this.createdAt,
  });
}
