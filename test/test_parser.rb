require 'minitest/autorun'
require 'rjson/parser'
require 'rjson/tokenizer'
require 'rjson/stream_tokenizer'
require 'json'
require 'stringio'

module RJSON
  class TestParser < MiniTest::Unit::TestCase
    [
      [
        'array',
        '["foo",null,true]',
        '["foo",null,true]'
      ],
      [
        'object',
        '{"foo":{"bar":null}}',
        '{"foo":{"bar":null}}'
      ]
    ].each do |test_case|
      define_method("test_#{test_case.first}") do
        parser = new_parser test_case[1]
        r = parser.parse.result
        r_as_json = r.to_json
        assert_equal(test_case.last, r_as_json)
      end
    end

    def new_parser string
      tokenizer = Tokenizer.new StringIO.new string
      Parser.new tokenizer
    end
  end
end
