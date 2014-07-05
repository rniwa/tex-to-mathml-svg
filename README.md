tex-to-mathml-svg
=================

Converts TeX expression into MathML and SVG using MathJax and PhantomJS.

Install [PhantomJS](http://phantomjs.org) into `/usr/bin/` and run `tex-to-mathml-svg.js`
or manually invoke the script as follows, which would emit the original expression, MathML, and SVG:

```<PathToPhantomJS>/phantomjs tex-to-mathml-svg.js "y = 2x + 1"```
