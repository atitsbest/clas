# Command Line Applications verschiedenster Art

## merger.rb
Diese kleine Programm verbindet Html-Seiten mit ausgelagerten Templates
Warum?
Wird eine Single Page Application (SPA) z.b. mit KnockoutJS erstellt, entstehen
mit der Zeit viele Templates die alle in einer Html-Datei liegen. 
Das wird unübersichtlich (und das Syntax-Highlight leidet auch darunter).
Mit diesem Script können die Templates in eigene Dateien ausgelagert werden
um später wieder zu einer einzelnen datei kompiliert zu werden.

Die Templates werden folgendermaßen in die HTML-Datei eingebunden:
  <script id="<template_datei_name_ohne_ext" type="text/template">
    ...template..
 </script>
 
