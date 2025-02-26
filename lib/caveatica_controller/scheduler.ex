defmodule CaveaticaController.Scheduler do
  use Quantum, otp_app: :caveatica_controller

  alias CaveaticaController.Times

  require Logger

  def init(opts) do
    jobs = opts[:jobs] || []
    jobs = jobs ++ [open_job(), close_job()]
    Keyword.put(opts, :jobs, jobs)
  end

  def reset() do
    Logger.info("Resetting Open/Close times")
    Logger.info("Before:")
    list_jobs()
    delete_existing()
    add_job(open_job())
    add_job(close_job())
    Logger.info("After:")
    list_jobs()
  end

  defp delete_existing() do
    delete_job(:open)
    delete_job(:close)
  end

  defp open_job() do
    next_open = Times.next_open!()

    schedule = %Crontab.CronExpression{
      hour: [next_open.hour],
      minute: [next_open.minute]
    }

    new_job()
    |> Quantum.Job.set_name(:open)
    |> Quantum.Job.set_schedule(schedule)
    |> Quantum.Job.set_task(fn ->
      Logger.info("Opening via cron job")

      CaveaticaControllerWeb.Endpoint.broadcast!("control", "open", %{
        "duration" => open_duration()
      })
    end)
  end

  defp close_job() do
    next_close = Times.next_close!()

    schedule = %Crontab.CronExpression{
      hour: [next_close.hour],
      minute: [next_close.minute]
    }

    new_job()
    |> Quantum.Job.set_name(:close)
    |> Quantum.Job.set_schedule(schedule)
    |> Quantum.Job.set_task(fn ->
      Logger.info("Closing via cron job")

      CaveaticaControllerWeb.Endpoint.broadcast!("control", "close", %{
        "duration" => close_duration()
      })
    end)
  end

  defp list_jobs() do
    jobs = jobs()
    Logger.info("Current Jobs: #{inspect(jobs)}")
  end

  defp open_duration() do
    Application.fetch_env!(:caveatica_controller, :open_duration)
  end

  defp close_duration() do
    Application.fetch_env!(:caveatica_controller, :close_duration)
  end
end
