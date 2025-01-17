defmodule Easypodcasts.Helpers.Utils do
  def slugify(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end

  def get_page_range(current_page, total_pages) do
    current_page =
      if is_binary(current_page) do
        String.to_integer(current_page)
      else
        current_page
      end

    cond do
      total_pages < 6 ->
        1..total_pages

      current_page <= 3 ->
        1..6

      current_page > 3 and current_page < total_pages - 3 ->
        (current_page - 2)..(current_page + 2)

      current_page >= total_pages - 6 ->
        (total_pages - 6)..total_pages
    end
  end

  def get_file_size(file) do
    {:ok, %{size: size}} = File.stat(file)
    size
  end

  def get_audio_duration(path) do
    case System.cmd("ffprobe", [
           path,
           "-show_entries",
           "format=duration",
           "-v",
           "quiet",
           "-of",
           "csv=p=0",
           "-user_agent",
           "'Mozilla/5.0 (X11; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0'"
         ]) do
      {duration, 0} -> duration |> String.trim() |> String.to_float() |> trunc
      _ -> 0
    end
  end
end
