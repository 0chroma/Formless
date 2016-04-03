defmodule Formless.Analysis.TextTest do
  use ExUnit.Case, async: true

  alias Formless.Analysis.Text

  test "text intersection" do
    assert Text.intersect("This is a", "is a test") == "This is a test"
    assert Text.intersect("This is a", " test") == "This is a test"
  end
end
