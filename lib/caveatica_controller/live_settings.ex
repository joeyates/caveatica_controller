defmodule CaveaticaController.LiveSettings do
  @moduledoc """
  This module handles the live settings for the CaveaticaController application.
  It uses an ETS table to store live settings.

  Initial settings are loaded from the environment variables.
  """

  use GenServer

  require Logger

  @table :caveatica_live_settings

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, nil, {:continue, :initialize}}
  end

  @impl true
  def handle_continue(:initialize, nil) do
    tid = create_ets_table()
    insert_initial_settings(tid)
    {:noreply, %{tid: tid}}
  end

  @impl true
  def handle_call({:get_open_duration}, _from, %{tid: tid} = state) do
    [open_duration: open_duration] = :ets.lookup(tid, :open_duration)
    {:reply, {:ok, open_duration}, state}
  end

  def handle_call({:set_open_duration, new_duration}, _from, %{tid: tid} = state) do
    if is_integer(new_duration) and new_duration >= 0 do
      :ets.insert(tid, {:open_duration, new_duration})
      Logger.info("Open duration set to #{new_duration} seconds.")
      {:reply, :ok, state}
    else
      {:reply, {:error, :invalid_duration}, state}
    end
  end

  def handle_call({:get_close_duration}, _from, %{tid: tid} = state) do
    [close_duration: close_duration] = :ets.lookup(tid, :close_duration)
    {:reply, {:ok, close_duration}, state}
  end

  def handle_call({:set_close_duration, new_duration}, _from, %{tid: tid} = state) do
    if is_integer(new_duration) and new_duration >= 0 do
      :ets.insert(tid, {:close_duration, new_duration})
      Logger.info("Close duration set to #{new_duration} seconds.")
      {:reply, :ok, state}
    else
      {:reply, {:error, :invalid_duration}, state}
    end
  end

  @spec get_open_duration() :: non_neg_integer()
  def get_open_duration() do
    {:ok, open_duration} = GenServer.call(__MODULE__, {:get_open_duration})
    open_duration
  end

  @spec set_open_duration(non_neg_integer()) :: :ok
  def set_open_duration(new_duration) when is_integer(new_duration) and new_duration >= 0 do
    :ok = GenServer.call(__MODULE__, {:set_open_duration, new_duration})
  end

  @spec default_open_duration() :: non_neg_integer()
  def default_open_duration() do
    Application.fetch_env!(:caveatica_controller, :open_duration)
  end

  @spec get_close_duration() :: non_neg_integer()
  def get_close_duration() do
    {:ok, close_duration} = GenServer.call(__MODULE__, {:get_close_duration})
    close_duration
  end

  @spec set_close_duration(non_neg_integer()) :: :ok
  def set_close_duration(new_duration) when is_integer(new_duration) and new_duration >= 0 do
    :ok = GenServer.call(__MODULE__, {:set_close_duration, new_duration})
  end

  @spec default_close_duration() :: non_neg_integer()
  def default_close_duration() do
    Application.fetch_env!(:caveatica_controller, :close_duration)
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
    Logger.info("Creating ETS table #{@table}")
    :ets.new(@table, [:set, :public, :named_table])
  end
end
