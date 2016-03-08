defmodule Formless.Store.Quad do
  defstruct [:ngram, :predicate, :subgram, :bucket]
  alias Formless.Store.Quad

  def to_cypher(%Quad{}=quad) do
    source = to_cypher_node(quad, :ngram, "n")
    target = to_cypher_node(quad, :subgram, "m")
    predicate = to_cypher_relationship(quad)
    "#{source}#{predicate}#{target}"
  end

  def to_cypher_relationship(%Quad{predicate: predicate}) do
    predicate = predicate |> Atom.to_string() |> String.upcase()
    "-[:#{predicate}]->"
  end

  def to_cypher_node(%Quad{} = quad, part, label) when part in [:ngram, :subgram] do
    "(#{label}:Ngram #{cypher_node_properties quad, part})"
  end

  defp cypher_node_properties(%Quad{bucket: bucket} = quad, part) do
    ngram = Map.get(quad, part)
    text = ngram |> Enum.join(" ") |> Poison.encode!()
    bucket = Poison.encode! bucket
    "{text: #{text}, bucket: #{bucket}, tokens: #{length(ngram)}, characters: #{String.length(text)}}"
  end

  def to_cypher_merge(quad) do
    """
    MERGE #{Quad.to_cypher_node(quad, :ngram, "s")}
    MERGE #{Quad.to_cypher_node(quad, :subgram, "t")}
    MERGE (s)#{Quad.to_cypher_relationship(quad)}(t)
    """
  end

end
