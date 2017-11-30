defmodule IRCTest do
  use ExUnit.Case
  doctest IRC

  test "greets the world" do
    assert IRC.hello() == :world
  end
end
