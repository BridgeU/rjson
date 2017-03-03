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
        'truncated_array',
        '["foo",nul',
        '["foo"]'
      ],
      [
        'truncated_number_in_array',
        '["foo",1',
        '["foo"]'
      ],
      [
        'truncated_array_ends_with_comma',
        '["foo",',
        '["foo"]'
      ],
      [
        'truncated_array_ends_with_opening_square_bracket',
        '["foo",[',
        '["foo",[]]'
      ],
      [
        'does_not_touch_uncorrupted_number_in_array',
        '["foo",1]',
        '["foo",1]'
      ],
      [
        'truncated_value_in_nested_array',
        '["foo",[10.3,["bar",fals',
        '["foo",[10.3,["bar"]]]'
      ],
      [
        'object',
        '{"foo":{"bar":null}}',
        '{"foo":{"bar":null}}'
      ],
      [
        'truncated_object',
        '{"foo":true,"bar":fals',
        '{"foo":true}'
      ],
      [
        'truncated_first_value_in_object',
        '{"foo":tru',
        '{}'
      ],
      [
        'truncated_number_in_object',
        '{"foo":13.5,"bar":1',
        '{"foo":13.5}'
      ],
      [
        'does_not_touch_uncorrupted_number_in_object',
        '{"foo":13.5,"bar":1}',
        '{"foo":13.5,"bar":1}'
      ],
      [
        'corrupted_value_in_nested_object',
        '{"foo":13.5,"bar":{"baz":fals',
        '{"foo":13.5,"bar":{}}'
      ],
      [
        'corrupted_object_key',
        '{"foo":true,"ba',
        '{"foo":true}'
      ],
      [
        'corrupted_object_ends_with_complete_key',
        '{"foo":true,"bar"',
        '{"foo":true}'
      ],
      [
        'corrupted_object_ends_with_colon',
        '{"foo":true,"bar":',
        '{"foo":true}'
      ],
      [
        'corrupted_object_ends_with_comma',
        '{"foo":true,',
        '{"foo":true}'
      ],
      [
        'corrupted_object_ends_with_opening_curly',
        '{"foo":{',
        '{"foo":{}}'
      ],
      [
        'corrupted_object_ends_with_decimal_point',
        '{"foo":true,"foo_fraction":0.',
        '{"foo":true}'
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
