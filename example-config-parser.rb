require 'parslet'
require_relative 'ini-parser'
require_relative 'setting-converter'

module SDDMConfigurationEditor
  class ExampleConfigTransform < Parslet::Transform
    rule(line: simple(:line)) {
      line.str.strip
    }

    rule(lines: sequence(:lines)) {
      lines
    }

    rule(comment: sequence(:_comment),
         key: simple(:_key),
         value: subtree(:_value)) {
      key = _key.str.strip
      value = _value == [] ? '' : _value.str.strip
      (type, key, default) = Setting.convert(key, value)
      {label: _comment && _comment.first || '',
       description: _comment && _comment[1] && _comment[1..-1].join("\n") || '',
       key: key, type: type, default_value: default}
    }

    rule(comment: subtree(:_comment),
         name: simple(:_name),
         settings: subtree(:_settings)) {
      {section: _name.str,
       settings: _settings}
    }

    rule(sections: subtree(:_sections)) {
      _sections
    }
  end

  class ExampleConfigParser
    def initialize
      @parser = INIParser.new
      @transform = ExampleConfigTransform.new
    end

    def parse(text, *options)
      @transform.apply @parser.parse(text, *options)
    end
  end
end
