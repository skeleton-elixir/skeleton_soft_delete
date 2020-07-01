defmodule Skeleton.ConfigTest do
  use Skeleton.App.TestCase
  alias Skeleton.SoftDelete.Config

  test "returns view suffix" do
    assert Config.view_suffix() == "_without_deleted"
  end
end
