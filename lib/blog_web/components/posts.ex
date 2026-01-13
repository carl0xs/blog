defmodule BlogWeb.Posts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use BlogWeb, :html

  embed_templates "layouts/*"

  attr :any, :any, default: %{}

  def recents(assigns) do
    posts =
      Blog.Post.all()
      |> Enum.sort_by(&(&1.date), :desc)
      |> Enum.take(3)

    assigns = assign(assigns, :posts, posts)

    ~H"""
    <div>
      <ul>
        <%= for post <- @posts do %>
          <li>
            <a href={~p"/posts/#{post.slug}"} class="underline decoration-solid text-info">
              <%= "#{post.date} - #{post.title}"  %>
            </a>
          </li>
        <% end %>
      </ul>
    </div>
    """  
  end
end
