defmodule BlogWeb.PostHTML do
  use BlogWeb, :html
  import Phoenix.Component

  embed_templates "post_html/*"
end
