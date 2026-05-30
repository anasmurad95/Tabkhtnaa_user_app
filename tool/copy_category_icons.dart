import 'dart:io';

void main() {
  final script = Platform.script.toFilePath();
  final toolDir = File(script).parent;
  final appRoot = toolDir.parent;
  final repoRoot = appRoot.parent.parent;
  final src = Directory('${repoRoot.path}/BackEnd/Tabkhtnaa/public/images/categorise');
  final dst = Directory('${appRoot.path}/assets/images/categories');
  dst.createSync(recursive: true);

  const map = <String, String>{
    'appetizers': 'Appetizers-01.png',
    'asian_food': 'Asian food-01.png',
    'aslan_food': 'Asian food-01.png',
    'bakery': 'Bakery-01.png',
    'barbeque': 'Barbeque-01.png',
    'dessert': 'Dessert-01.png',
    'drinks': 'Drinks-01.png',
    'fast_food': 'Fast food-01.png',
    'frozen': 'Frozen-01.png',
    'healthy_food': 'Healthy food-01.png',
    'orders': 'Orders-01.png',
    'oriental_food': 'Oriental food-01.png',
    'pasta': 'Pasta-01.png',
    'pickels': 'Pickels-01.png',
    'salad': 'Salad-01.png',
    'sandwiches': 'Sandwiches-01.png',
    'soup': 'Soup-01.png',
    'spicy': 'Spicy-01.png',
    'western': 'Western-01.png',
  };

  var copied = 0;
  for (final entry in map.entries) {
    final from = File('${src.path}/${entry.value}');
    final to = File('${dst.path}/${entry.value}');
    if (!from.existsSync()) {
      stderr.writeln('MISSING ${from.path}');
      continue;
    }
    from.copySync(to.path);
    copied++;
    stdout.writeln('OK ${entry.key} -> ${entry.value}');
  }

  final files = dst
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.png'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  stdout.writeln('COPIED=$copied');
  stdout.writeln('TOTAL=${files.length}');
  for (final f in files) {
    stdout.writeln('${f.uri.pathSegments.last} ${f.lengthSync()}');
  }
}
