defmodule Formless.Store.Queries do
  def shingle_to_cypher({shingle, side, subshingles}) do
    subshingles
    |> Enum.map(&shingle_subshingle_relationship(shingle, side, &1))
  end
  defp shingle_subshingle_relationship(shingle, side, subshingle) do
    predicate = case side do
      :beginning -> "ENDS_WITH"
      :end -> "BEGINS_WITH"
    end
    """
      MERGE (n:Shingle #{node_props(shingle)})
      MERGE (m:Shingle #{node_props(subshingle)})
      MERGE (n)-[:#{predicate}]->(m)
      WITH m
      MATCH (s:Shingle)-[:ENDS_WITH]->(m)<-[:BEGINS_WITH]-(t:Shingle)
      MERGE (s)-[:LEADS]->(t)
      MERGE (s)<-[:FOLLOWS]-(t)
    """
  end
  defp node_props(shingle) do
    text = Enum.join(shingle)
    textEscaped = Poison.encode! text
    numTokens = length(shingle)
    "{text: #{textEscaped}, numTokens: #{numTokens}, length: #{String.length(text)}}"
  end
  
  def traversal(seed, overlap=3) do
    """
    var cursor = g.V("whenever anyone asks what the").ToValue();
    g.Emit(cursor);
    var get_random = function(result){
      var index = Math.floor(Math.random()*result.length);
      return result[index];
    }
    var find_next = function(id){
      for(var i=2; i>=1; i--){
        ret = get_random(g.V(id).LabelContext('twitter2').Out('ends_with_'+i).In('begins_with_'+i).ToArray());
        if(ret && ret != id)
          return ret;
      }
    }
    for(var i=0; i<13 && cursor; i++){
      cursor = find_next(cursor);
      g.Emit(cursor);
    }
    """
  end
end
