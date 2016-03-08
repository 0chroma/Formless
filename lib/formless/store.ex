defmodule Formless.Store do
  alias Formless.Store.Quad
  alias Formless.Store.Ngram
  alias Neo4j.Sips, as: Neo4j

  def write(bucket, text) do
    text
    |> Ngram.from_text()
    |> Enum.flat_map(&Ngram.to_quads(&1, bucket))
    |> write_cypher()
  end

  defp write_cypher(quads) do
    queries = Enum.map quads, &Quad.to_cypher_merge(&1)
    IO.puts Enum.join queries, "\n"
    Neo4j.query Neo4j.conn, queries
  end

end
