defmodule CaveaticaController.Scheduler do
  use Quantum, otp_app: :caveatica_controller

  alias CaveaticaController.Times

  require Logger

  def reset() do
    Logger.info("Resetting Open/Close times")
    Logger.info("Before:")
    list_jobs()
    next_close = Times.next_close!()
    next_open = Times.next_open!()
    Logger.info("next_close: #{inspect(next_close)}")
    Logger.info("next_open: #{inspect(next_open)}")
  end

  defp list_jobs() do
    jobs = jobs()
    Logger.info("Current Jobs: #{inspect(jobs)}")
  end
end
