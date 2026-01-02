defmodule BlogWeb.Posts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use BlogWeb, :html

  alias Blog.Post

  def recents(assigns) do
    posts =
      Post.all()
      |> Enum.sort_by(&Date.from_iso8601!(&1.date), :desc)
      |> Enum.take(3)

    assigns = assign(assigns, :posts, posts)

    ~H"""
    <div>
      <ul>
        <%= for post <- @posts do %>
          <li>
            <a href={~p"/posts/#{post.slug}"} class="underline decoration-solid text-blue">
              <%= post.title %>
            </a>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
