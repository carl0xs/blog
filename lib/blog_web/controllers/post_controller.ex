defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  def show(conn, %{"slug" => slug}) do
    case read_post(slug) do
      {:ok, body} ->
        conn
        |> put_view(html: BlogWeb.PostHTML)
        |> render("show.html", post_html: Earmark.as_html!(body))

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> put_view(html: BlogWeb.ErrorHTML, json: BlogWeb.ErrorJSON)
        |> render("404.html")
    end
  end

  defp read_post(slug) do
    file_path = Path.join(["priv", "posts", slug <> ".md"])

    if File.exists?(file_path) do
      {:ok, File.read!(file_path)}
    else
      {:error, :not_found}
    end
  end
end
