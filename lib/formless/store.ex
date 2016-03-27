defmodule Formless.Store do
  alias Formless.Store.Queries
  alias Formless.Analysis.Tokens
  alias Neo4j.Sips, as: Neo4j

  def write(bucket, text) do
    text
    |> Tokens.sentences_from_text() # list of sentences
    |> Enum.map(&Tokens.words_from_text(&1)) # list of tokenized sentences
    |> Enum.flat_map(&shingles(&1)) # list of {shingle, side, [subshingles]} from each sentence
    |> Enum.flat_map(&Queries.shingle_to_cypher(&1, bucket)) # list of cypher query strings
    |> write_to_neo4j()
  end

  defp shingles(tokens) do
    Enum.flat_map [:beginning, :end], fn(side) ->
      Tokens.edge_shingles(tokens, side, 5)
      |> Enum.map(&subshingles(&1, side))
    end
  end
  defp subshingles(tokens, side), do: {tokens, side, Tokens.edge_shingles(tokens, opposite_side(side), 2)}
  defp opposite_side(:beginning), do: :end
  defp opposite_side(:end), do: :beginning

  defp write_to_neo4j(queries) do
    Neo4j.query Neo4j.conn, queries
  end
end
