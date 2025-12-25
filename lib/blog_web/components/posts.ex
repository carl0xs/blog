defmodule BlogWeb.Posts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use BlogWeb, :html

  def recents(assigns) do
    posts =
      "priv/posts"
      |> File.ls!()
      |> Enum.map(&Path.join("priv/posts", &1))
      |> Enum.map(fn path -> {path, File.stat!(path)} end)
      |> Enum.sort_by(fn {_, stat} -> stat.mtime end, :desc)
      |> Enum.take(3)

    assigns = assign(assigns, :posts, posts)

    ~H"""
    <div class="mt-4">
      <ul>
        <%= for {path, _} <- @posts do %>
          <li>
            <a href={"/posts/#{Path.basename(path, ".md")}"} class="underline decoration-solid text-blue">
              <%= Path.basename(path, ".md") |> String.replace("-", " ") |> String.capitalize() %>
            </a>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
