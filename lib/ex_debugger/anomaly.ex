defmodule ExDebugger.Anomaly do
  @moduledoc """
  Throws exception to alert user about incorrect usage.
  """

  import Kernel, except: [raise: 2]
  defexception [:message, :error_code]

  @impl true
  def exception({msg, error_code}) do
    struct(__MODULE__, %{
      message: msg,
      error_code: error_code
    })
  end

  @doc false
  def raise(msg, error_code) do
    Kernel.raise(__MODULE__, {msg, error_code})
  end
end
