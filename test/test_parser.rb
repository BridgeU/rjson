require 'minitest/autorun'
require 'rjson/parser'
require 'rjson/tokenizer'
require 'rjson/stream_tokenizer'
require 'json'
require 'stringio'

module RJSON
  class TestParser < MiniTest::Unit::TestCase
    def test_array
      assert_parses_as('["foo",null,true]',
                       '["foo",null,true]')
    end

    def test_truncated_array
      assert_parses_as('["foo","_truncated"]',
                       '["foo",nul')
    end

    def test_truncated_number_in_array
      assert_parses_as('["foo","_truncated"]',
                       '["foo",1')
    end

    def test_truncated_array_ends_with_comma
      assert_parses_as('["foo","_truncated"]',
                       '["foo",')
    end

    def test_truncated_array_ends_with_opening_square_bracket
      assert_parses_as('["foo",[],"_truncated"]',
                       '["foo",[')
    end

    def test_does_not_touch_untruncated_number_in_array
      assert_parses_as('["foo",1]',
                       '["foo",1]')
    end

    def test_truncated_value_in_nested_array
      assert_parses_as('["foo",[10.3,["bar"]],"_truncated"]',
                       '["foo",[10.3,["bar",fals')
    end

    def test_object
      assert_parses_as('{"foo":{"bar":null}}',
                       '{"foo":{"bar":null}}')
    end

    def test_truncated_object
      assert_parses_as('{"foo":true,"_truncated":true}',
                       '{"foo":true,"bar":fals')
    end

    def test_truncated_first_value_in_object
      assert_parses_as('{"_truncated":true}',
                       '{"foo":tru')
    end

    def test_truncated_number_in_object
      assert_parses_as('{"foo":13.5,"_truncated":true}',
                       '{"foo":13.5,"bar":1')
    end

    def test_does_not_touch_untruncated_number_in_object
      assert_parses_as('{"foo":13.5,"bar":1}',
                       '{"foo":13.5,"bar":1}')
    end

    def test_truncated_value_in_nested_object
      assert_parses_as('{"foo":13.5,"bar":{},"_truncated":true}',
                       '{"foo":13.5,"bar":{"baz":fals')
    end

    def test_truncated_object_key
      assert_parses_as('{"foo":true,"_truncated":true}',
                       '{"foo":true,"ba')
    end

    def test_truncated_object_ends_with_complete_key
      assert_parses_as('{"foo":true,"_truncated":true}',
                       '{"foo":true,"bar"')
    end

    def test_truncated_object_ends_with_colon
      assert_parses_as('{"foo":true,"_truncated":true}',
                       '{"foo":true,"bar":')
    end

    def test_truncated_object_ends_with_comma
      assert_parses_as('{"foo":true,"_truncated":true}',
                       '{"foo":true,')
    end

    def test_truncated_object_ends_with_opening_curly
      assert_parses_as('{"foo":{},"_truncated":true}',
                       '{"foo":{')
    end

    def test_truncated_object_ends_with_decimal_point
      assert_parses_as('{"foo":true,"_truncated":true}',
                       '{"foo":true,"foo_fraction":0.')
    end

    def test_invalid_but_not_trucated_json_raises_exception
      skip "until our parser can reject invalid but not truncated JSON"
      parser = new_parser '{"foo":}'
      assert_raises(Racc::ParseError) do
        parser.parse.result
      end
    end

    private

    def assert_parses_as(expected, actual)
      parser = new_parser actual
      assert_equal(
        expected, parser.parse.result.to_json,
        "Expected #{actual.inspect} to parse as #{expected.inspect}"
      )
    end

    def new_parser string
      tokenizer = Tokenizer.new StringIO.new string
      Parser.new tokenizer
    end
  end
end
