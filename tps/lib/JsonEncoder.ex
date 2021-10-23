defprotocol JsonEncoder do
  @doc "Encodes given value to JSON"
  @fallback_to_any true
  def to_json(value)
end

defimpl JsonEncoder, for: Integer do
  def to_json(x) do
    "{" <> to_string(x) <> "}"
  end
end

defimpl JsonEncoder, for: BitString do
  def to_json(str) do
    "{" <> str <> "}"
  end
end

defimpl JsonEncoder, for: List do
  def to_json(list) do
    "{[" <> (list |> Enum.map(fn e -> to_string(e) end) |> Enum.join(", ")) <> "]}"
  end
end

defimpl JsonEncoder, for: Map do
  def to_json(map) do
    "{" <> (map |> Enum.map(fn {k, v} -> to_string(k) <> " : " <> to_string(v) end) |> Enum.join(", ")) <> "}"
  end
end

defimpl JsonEncoder, for: Point do
  def to_json(p) do
    "{x : " <> to_string(p.x) <> ", y : " <> to_string(p.y) <> "}"
  end
end

defimpl JsonEncoder, for: Any do
  def to_json(_value) do
    "{object not parsable}"
  end
end
