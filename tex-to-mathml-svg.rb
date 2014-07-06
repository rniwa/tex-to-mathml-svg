module TexToMathMLSVG
    class TexToMathMLSVG < Jekyll::Generator
        safe false

        DEFAULT_PHANTOMJS_PATH = '/usr/bin/phantomjs'
        private_constant :DEFAULT_PHANTOMJS_PATH

        DEFAULT_INLINE_START = '$'
        DEFAULT_INLINE_END = '$'
        DEFAULT_OUTOFLINE_START = '$$'
        DEFAULT_OUTOFLINE_END = '$$'
        private_constant :DEFAULT_INLINE_START, :DEFAULT_INLINE_END, :DEFAULT_OUTOFLINE_START, :DEFAULT_OUTOFLINE_END

        @full_generation = true
        @disable_mathml = false
        @phantomjs = nil
        @converterjs = nil
        @expression_regex = nil

        def generate(site)
            config = site.config['tex_to_mathml_svg'] || {}

            # FIXME: Figure out a better way to avoid running inside serve -w
            @full_generation = !config['disable'] && (ARGV[0] != 'serve' || config['enable_in_serve_watch'])
            @disable_mathml = config['disable_mathml']

            @phantomjs = config['phantomjs'] || DEFAULT_PHANTOMJS_PATH
            @converterjs = File.join(File.dirname(__FILE__), '/tex-to-mathml-svg.js')

            inline_start = Regexp.escape(config['inline_start'] || DEFAULT_INLINE_START)
            inline_end = Regexp.escape(config['inline_end'] || DEFAULT_INLINE_START)
            outofline_start = Regexp.escape(config['outofline_start'] || DEFAULT_OUTOFLINE_START)
            outofline_end = Regexp.escape(config['outofline_end'] || DEFAULT_OUTOFLINE_END)
            @expression_regex = Regexp.new(inline_start + '([^$]+)' + inline_end + '|' + outofline_start + '([^$\n]+)' + outofline_end)

            site.pages.each { |page| convert(page) }
            site.posts.each { |post| convert(post) }
        end

        private
        def convert(page_or_post)
            expressions = []
            page_or_post.content.scan(@expression_regex) { |match|
                expressions.push($1 || $2)
            }

            expression_to_mathml_svg = @full_generation ? generate_mathml_and_svg(expressions) : {}
            return if expression_to_mathml_svg.nil?

            page_or_post.content.gsub!(@expression_regex) do |match|
                expression = ($1 || $2).strip()
                classes = $1 ? 'inline-math' : 'out-of-line-math'
                lines = []

                mathml_svg = expression_to_mathml_svg[expression]

                if !mathml_svg
                    "<b>#{expression}</b>"
                else
                    mathml = mathml_svg[:mathml].gsub(/\<\!\-\- [^\>]+ \-\-\>/, '')
                    mathml_markup = @disable_mathml ? '' : '<span class="mathml">' + mathml + '</span>'
                    svg = mathml_svg[:svg]
                    "<span class=\"math #{classes}\" title=\"#{expression}\">#{mathml_markup}<span class=\"svg\">#{svg}</span></span>"
                end
            end
        end

        private
        def generate_mathml_and_svg(expressions)
            expression_to_mathml_svg = {}
            return {} if expressions.empty?
            IO.popen([@phantomjs, @converterjs] + expressions) do |io|
                current_expression = nil
                current_mathml = nil
                done = false
                io.each_line do |line|
                    if line == "done\n"
                        done = true
                    elsif not line.start_with?(' ')
                        current_expression = line.strip()
                    elsif not current_mathml
                        current_mathml = line.strip()
                    else
                        expression_to_mathml_svg[current_expression] = {:mathml => current_mathml, :svg => line.strip()}
                    end
                end
                # FIXME: Figure out how to report errors properly
                if not done
                    print "Failed to convert", expressions
                    return nil
                end
            end
            return expression_to_mathml_svg
        end
    end
end
