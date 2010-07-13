use Test::More tests => 10;


use Javascript::Closure qw(:CONSTANTS);

diag('testing constants importation');

ok(WHITESPACE_ONLY eq 'WHITESPACE_ONLY','WHITESPACE_ONLY imported');
ok(SIMPLE_OPTIMIZATIONS eq 'SIMPLE_OPTIMIZATIONS','SIMPLE_OPTIMIZATIONS imported');
ok(ADVANCED_OPTIMIZATIONS eq 'ADVANCED_OPTIMIZATIONS','ADVANCED_OPTIMIZATIONS imported');
ok(COMPILED_CODE eq 'compiled_code','COMPILED_CODE imported');
ok(WARNINGS eq 'warnings','WARNINGS imported');
ok(ERRORS eq 'errors','ERRORS imported');
ok(STATISTICS eq 'statistics','STATISTICS imported');
ok(TEXT eq 'text','TEXT imported');
ok(JSON eq 'json','JSON imported');
ok(XML eq 'xml','XML imported');
