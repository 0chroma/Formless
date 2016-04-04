defmodule Formless.Store.Backup do
  # Store for backing up indexed data
  # Will be used for reindexing at some point
  use GenServer

  # Client API
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  # Server API
  def init(:ok) do
    store = Exleveldb.open("/tmp/formless.db", [{:create_if_missing, :true}]) #TODO conf param
    {:ok, %{store: store}}
  end
end
