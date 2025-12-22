defmodule BlogWeb.Posts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use BlogWeb, :html

  def recents(assigns) do 
    ~H"""
      <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      </div>
    """
  end
end
