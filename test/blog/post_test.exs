defmodule Blog.PostTest do
  use ExUnit.Case, async: false
  alias Blog.Post

  setup do
    tmp_dir = Path.join(System.tmp_dir!(), "blog_posts_test")
    File.mkdir_p!(tmp_dir)
    post_path = Path.join(tmp_dir, "hello-world.md")
    File.write!(post_path, """
    ---
    title: Hello World
    date: 2024-01-01
    tags:
      - elixir
      - phoenix
    ---

    # Hello World

    This is my first blog post.
    """)

    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    %{tmp_dir: tmp_dir}
  end

  test "all/1 returns all posts", %{tmp_dir: tmp_dir} do
    posts = Post.all(tmp_dir) |> Enum.map(& &1.slug)
    assert Enum.member?(posts, "hello-world")
  end

  test "find/2 returns a single post", %{tmp_dir: tmp_dir} do
    post = Post.find("hello-world", tmp_dir)
    assert post.slug == "hello-world"
    assert post.title == "Hello World"
    assert post.date == "2024-01-01"
    assert post.tags == ["elixir", "phoenix"]
  end

  test "find/1 returns nil for non-existent post" do
    assert Post.find("non-existent") == nil
  end
end
