import 'package:smp/models/category.dart';

class CategoryOperations {
  CategoryOperations._() {}

  static List<Category> getCategories() {
    return <Category>[
      Category('Top Songs', 'https://cdn1.suno.ai/32f56318.webp'),
      Category('Hot Mix', 'https://cdn1.suno.ai/32f56318.webp'),
      Category('Romantic Mix', 'https://cdn1.suno.ai/32f56318.webp'),
      Category('Latest Hits',
          'https://is3-ssl.mzstatic.com/image/thumb/Purple122/v4/2a/0a/13/2a0a1378-2d71-5373-040c-4c790dfe0ac8/source/256x256bb.jpg'),
    ];
  }
}
