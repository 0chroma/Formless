defmodule Formless.Rest do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/index_text" do
    send_resp(conn, 200, "ok")
  end

  get "/query_random" do
    send_resp(conn, 200, "TODO")
  end

  match _ do
    send_resp(conn, 404, "method not found")
  end
end
