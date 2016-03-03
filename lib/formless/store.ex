defmodule Formless.Store do
  alias Formless.Store.Analysis

  def write(bucket, text) do
    text
    |> Analysis.ngrams()
    |> Enum.each(&write_quads(bucket, &1))
  end

  defp write_quads(bucket, ngram) do
    Enum.each [:begins_with, :ends_with], fn(predicate) ->
      ngram
      |> split_to_quads(predicate)
      |> Enum.each(&write_quad(bucket, ngram, predicate, &1))
    end
  end

  defp split_to_quads(ngram, predicate) when predicate in [:begins_with, :ends_with] do
    #TODO
  end

  defp write_quad(bucket, ngram, predicate, words) when predicate in [:begins_with, :ends_with] do
    # TODO: should we use `length(ngram)` in the label/predicate so we can only query ngrams of length n?
    Formless.Graph.write(%{
      subject: Enum.join(ngram, " "),
      predicate: Atom.to_string(predicate),
      object: Enum.join(words, " "),
      label: bucket
    })
  end
end
