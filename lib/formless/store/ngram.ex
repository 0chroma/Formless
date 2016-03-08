defmodule Formless.Store.Ngram do
  alias Formless.Store.Quad
  alias Gibran.Tokeniser

  @token_pattern ~r/\s|(?<=\p{Po})|(?=\p{Po})/u
  @sentence_end_pattern ~r/\p{Po}/u

  # Text related functions

  def from_text(text, opts \\ []) do
    # This would be more performant if it accepted a text stream, but I think you can
    # just chunk text by paragraph and the ngram output should still be useful enough.
    length = Keyword.get opts, :length, 6 #TODO: this will break if there aren't 6 tokens in text!
    # We're going to need a different tokenizer for asian languages sadly
    text
    |> Tokeniser.tokenise([pattern: @token_pattern])
    |> ngramize_list(length)
  end

  defp ngramize_list(_, 1) do
    []
  end
  defp ngramize_list(list, n) when n > 1 do
    sublists(list, n) ++ ngramize_list(list, n-1)
  end

  defp sublists(list, n) when length(list) == n do
    [list]
  end

  defp sublists(list = [_|tail], n) do
    [Enum.take(list, n)] ++ sublists(tail, n)
  end

  # Quad related functions

  def to_quads(ngram, bucket) do
    Enum.flat_map [:begins_with, :ends_with], &split_to_quads(ngram, &1, bucket)
  end

  defp split_to_quads([], _, _) do
    []
  end
  defp split_to_quads(ngram, predicate, bucket) do
    drop_from = case predicate do
      :ends_with -> 1
      :begins_with -> -1
    end
    [
      %Quad{
        ngram: ngram,
        predicate: predicate,
        subgram: Enum.drop(ngram, drop_from),
        bucket: bucket
      }
    ] ++ split_to_quads(Enum.drop(ngram, drop_from*2), predicate, bucket)
  end

end
