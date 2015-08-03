defmodule Kron do
  defstruct minute: nil, hour: nil, day: nil, month: nil, day_of_week: nil

  def match_now(sched) do
    match sched, :calendar.local_time()
  end

  def match(%Kron{minute: minute, 
    hour: hour, 
    day: day, 
    month: month, 
    day_of_week: dow}, 
    {{y, mon, d}, {h, m, s}}) do
    [{minute, m}, 
    {hour, h}, 
    {day, d}, 
    {month, mon},
    {dow, :calendar.day_of_the_week(y, mon, d) - 1}]
    |> Enum.reduce true, fn {f, v}, acc -> 
      if not acc do
        acc
      else
        match_field f, v 
      end
    end
  end

  defp match_field(:any, _), do: true
  defp match_field(l..h, v) do
    v in l..h
  end
  defp match_field([h|t], v) do
    v in [h|t]
  end

end
