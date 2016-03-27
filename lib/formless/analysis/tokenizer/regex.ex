defmodule Formless.Analysis.Tokenizer.Regex do
  @behaviour Formless.Analysis.Tokenizer

  @token_pattern ~r/(?<=(\p{Po}|\p{Ps}|\s))|(?=(\p{Po}|\p{Pe}|\s))/u
  def tokenize(text, opts \\ []) do
    regex = Keyword.get(opts, :regex, @token_pattern)
    String.split(text, regex, trim: true)
  end
end
