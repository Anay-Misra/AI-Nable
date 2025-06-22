class Lesson {
 final String title;
 final DateTime dateSaved;
 final String originalContent;
 String simplifiedText;
 List<Map<String, String>> keyTerms;
 List<String> stepByStep;
 String? visualImageBase64;
 bool isFavorite;


 Lesson({
   required this.title,
   required this.dateSaved,
   required this.originalContent,
   this.simplifiedText = '',
   this.keyTerms = const [],
   this.stepByStep = const [],
   this.visualImageBase64,
   this.isFavorite = false, // ✅ Default to false
 });
}
