defmodule Formless.Analysis.Tokenizer.Regex do
  @behaviour Formless.Analysis.Tokenizer

  @token_pattern ~r/\s|(?<=\p{Po})|(?=\p{Po})/u
  def tokenize(text, opts \\ []) do
    regex = Keyword.get(opts, :regex, @token_pattern)
    String.split(text, regex, trim: true)
  end
end
