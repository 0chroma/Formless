defmodule Formless.Store.Query do
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
