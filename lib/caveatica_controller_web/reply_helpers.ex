defmodule CaveaticaControllerWeb.ReplyHelpers do
  @moduledoc """
  Reply to liveview calls by piping the socket through a helper
  """
  def ok(socket), do: {:ok, socket}

  def noreply(socket), do: {:noreply, socket}
end
