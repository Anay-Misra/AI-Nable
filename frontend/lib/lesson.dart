class Lesson {
 final String title;
 final DateTime dateSaved;
 bool isFavorite;


 Lesson({
   required this.title,
   required this.dateSaved,
   this.isFavorite = false, // ✅ Default to false
 });
}
