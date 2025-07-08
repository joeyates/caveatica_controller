defmodule CaveaticaController.LiveSettings do
  @moduledoc """
  This module handles the live settings for the CaveaticaController application.
  It uses an ETS table to store live settings.

  Initial settings are loaded from the environment variables.
  """

  require Logger

  @table :caveatica_live_settings

  @spec get_open_duration() :: non_neg_integer()
  def get_open_duration() do
    tid = ets_table_tid()
    [open_duration: open_duration] = :ets.lookup(tid, :open_duration)
    open_duration
  end

  @spec set_open_duration(non_neg_integer()) :: :ok
  def set_open_duration(new_duration) when is_integer(new_duration) and new_duration >= 0 do
    tid = ets_table_tid()
    :ets.insert(tid, {:open_duration, new_duration})
    Logger.info("Open duration set to #{new_duration} seconds.")
  end

  @spec default_open_duration() :: non_neg_integer()
  def default_open_duration() do
    Application.fetch_env!(:caveatica_controller, :open_duration)
  end

  @spec get_close_duration() :: non_neg_integer()
  def get_close_duration() do
    tid = ets_table_tid()
    [close_duration: close_duration] = :ets.lookup(tid, :close_duration)
    close_duration
  end

  @spec set_close_duration(non_neg_integer()) :: :ok
  def set_close_duration(new_duration) when is_integer(new_duration) and new_duration >= 0 do
    tid = ets_table_tid()
    :ets.insert(tid, {:close_duration, new_duration})
    Logger.info("Close duration set to #{new_duration} seconds.")
  end

  @spec default_close_duration() :: non_neg_integer()
  def default_close_duration() do
    Application.fetch_env!(:caveatica_controller, :close_duration)
  end

  @spec ets_table_tid() :: term()
  defp ets_table_tid() do
    case :ets.whereis(@table) do
      :undefined ->
        prepare_ets_table()

      tid ->
        tid
    end
  end

  defp prepare_ets_table() do
    tid = create_ets_table()
    insert_initial_settings(tid)
    tid
  end

  defp insert_initial_settings(tid) do
    open_duration = default_open_duration()
    close_duration = default_close_duration()

    :ets.insert(tid, [{:open_duration, open_duration}, {:close_duration, close_duration}])

    Logger.info(
      "Initial settings loaded: open_duration=#{open_duration}, close_duration=#{close_duration}"
    )
  end

  defp create_ets_table() do
    Logger.info("ETS table #{@table} not found, creating it.")
    :ets.new(@table, [:set, :public, :named_table])
  end
end
