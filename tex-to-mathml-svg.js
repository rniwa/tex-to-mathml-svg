#!/usr/bin/phantomjs

function main() {
    try {
        var system = require('system');
        if (system.args.length < 2) {
            console.error('Specify LaTeX expression.');
            phantom.exit(1);
        }
        var texExpression = system.args[1];

        var webPage = require('webpage');
        var page = webPage.create();
        var results = [];
        page.open(phantom.libraryPath + '/mathjax-sandbox.html', function (status) {
            page.evaluate(function (texExpression) {
                document.body.textContent = '$$' + texExpression + '$$';
            }, texExpression);
            page.onConsoleMessage = function (line) {
                if (line == 'done')
                    phantom.exit(0);
                console.log(line);
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
