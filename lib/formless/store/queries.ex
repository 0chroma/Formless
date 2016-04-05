defmodule Formless.Store.Queries do
  def shingle_to_cypher({shingle, side, subshingles}, bucket) do
    subshingles
    |> Enum.map(&shingle_subshingle_relationship(shingle, side, &1, bucket))
  end
  defp shingle_subshingle_relationship(shingle, side, subshingle, bucket) do
    predicate = case side do
      :beginning -> "ENDS_WITH"
      :end -> "BEGINS_WITH"
    end
    """
      MERGE (n:Shingle #{node_props(shingle, side)})
      #{bucket_property("n", bucket)}
      MERGE (m:Shingle #{node_props(subshingle)})
      #{bucket_property("m", bucket)}
      MERGE (n)-[r1:#{predicate}]->(m)
      WITH m
      MATCH (s:Shingle)-[:ENDS_WITH]->(m)<-[:BEGINS_WITH]-(t:Shingle)
      MERGE (s)-[r2:LEADS]->(t)
      MERGE (s)<-[r3:FOLLOWS]-(t)
    """
  end
  defp bucket_property(ref, bucket) do
    bucket_escaped = Poison.encode! bucket
    """
      ON CREATE SET #{ref}.buckets = [#{bucket_escaped}]
      ON MATCH SET #{ref}.buckets = FILTER(x in #{ref}.buckets WHERE NOT(x=#{bucket_escaped})) + #{bucket_escaped}
    """
  end
  defp node_props(shingle, side \\ nil) do
    text = Enum.join(shingle)
    text_escaped = Poison.encode! text
    num_tokens = length(shingle)
    side_part = if side do
      side_string = Atom.to_string side
      ", side: \"#{side_string}\""
    else
      ""
    end
    "{text: #{text_escaped}, numTokens: #{num_tokens}, length: #{String.length(text)}#{side_part}}"
  end
  
  def random_path(source_bucket, target_bucket) do
    # Might not be the most efficient way to query for a random node in large buckets,
    # but I'm not exactly expecting huge amounts of overlap between buckets
    # Could optimize this further by taking a sampling where clause, ie `WHERE rand() > 0.5`
    source_escaped = Poison.encode! source_bucket
    target_escaped = Poison.encode! target_bucket
    """
      MATCH p=(n:Shingle {side: "beginning"})-[:LEADS]->(m:Shingle {side: "end"})
      WHERE #{source_escaped} in n.buckets AND #{target_escaped} in m.buckets
      WITH p, rand() AS r
      ORDER BY r
      RETURN p
      LIMIT 1
    """
  end

  def drop_bucket(bucket) do
    bucket_escaped = Poison.encode! bucket
    """
      MATCH (n:Shingle)
      WHERE #{bucket_escaped} in n.buckets
      SET n.buckets = FILTER(x in n.buckets WHERE NOT(x=#{bucket_escaped}))
      WITH n
      WHERE n.buckets = []
      DETACH DELETE n
    """
  end

  def list_buckets() do
    """
      MATCH (n:Shingle)
      UNWIND n.buckets as bucket
      WITH collect(DISTINCT bucket) as buckets
      RETURN buckets
    """
  end
end
