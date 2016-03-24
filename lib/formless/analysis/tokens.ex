defmodule Formless.Analysis.Tokens do
  def from_text(text, strategy \\ :regex, opts \\ []) do
    tokenizer = Module.concat(Formless.Analysis.Tokenizer, String.capitalize(Atom.to_string(strategy)))
    tokenizer.tokenize(text, opts)
  end

  def group_by_sentence(tokens) do

  end

  def edge_shingle(tokens) do

  end

  def matching_pair_characters?(tokens) do

  end

  def stopwords(tokens) do

  end
end
