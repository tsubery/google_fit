defmodule Support.TestClient do
  defstruct [:id]
  def get(client, url,[], params: params, recv_timeout: _), do: {:error, {client, url, params}}
end
