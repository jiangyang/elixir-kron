defmodule KronTest do
  use ExUnit.Case
  require Logger
  import Kron.Parser
  import Kron

  test "match" do
    {:ok, sched} = Kron.Parser.parse("* * * * *")
    assert Kron.match sched, {{1970, 1, 1}, {0, 0, 0}}
    {:ok, sched} = Kron.Parser.parse("2 0-20/10,23 28 11 *")
    assert !Kron.match sched, {{2015, 11, 28}, {0, 0, 0}}
    {:ok, sched} = Kron.Parser.parse("2 0-20/10,23 28 11 *")
    assert Kron.match sched, {{2015, 11, 28}, {23, 2, 55}}
  end

end
