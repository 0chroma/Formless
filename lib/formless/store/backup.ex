defmodule Formless.Store.Backup do
  # Store for backing up indexed data
  # Will be used for reindexing at some point
  use GenServer

  # Client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  def write_text(server, bucket, text) do
    GenServer.call(server, {:write_text, bucket, text})
  end

  def text_stream(server, bucket) do
    Stream.unfold 1, fn(index) ->
      case GenServer.call(server, {:get_text, bucket, index}) do
        {:ok, text} -> {text, index + 1}
        :done -> nil
      end
    end
  end

  def stop(server, reason, timeout) do
    GenServer.stop(server, reason, timeout)
  end


  # Server API

  def init(:ok) do
    data_dir = Application.get_env(:formless, :data_directory, "/tmp")
    db_path = Path.join(data_dir, "backup.db")
    {:ok, store} = Exleveldb.open(db_path, [create_if_missing: true])

    {:ok, %{store: store}}
  end

  defp get_counters(store) do
    case Exleveldb.get(store, "counters") do
      {:ok, counters} -> :erlang.binary_to_term(counters)
      :not_found -> %{}
    end
  end

  defp get_counter(store, bucket) do
    counters = get_counters(store)
    counters[bucket] || 0
  end

  defp increment_counter(store, bucket) do
    counters = get_counters(store)
    value = (counters[bucket] || 0) + 1
    counters = Map.put(counters, bucket, value)
    :ok = Exleveldb.put(store, "counters", :erlang.term_to_binary(counters))
    value
  end

  defp clear_counter(store, bucket) do
    counters = get_counters(store)
    counters = Map.delete(counters, bucket)
    :ok = Exleveldb.put(store, "counters", :erlang.term_to_binary(counters))
  end

  def handle_call({:write_text, bucket, text}, _from, %{store: store} = state) do
    next = increment_counter(store, bucket)
    :ok = Exleveldb.put(store, "buckets.#{bucket}.#{next}", text)
    {:reply, :ok, state}
  end

  def handle_call({:get_text, bucket, index}, _from, %{store: store} = state) do
    if index > get_counter(store, bucket) do
      {:reply, :done, state}
    else
      case Exleveldb.get(store, "buckets.#{bucket}.#{index}") do
        {:ok, value} -> {:reply, {:ok, value}, state}
        :not_found -> {:reply, {:ok, nil}, state} # hopefully this never happens?
      end
    end
  end

  def terminate(_reason, %{store: store}) do
    Exleveldb.close(store)
  end
end
