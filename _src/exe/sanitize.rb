#!/usr/bin/env ruby

require 'pp'
require 'kramdown'
require 'yaml'
require 'fileutils'

IN = File.expand_path('../intermediate/parsed', __dir__)
OUT = File.expand_path('../intermediate/sanitized', __dir__)

def sanitize_line(source, ln)
  return ln if ln.start_with?('    ') # It's code, don't touch it!

  ln
    .gsub(/(?<=[^`])([A-Z][a-zA-Z:]+[#][a-z_?!\[\]=]+)(?=[^`a-z_?!=\[\]]|$)/, '`\1`')   # FooBar#foobar, always method reference
    .gsub(/(?<= |^)([#][a-z_?!\[\]=]+)(?=[^`a-z_?!=\[\]]|$)/, '`\1`')                   # #foobar, always method reference
    .gsub(/(?<=[^`])(__[A-Z_]+__)(?=[^`])/, '`\1`')
    .gsub(/(?<=[a-z])`(?=[a-z])/, "'")                                                  # Fancy apostrophe for typesetting
    .gsub('---', '—')                                                                   # Just dash. Probably should be done smarter
end

FileUtils.rm_rf OUT

Dir["#{IN}/**/*.md"].each do |source|
  target = source.sub('/parsed/', '/sanitized/')
  content = File.read(source)
    .sub(/\A\#\s*-\*-[^\n]+\n/, '') # First line with settings to editor
    .strip
    .gsub("ruby-talk:69518\n:   ", "[ruby-talk:69518] ")    # Just broken by rdoc2markdown
    .gsub(/\n(.+)\n: {3}(?=\S)/, "\n* \\1: ")               # RDoc converts dd/dt this way, no Markdown corresponding syntax...
    .gsub(/`(\w[^\n`']*?)'/, '`\1`')                        # Code pieces wrapped in `foo'
    .gsub("`(?``*name*`')`", "`(?'`*name*`')`")             # Manually fix one case broken by previous line
    .gsub("`enor'", "'enor'")                               # And another one...
    .gsub(/(\n[^\*\n][^\n]+)\n(\* )/, "\\1\n\n\\2")         # List start without empty space after previous paragraph
    .gsub(/(\[RFC\d+\])\s+(?=\(http)/, '\1')                # Remove wrongful spaces in [RFCxxxx] (http://) for Net:: libs
    .split("\n").map { |ln| sanitize_line(source, ln) }
    .join("\n")

  # Per file fixes:
  content =
    case source
    when %r{doc/keywords\.md}
      # TODO: Or maybe fancy table?
      content
        .gsub(/\n\* (\S+):/, "\n* `\\1`:")
    when %r{doc/globals\.md}
      # TODO: Or maybe fancy table?
      content
        .gsub(/\n\* (\S+):/, "\n* `\\1`:")
        .gsub(/(?<=to the |to )(\$.)/, '`\1`')
        .sub('`$s`tderr', '`$stderr`')
        .sub('`$``') { '<code class="highlighter-rouge">$`</code>' } # Without block, '`' has special meaning in sub
        .gsub(/(?<!`)\$(stdin|stdout|DEBUG|VERBOSE)/, '`$\1`')
    when %r{core/Class\.md}
      content.sub('of the class `Class`.', "of the class `Class`.\n") # To properly render the diagram after
    when %r{core/Float\.md}
      content.sub("wiki-floats_i\n    mprecise\n\n", "wiki-floats_imprecise\n")
    when %r{lib/cgi/CGI\.md}
      content.sub("[cgi]('field_name')", "`cgi['field_name']`")
    when %r{lib/irb/IRB\.md}
      content.sub('[IRB.conf](:IRB_RC)', '`IRB.conf[:IRB_RC]`')
    when %r{lib/prime/Prime\.md}
      content
        .sub("e.g.\n    Prime", "e.g.\n\n    Prime")
        .sub('`Prime`.instance', '`Prime.instance`')
        .gsub('`Prime`::`', '`Prime::')
    when %r{core/String\.md}
      content
        .gsub("``!''", "`!`")
    when %r{ext/date/}
      content.sub(/\A.+?\n/, '') # We don't need first header inserted by render script.
    # FIXME: probably could be handled generically (line with a lot of spaces after line without spaces):
    when %r{lib/abbrev/Abbrev\.md}
      content.gsub("*Generates:*\n", "*Generates:*\n\n")
    when %r{lib/logger/Logger\.md}
      content.gsub(/(Log (format|sample)):\n/, "\\1\n\n")
    when %r{lib/pp/PP\.md}
      content.gsub("returns this:\n", "returns this:\n\n")
    when %r{lib/optparse/OptionParser\.md}
      content.gsub(/((Used|output):)\n(?=    bash-3\.2)/, "\\1\n\n")
    when %r{lib/English/English.md}
      content.gsub(/^\* (\$.+?): (\$.+?)$/, '* `\1`: `\2`')
        .sub('`$``') { '<code class="highlighter-rouge">$`</code>' } # Without block, '`' has special meaning in sub
    when %r{_special/kernel\.md}
      content.gsub(/ref:\`(.+?)\`/, 'ref:\1')
    else
      content
    end

  FileUtils.mkdir_p File.dirname(target)
  File.write target, content
end