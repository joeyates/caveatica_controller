defmodule CaveaticaController.Scheduler do
  use Quantum, otp_app: :caveatica_controller

  alias CaveaticaController.Cldr.DateTime.Relative
  alias CaveaticaController.LiveSettings
  alias CaveaticaController.Times
  alias Crontab.Scheduler

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
    add_job(reset_after_open_job())
    add_job(close_job())
    add_job(reset_after_close_job())
    Logger.info("After:")
    list_jobs()
  end

  def next_open() do
    jobs = jobs()
    next_open = jobs[:open].schedule

    with {:ok, naive} <- Scheduler.get_next_run_date(next_open, NaiveDateTime.utc_now()),
         {:ok, local} <- DateTime.from_naive(naive, timezone()) do
      relative = Relative.to_string!(local, format: :default)
      "#{relative} (at #{DateTime.to_string(local)})"
    else
      _ -> "No next open time found"
    end
  end

  def next_close() do
    jobs = jobs()
    next_close = jobs[:close].schedule

    with {:ok, datetime} <- Scheduler.get_next_run_date(next_close, NaiveDateTime.utc_now()),
         {:ok, local} <- DateTime.from_naive(datetime, timezone()) do
      relative = Relative.to_string!(local, format: :default)
      "#{relative} (at #{DateTime.to_string(local)})"
    else
      _ -> "No next close time found"
    end
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

      open_duration = LiveSettings.get_open_duration()

      CaveaticaControllerWeb.Endpoint.broadcast!("control", "open", %{
        "duration" => open_duration
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

      close_duration = LiveSettings.get_close_duration()

      CaveaticaControllerWeb.Endpoint.broadcast!("control", "close", %{
        "duration" => close_duration
      })
    end)
  end

  defp reset_after_open_job() do
    next_open = Times.next_open!()
    after_next_open = DateTime.add(next_open, 1, :minute)

    schedule = %Crontab.CronExpression{
      hour: [after_next_open.hour],
      minute: [after_next_open.minute]
    }

    new_job()
    |> Quantum.Job.set_name(:reset_after_open)
    |> Quantum.Job.set_schedule(schedule)
    |> Quantum.Job.set_task(fn ->
      Logger.info("Resetting after open via cron job")

      CaveaticaController.Scheduler.reset()
    end)
  end

  defp reset_after_close_job() do
    next_close = Times.next_close!()
    after_next_close = DateTime.add(next_close, 1, :minute)

    schedule = %Crontab.CronExpression{
      hour: [after_next_close.hour],
      minute: [after_next_close.minute]
    }

    new_job()
    |> Quantum.Job.set_name(:reset_after_close)
    |> Quantum.Job.set_schedule(schedule)
    |> Quantum.Job.set_task(fn ->
      Logger.info("Resetting after close via cron job")

      CaveaticaController.Scheduler.reset()
    end)
  end

  defp list_jobs() do
    jobs = jobs()
    Logger.info("Current Jobs: #{inspect(jobs)}")
  end

  defp timezone() do
    Application.fetch_env!(:caveatica_controller, :timezone)
  end
end
