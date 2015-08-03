defmodule Kron.ParserTest do
  require Logger
  use ExUnit.Case
  import Kron.Parser

  test "parse good" do
    assert {:ok, %Kron{
        minute: 1..5,
        hour: :any,
        day: [1,6,11,16,21,26,31],
        month: 10..11,
        day_of_week: [1,3]
      }} = parse("1-2/1,2,4-5,3-4 *  */5 10,11 1-4/2")
    assert {:ok, %Kron{
        minute: [0,5,9,10,15,20,21,23,25,30,35,40,45,50,55],
        hour: 0..12,
        day: 1..31,
        month: 2..3,
        day_of_week: 1..6
      }} = parse("*/5,23,21,9 0-10,11-12 1-31 2-3 1-6/1")
      assert {:ok, %Kron{
        minute: [0,1,2,3,4,5,55,56,57,58,59],
        hour: [0,1,2,3,4,5,23],
        day: [2,7,27],
        month: [1,2,3,4,7,11,12],
        day_of_week: :any
      }} = parse("55-5 23-3,4-5 27-10/5 */6,11-4 *")
  end

  test "parse bad" do
    assert {:error, msg} = parse("* foo   bar   * ")
    Logger.error msg
    assert {:error, msg} = parse("?  * * * *")
    Logger.error msg
    assert {:error, msg} = parse("66  * * * *")
    Logger.error msg
    assert {:error, msg} = parse("0-66  * * * *")
    Logger.error msg
    assert {:error, msg} = parse("0-66/1  * * * *")
    Logger.error msg
    assert {:error, msg} = parse("0-25/x  * * * *")
    Logger.error msg
    assert {:error, msg} = parse("-1/5  * * * *")
    Logger.error msg
  end
  
end