tex-to-mathml-svg
=================

Converts TeX expression into MathML and SVG using MathJax and PhantomJS.

Install [PhantomJS](http://phantomjs.org) into `/usr/bin/` and run `tex-to-mathml-svg.js`
or manually invoke the script as follows, which would emit the original expression, MathML, and SVG:

```<PathToPhantomJS>/phantomjs tex-to-mathml-svg.js "y = 2x + 1" "\frac{1}{2}"```

When multiple expressions are passed into the script, the generated SVG markups share the glyph definitions
included in the first SVG so they all need to appear in a single document.

# Integrating into Jekyll

You can also use it as a Jekyll plugin. Put it into your site's `_plugins` directory.
The following configuration options are available in _config.yml under tex_to_mathml_svg:

- `phantomjs`: The absolute path to PhantomJS binary. Defaults to `/usr/bin/phantomjs`
- `enable_in_serve_watch`: Since this plugin is extremely slow, it doesn't run inside `serve -w` by default.
  Set this option to true to generate MathML/SVG inside `serve -w`.
- `disable`: Always disables the MathML/SVG generation when set true.
- `disable_mathml`: Disables MathML generation.
- `inline_start`: The delimiter for the start of an inline (contains no new line) TeX expression. Defatuls to `$`.
- `inline_end`: Ditto for the end.
- `outofline_start`: The delimiter for the start of an out-of-line MathML expression. Defaults to `$$`.
- `outofline_end`: Ditto for the end.
