defmodule Formless.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    port = Application.get_env(:concoction, :http_port, 8080)
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Formless.Rest, [], port: port)
    ]

    supervise(children, strategy: :one_for_one)
  end

end
