defmodule TLRSS.Download do
  def download_file(url) when is_binary(url) do
    filename = List.last String.split(url, "/")
    {:ok, resp} = :httpc.request(:get,
                                 {String.to_char_list(url), []},
                                 [],
                                 [body_format: :binary])
    {{_, 200, 'OK'}, _headers, body} = resp
    {{:filename, filename}, {:data, body}}
  end

  def write_file(filename, data) do
    download_dir = Application.get_env :tlrss, :download_dir
    full_path = download_dir <> filename

    File.write! full_path, data
  end

  def start_download(url) do
    dl = Task.Supervisor.async(TLRSS.DownloadSupervisor, fn -> download_file(url) end)
    {{:filename, filename}, {:data, data}} = Task.await(dl)
    write_file(filename, data)
  end
end
