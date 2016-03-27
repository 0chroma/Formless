defmodule Formless.Store do
  alias Formless.Store.Quad
  alias Formless.Analysis.Tokens
  alias Neo4j.Sips, as: Neo4j

  def write(bucket, text) do
    text
    |> Tokens.sentences_from_text() # list of sentences
    |> Enum.map(&Tokens.words_from_text(&1)) # list of tokenized sentences
    |> Enum.flat_map(&subshingles(&1)) # list of {shingle, [subshingles]} from each sentence
    |> IO.inspect()
  end

  defp subshingles(tokens) do
    Enum.flat_map [:beginning, :end], fn(side) ->
      Tokens.edge_shingles(tokens, side, 3)
      |> Enum.map(&{&1, Tokens.edge_shingles(&1, opposite_side(side))})
    end
  end
  defp opposite_side(:beginning), do: :end
  defp opposite_side(:end), do: :beginning

  defp write_cypher(quads) do
    queries = Enum.map quads, &Quad.to_cypher_merge(&1)
    IO.puts Enum.join queries, "\n"
    Neo4j.query Neo4j.conn, queries
  end
end
