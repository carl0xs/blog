defmodule BlogWeb.BookmarksHTML do
  use BlogWeb, :html
  import Phoenix.Component

  embed_templates "bookmarks_html/*"
end
