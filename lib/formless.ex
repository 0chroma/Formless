defmodule Formless do
  use Application

  def start(_type, _args) do
    Formless.Supervisor.start_link
  end
end
