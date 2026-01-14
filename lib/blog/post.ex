defmodule Blog.Post do
  @derive {Jason.Encoder, only: [:slug, :title, :tags, :html]}
  defstruct [:slug, :title, :date, :tags, :html]

  def all do
    Path.wildcard(Path.join("priv/posts", "*.md"))
    |> Enum.flat_map(fn path ->
      case parse(path) do
        nil -> []
        post -> [post]
      end
    end)
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

        case Regex.run(~r/^---\s*\n(.*?)\n---\s*\n(.*)/s, content, capture: :all_but_first) do
          [front_matter, markdown] ->
            meta = :yamerl_constr.string(front_matter) |> hd |> Enum.into(%{})

            {:ok, html, _warnings} = Earmark.as_html(markdown)

            %Blog.Post{
              slug: slug,
              title: meta[~c"title"],
              date: parse_date(meta[~c"date"]),
              tags: meta[~c"tags"] || [],
              html: html
            }

          _ ->
            nil
        end

      {:error, :enoent} ->
        nil
    end
  end

  defp parse_date(value) when is_binary(value) do
    Date.from_iso8601!(value)
  end

  defp parse_date(value) when is_list(value) do
    value
    |> to_string()
    |> Date.from_iso8601!()
  end

  defp parse_date(_), do: nil
end
