defmodule Formless.Store do
  alias Formless.Store.Analysis
  alias Formless.Store.Quads

  def write(bucket, text) do
    text
    |> Analysis.ngrams()
    |> Enum.each(&Quads.write(bucket, &1))
  end

end
