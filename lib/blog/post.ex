defmodule Blog.Post do
  @derive {Jason.Encoder, only: [:slug, :title, :tags, :html]}
  defstruct [:slug, :title, :date, :tags, :html]

  def all, do: all("priv/posts")

  def all(posts_path) do
    Path.wildcard(Path.join(posts_path, "*.md"))
    |> Enum.map(&parse/1)
    |> Enum.reject(&is_nil/1)
  end

  def find(slug), do: find(slug, "priv/posts")

  def find(slug, posts_path) do
    Path.join(posts_path, "#{slug}.md")
    |> parse()
  end

  defp parse(path) do
    case File.read(path) do
      {:ok, content} ->
        slug = Path.basename(path, ".md")

        parts = Regex.run(~r/^---\s*\n(.*?)\n---\s*\n(.*)/s, content, capture: :all_but_first)

        if length(parts) == 2 do
          [front_matter, markdown] = parts
          meta = :yamerl_constr.string(front_matter) |> hd |> Enum.into(%{})

          {:ok, html, _warnings} = Earmark.as_html(markdown)

          date =
            with date_str when is_binary(date_str) <- meta["date"],
                 {:ok, date} <- Date.from_iso8601(date_str) do
              date
            else
              _ -> nil
            end

          %Blog.Post{
            slug: slug,
            title: meta["title"],
            date: date,
            tags: meta["tags"] || [],
            html: html
          }
        else
          nil
        end

      {:error, :enoent} ->
        nil
    end
  end
end
