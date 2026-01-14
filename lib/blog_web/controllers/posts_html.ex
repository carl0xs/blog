defmodule BlogWeb.PostsHTML do
  use BlogWeb, :html
  import Phoenix.Component

  embed_templates "posts_html/*"
end
