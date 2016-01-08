defmodule TLRSS.Download do
  use GenServer

  require Logger

  #######
  # API #
  #######

  def start_link(opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, [], opts)
  end

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
    dl = Task.Supervisor.async(TLRSS.DownloadSupervisor,
      fn -> download_file(item.link) end)
    {{:filename, filename}, {:data, data}} = Task.await(dl)
    write_file(filename, data)
    Logger.info("Downloaded '#{item.name}'.")
    {:noreply, state}
  end
end
