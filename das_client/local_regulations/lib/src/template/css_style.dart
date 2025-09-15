/// CSS style for local regulations.
/// Used as Dart multi line string as reading package assets from executables are not possible.
const cssStyle = '''
/* CSS FOR BASE STRUCTURE */

html, body {
  padding: 0;
  margin: 0 auto;
  height: 100%;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Inter, "Helvetica Neue", Arial, "Noto Sans", system-ui, sans-serif;
}

.title {
    font-weight: bold;
    padding-top: 5px;
    padding-bottom: 5px;
}

.content {
    margin-bottom: 8px;
}

.base-row {
    display: flex;
    align-items: flex-start;
    gap: 16px;
    margin-top: 16px;
}

.col-relevance {
    font-size: 14px;
    font-weight: bold;
    flex: 0 0 32px;               
    border: 1px solid #000;
    padding: 4px;
    box-sizing: border-box;
}

.col-content {
    flex: 1 1 auto;
}

/* CSS FOR LOCAL REGULATION HTML */

img {
    height: auto !important;
    max-width: 100% !important;
}

.row>.col-sm-3>.row>.col-sm-3,
.row>.col-sm-9>.row>.col-sm-3,
.row>.col-sm-3>.row>.col-sm-9,
.row>.col-sm-9>.row>.col-sm-9 {
    all: unset;
}

.row:has(> .row) {
    all: unset;
}

.row {
    display: flex;
    flex-wrap: wrap;
}

.col-sm-3 {
    flex: 0 0 25%;
    max-width: 25%;
    padding: 4px;
    border: 1px solid grey;
}

.col-sm-9 {
    flex: 0 0 73%;
    max-width: 73%;
    padding: 4px;
    border: 1px solid grey;
}

table {
    width: 100%;
    border-collapse: collapse;
    border: 1px solid grey;
}

th,
td {
    border: 1px solid grey;
    padding: 4px;
    text-align: left;
}

th {
    background-color: #e0e0e0;
    font-weight: bold;
}
''';
