defmodule CaveaticaController.Scheduler do
  use Quantum, otp_app: :caveatica_controller

  alias CaveaticaController.Times

  require Logger

  def reset() do
    Logger.info("Resetting Open/Close times")
    Logger.info("Before:")
    list_jobs()
    delete_existing()
    create_open()
    create_close()
    Logger.info("After:")
    list_jobs()
  end

  defp delete_existing() do
    delete_job(:open)
    delete_job(:close)
  end

  defp create_open() do
    next_open = Times.next_open!()

    schedule = %Crontab.CronExpression{
      hour: [next_open.hour],
      minute: [next_open.minute]
    }

    new_job()
    |> Quantum.Job.set_name(:open)
    |> Quantum.Job.set_schedule(schedule)
    |> Quantum.Job.set_task(fn -> Logger.info("Open!!") end)
    |> add_job()
  end

  defp create_close() do
    next_close = Times.next_close!()

    schedule = %Crontab.CronExpression{
      hour: [next_close.hour],
      minute: [next_close.minute]
    }

    new_job()
    |> Quantum.Job.set_name(:close)
    |> Quantum.Job.set_schedule(schedule)
    |> Quantum.Job.set_task(fn -> Logger.info("Close!!") end)
    |> add_job()
  end

  defp list_jobs() do
    jobs = jobs()
    Logger.info("Current Jobs: #{inspect(jobs)}")
  end
end
