defmodule Formless.Analysis.TokensTest do
  use ExUnit.Case, async: true

  alias Formless.Analysis.Tokens

  test "words from text" do
    assert Tokens.words_from_text("Hello! This is a \"string\".") == ["Hello", "!", " ", "This", " ", "is", " ", "a", " ", "\"", "string", "\"", "."]
    assert Tokens.words_from_text("Here's (some parenthesis) to test.") == ["Here", "'", "s", " ", "(", "some", " ", "parenthesis", ")", " ", "to", " ", "test", "."]
    assert Tokens.words_from_text("\"String\" at front") == ["\"", "String", "\"", " ", "at", " ", "front"]
  end

  test "sentences from text" do
    input = "Hans Rudolf \"Ruedi\" Giger (/ˈɡiːɡər/ ghee-gur; German: [ˈɡiːɡər]; 5 February 1940 – 12 May 2014) was a Swiss surrealist painter, whose style was adapted for many media, including record-albums, furniture and tattoo-art. His paintings are on display at the H.R. Giger Museum at Gruyères."
    output = [
      "Hans Rudolf \"Ruedi\" Giger (/ˈɡiːɡər/ ghee-gur; German: [ˈɡiːɡər]; 5 February 1940 – 12 May 2014) was a Swiss surrealist painter, whose style was adapted for many media, including record-albums, furniture and tattoo-art.",
      "His paintings are on display at the H.R. Giger Museum at Gruyères."
    ]
    assert Tokens.sentences_from_text(input) == output
  end

  test "edge shingles" do
    output = [
      ["Test", "sentence", "please", "ignore"],
      ["Test", "sentence", "please"],
      ["Test", "sentence"],
      ["Test"],
      ["sentence", "please", "ignore", "."],
      ["please", "ignore", "."],
      ["ignore", "."],
      ["."]
    ]
    assert Tokens.edge_shingles(["Test", "sentence", "please", "ignore", "."]) == output
    assert Tokens.edge_shingles(["Test", "sentence", "please", "ignore", "."], :both, 1, 3) == Enum.filter(output, &(length(&1) <= 3))
    assert Tokens.edge_shingles(["Test", "sentence", "please", "ignore", "."], :both, 3) == Enum.filter(output, &(length(&1) >= 3))
  end
  
  test "shingles" do
    output = [
      ["1", "2", "3"], ["2", "3", "4"], ["1", "2"], ["2", "3"], ["3", "4"]
    ]
    assert Tokens.shingles(["1", "2", "3", "4"]) == output
  end
end
