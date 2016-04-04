defmodule Formless.Store do
  alias Formless.Store.Queries
  alias Formless.Analysis.Tokens
  alias Formless.Analysis.Text
  alias Neo4j.Sips, as: Neo4j

  def write(bucket, text) do
    #TODO: add sentence guids so we can find overlap between unique sentences from the same source
    text
    |> Tokens.sentences_from_text() # list of sentences
    |> Enum.map(&Tokens.words_from_text(&1)) # list of tokenized sentences
    |> Enum.flat_map(&shingles(&1)) # list of {shingle, side, [subshingles]} from each sentence
    |> Enum.flat_map(&Queries.shingle_to_cypher(&1, bucket)) # list of cypher query strings
    |> query_neo4j()
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

  defp query_neo4j(query) do
    Neo4j.query Neo4j.conn, query
  end
  defp query_neo4j!(query) do
    Neo4j.query! Neo4j.conn, query
  end

  def query_random(source_bucket, dest_bucket) do
    Queries.random_path(source_bucket, dest_bucket)
    |> query_neo4j!()
    |> intersect_result()
  end
  
  defp intersect_result(result) do
    if length(result) > 0 do
      [%{"p" => [node1, relationship, node2]}] = result
      %{"text" => first} = node1
      %{"text" => last} = node2
      Text.intersect(first, last)
    else
      ""
    end
  end
end
