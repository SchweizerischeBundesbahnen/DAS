/// HTML template for local regulations.
/// Used as Dart multi line string as reading package assets from executables are not possible.
const htmlTemplate = '''
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>

    <title>Local Regulations</title>

    <style>
        {{CSS_STYLE}}
    </style>
</head>
<body>
{{HTML_BODY}}
</body>
</html>
''';
