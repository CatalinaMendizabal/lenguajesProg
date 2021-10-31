defmodule Text do
  # def to_json(str) when is_bitstring(str) do
  #   "{" <> str <> "}"
  # end

  # def to_json(x) when is_integer(x) do
  #   "{" <> to_string(x) <> "}"
  # end

  # def to_json(list) when is_list(list) do
  #   "{[" <> (list |> Enum.map(fn e -> to_string(e) end) |> Enum.join(", ")) <> "]}"
  # end

  # def to_json(map) when is_map(map) do
  #   "{" <> (map |> Enum.map(fn {k, v} -> to_string(k) <> " : " <> to_string(v) end) |> Enum.join(", ")) <> "}"
  # end

  def to_json(value) do
    JsonEncoder.to_json(value)
  end
end


defmodule Point do
  defstruct x: 0, y: 0
end
