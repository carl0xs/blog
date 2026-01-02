defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Post

  def show(conn, %{"slug" => slug}) do
    case Post.find(slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(html: BlogWeb.ErrorHTML, json: BlogWeb.ErrorJSON)
        |> render("404.html")

      post ->
        conn
        |> put_view(html: BlogWeb.PostHTML)
        |> render("show.html", post: post)
    end
  end
end
