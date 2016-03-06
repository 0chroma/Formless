defmodule Formless.Store.Quads do
  def write(bucket, ngram) do
    Enum.each [:begins_with, :ends_with], fn(predicate) ->
      ngram
      |> split_to_quads(predicate)
      |> Enum.each(&write_quad(bucket, ngram, predicate, &1))
    end
  end

  defp split_to_quads([], _) do
    []
  end
  defp split_to_quads(ngram, predicate) do
    drop_from = case predicate do
      :ends_with -> 1
      :begins_with -> -1
    end
    [Enum.drop(ngram, drop_from)] ++ split_to_quads(Enum.drop(ngram, drop_from*2), predicate)
  end

  defp write_quad(bucket, ngram, predicate, words) when predicate in [:begins_with, :ends_with] do
    # TODO: should we use `length(ngram)` in the label/predicate so we can only query ngrams of length n?
    Formless.Graph.write(%{
      subject: Enum.join(ngram, " "),
      predicate: "#{Atom.to_string(predicate)}_#{length(words)}",
      object: Enum.join(words, " "),
      label: bucket
    })
  end
end
