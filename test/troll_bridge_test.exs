defmodule TrollBridgeTest do
  use ExUnit.Case
  doctest TrollBridge

  test "greets the world" do
    assert TrollBridge.hello() == :world
  end
end
