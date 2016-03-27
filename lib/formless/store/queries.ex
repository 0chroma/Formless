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
      MERGE (n:Shingle #{node_props(shingle)})
      #{bucket_property("n", bucket)}
      MERGE (m:Shingle #{node_props(subshingle)})
      #{bucket_property("m", bucket)}
      MERGE (n)-[r1:#{predicate}]->(m)
      #{bucket_property("r1", bucket)}
      WITH m
      MATCH (s:Shingle)-[:ENDS_WITH]->(m)<-[:BEGINS_WITH]-(t:Shingle)
      MERGE (s)-[r2:LEADS]->(t)
      #{bucket_property("r2", bucket)}
      MERGE (s)<-[r3:FOLLOWS]-(t)
      #{bucket_property("r3", bucket)}
    """
  end
  defp bucket_property(ref, bucket) do
    bucket_escaped = Poison.encode! bucket
    """
      ON CREATE SET #{ref}.bucket=[#{bucket_escaped}]
      ON MATCH SET #{ref}.bucket = FILTER(x in #{ref}.bucket WHERE NOT(x=#{bucket_escaped})) + #{bucket_escaped}
    """
  end
  defp node_props(shingle) do
    text = Enum.join(shingle)
    text_escaped = Poison.encode! text
    num_tokens = length(shingle)
    "{text: #{text_escaped}, numTokens: #{num_tokens}, length: #{String.length(text)}}"
  end
  
  def traversal(seed, overlap=3) do
    """
    MATCH p=(n:Shingle)-[:LEADS*1..5]->(m:Shingle)
    WHERE "mybucket" in n.bucket
    RETURN p
    """
  end
end
