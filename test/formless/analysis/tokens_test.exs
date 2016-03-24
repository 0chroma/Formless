defmodule Formless.Analysis.TokensTest do
  use ExUnit.Case, async: true

  alias Formless.Analysis.Tokens

  test "from text" do
    assert Tokens.from_text("Hello! This is a \"string\".") == ["Hello", "!", "This", "is", "a", "\"", "string", "\"", "."]
    assert Tokens.from_text("Here's (some parenthesis) to test.") == ["Here's", "(", "some", "parenthesis", ")", "to", "test", "."]
  end

  test "group by sentence" do
    tokens = [
      "This", ",", "is", "a", "\"", "test", "\"", "sentence", ".",
      "It", "has", "(", "lots", "of", ")", "punctuation", ",", "but", "{", "only", "}",
      "splits", "on", "\"", ".", "\"", "characters", "."
    ]
    output = [
      ["This", ",", "is", "a", "\"", "test", "\"", "sentence", "."],
      ["It", "has", "(", "lots", "of", ")", "punctuation", ",", "but", "{", "only", "}",
      "splits", "on", "\"", ".", "\"", "characters", "."]
    ]
    assert Tokens.group_by_sentence(tokens) == output
  end
end
