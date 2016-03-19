defmodule TLRSS.Download do
  @moduledoc"""
  Module responsible for downloading the files in the feed.
  """
  use GenServer

  require Logger

  #######
  # API #
  #######

  @doc"""
  Starts the Download server. Takes no arguments, as there
  is no state to keep.
  """
  def start_link(opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @spec download(String.t, pid) :: :ok
  @doc"""
  Requests the start of a download, referred to only by URL.
  Internally, the server will spawn a Task in which the server
  downloads the file.

  Currently does *not* save failed downloads.
  """
  def download(url, pid \\ __MODULE__) do
    GenServer.cast(pid, {:download, url})
  end

  ############
  # Internal #
  ############

  defp download_file(url) when is_binary(url) do
    filename = List.last String.split(url, "/")
    {:ok, resp} = :httpc.request(:get,
                                 {String.to_char_list(url), []},
                                 [],
                                 [body_format: :binary])
    {{_, 200, 'OK'}, _headers, body} = resp
    {{:filename, filename}, {:data, body}}
  end

  defp write_file(filename, data) do
    download_dir = Application.get_env :tlrss, :download_dir
    full_path = download_dir <> filename

    File.write! full_path, data
  end

  def handle_cast({:download, item}, state) do
    dl = Task.Supervisor.async(TLRSS.TaskSupervisor,
      fn -> download_file(item.link) end)
    {{:filename, filename}, {:data, data}} = Task.await(dl)
    write_file(filename, data)
    Logger.info("Downloaded '#{item.name}'.")
    {:noreply, state}
  end
end
