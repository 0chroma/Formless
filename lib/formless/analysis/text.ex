defmodule Formless.Analysis.Text do
  def intersect(str1, str2) do
    overlap = Enum.find(tails(str1), "", &String.starts_with?(str2, &1))
    str1 <> String.replace_prefix(str2, overlap, "")
  end

  defp tails(<<_::utf8>>) do
    []
  end
  defp tails(<<_::utf8, tail::binary>>) do
    [tail] ++ tails(tail)
  end
end
