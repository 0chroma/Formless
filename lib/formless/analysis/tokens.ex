defmodule Formless.Analysis.Tokens do
  def words_from_text(text, strategy \\ :regex, opts \\ []) do
    tokenizer = Module.concat(Formless.Analysis.Tokenizer, String.capitalize(Atom.to_string(strategy)))
    tokenizer.tokenize(text, opts)
  end

  def sentences_from_text(text, check_capitals \\ false) do
    # There are better algorithms for doing this (ie punkt)
    # but I don't want to spend too much time on this
    
    regex = case check_capitals do
      true -> ~r/((?<=[a-z0-9][.?!])|(?<=[a-z0-9][.?!]\"))(\s|\r\n)(?=\"?[A-Z])/u
      false -> ~r/((?<=[a-z0-9][.?!])|(?<=[a-z0-9][.?!]\"))(\s|\r\n)/u
    end
    String.split(text, regex)
  end

  def edge_shingles(tokens, min_size \\ 1, max_size \\ :infinity) do
    edge_shingles(tokens, min_size, max_size, -1)
    ++ edge_shingles(tokens, min_size, max_size, 1)
  end

  def edge_shingles([], _, _, _) do
    []
  end
  def edge_shingles(tokens, min_size, _, _) when length(tokens) <= min_size do
    []
  end
  def edge_shingles(tokens, min_size, max_size, side) when length(tokens) - 1 > max_size do
    edge_shingles(Enum.drop(tokens, side), min_size, max_size, side)
  end
  def edge_shingles(tokens, min_size, max_size, side) do
    shingle = Enum.drop(tokens, side)
    [shingle] ++ edge_shingles(shingle, min_size, max_size, side)
  end

  def shingles(tokens) do
    shingles(tokens, length(tokens)-1)
  end
  def shingles(_, 1) do
    []
  end
  def shingles(tokens, n) when n > 1 do
    sublists(tokens, n) ++ shingles(tokens, n-1)
  end

  defp sublists(list, n) when length(list) == n do
    [list]
  end
  defp sublists(list = [_|tail], n) do
    [Enum.take(list, n)] ++ sublists(tail, n)
  end

  def matching_pair_characters?(tokens) do
    # TODO: this would be a nice to have but not necessary
  end

  def stopwords(tokens) do
    # TODO: this would be a nice to have but not necessary
  end
end
