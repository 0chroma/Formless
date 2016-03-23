defmodule Formless.Analysis.Tokenizer do
  @type opts :: [any]
  @callback tokenize(String.t, opts) :: [String.t]
end
