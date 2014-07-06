module TexToMathMLSVG

    # This generator is EXTREMELY slow as it invokes PhantomJS.
    # As such, it exits early when running inside "serve -w".
    # Configuration Options
    # tex_to_mathml_svg:
    #     phantomjs: The absolute path to PhantomJS binary. Defaults to /usr/bin/
    #     enable_in_serve_watch: Enables the generator in "serve -w" when set true.
    #     omit_mathml: Disables MathML generation.

    class TexToMathMLSVG < Jekyll::Generator
        safe false

        DEFAULT_PHANTOMJS_PATH = '/usr/bin/phantomjs'
        private_constant :DEFAULT_PHANTOMJS_PATH

        @full_generation = true
        @disable_mathml = false
        @phantomjs = nil
        @converterjs = nil

        def generate(site)
            config = site.config['tex_to_mathml_svg'] || {}

            # FIXME: Figure out a better way to avoid running inside serve -w
            @full_generation = ARGV[0] != 'serve' || config['enable_in_serve_watch']
            @disable_mathml = config['disable_mathml']

            @phantomjs = config['phantomjs'] || DEFAULT_PHANTOMJS_PATH
            @converterjs = File.join(File.dirname(__FILE__), '/tex-to-mathml-svg.js')

            site.pages.each { |page| convert(page) }
            site.posts.each { |post| convert(post) }
        end

        private
        def convert(page_or_post)
            page_or_post.content.gsub!(/\$\$([^$]+)\$\$|\$([^$\n]+)\$/) do |match|
                expression = $1 || $2
                classes = $1 ? 'out-of-line-math' : 'inline-math'
                lines = []

                if !@full_generation
                    "<b>#{expression}</b>"
                else
                    IO.popen([@phantomjs, @converterjs, expression]) { |io|
                        io.each_line { |line| lines.push(line.strip()) }
                        # FIXME: Figure out how to report errors properly
                        print "Failed to convert", expression, "\n", lines if lines[-1] != 'done'
                    }
                    mathml = lines[1].gsub(/\<\!\-\- [^\>]+ \-\-\>/, '')
                    mathml_markup = @disable_mathml ? '' : '<span class="mathml">' + mathml + '</span>'
                    svg = lines[2]
                    "<span class=\"math #{classes}\" title=\"#{expression}\">#{mathml_markup}<span class=\"svg\">#{svg}</span></span>"
                end
            end
        end

    end
end
