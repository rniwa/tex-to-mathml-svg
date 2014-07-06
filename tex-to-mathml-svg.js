#!/usr/bin/phantomjs

function main() {
    try {
        var system = require('system');
        if (system.args.length < 2) {
            console.error('Specify LaTeX expressions.');
            phantom.exit(1);
        }
        var texExpressions = system.args.slice(1);

        var webPage = require('webpage');
        var page = webPage.create();
        var results = [];
        page.open(phantom.libraryPath + '/mathjax-sandbox.html', function (status) {
            page.evaluate(function (texExpressions) {
                var content = texExpressions.reduce(function (text, exp) { return text + ' $$ ' + exp + ' $$ '; }, '');
                document.body.textContent = content;
            }, texExpressions);
            page.onConsoleMessage = function (line) {
                console.log(line);
                if (line == 'done')
                    phantom.exit(0);
            }
        });

        setTimeout(function () {
            console.error("MaxJax couldn't convert the expression in 3s");
            phantom.exit(2);
        }, 3000);

    } catch (error) {
        console.error("Encountered an unexpected error:", error);
        phantom.exit(-1);
    }
}

main();
