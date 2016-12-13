defmodule Support.TestClient do
  defstruct [:id]
  def get(client, url,[], params: params), do: {:error, {client, url, params}}
end
