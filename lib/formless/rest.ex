defmodule Formless.Rest do
  use Plug.Router

  alias Plug.Conn
  alias Formless.Store

  plug Plug.Parsers, parsers: [:urlencoded, :json, :multipart],
                              json_decoder: Poison
  plug Plug.Logger
  plug :match
  plug :dispatch

  post "/index_text" do
    bucket = conn.body_params["bucket"]
    text = conn.body_params["text"]
    {:ok, _} = Store.write(bucket, text)
    send_resp(conn, 200, "ok")
  end

  get "/query_random" do
    conn = Conn.fetch_query_params conn
    from_bucket = conn.query_params["from_bucket"]
    to_bucket = conn.query_params["to_bucket"]
    resp = Store.query_random(from_bucket, to_bucket)
    send_resp(conn, 200, resp)
  end

  get "/list_buckets" do
    {:ok, resp} = Store.list_buckets()
    send_resp(conn, 200, Poison.encode!(resp))
  end

  match _ do
    send_resp(conn, 404, "method not found")
  end
end
