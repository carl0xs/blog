defmodule BlogWeb.BookmarksController do
  use BlogWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
