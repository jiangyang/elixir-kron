defmodule Kron.Parser do
  @doc """
  """
  require Logger

  @minute_min 0
  @minute_max 59
  @hour_min 0
  @hour_max 23
  @day_min 1
  @day_max 31
  @month_min 1
  @month_max 12
  @dow_min 0
  @dow_max 6

  def parse(str) do
    try do
      [minute, hour, day, month, day_of_week] = String.split(str, ~r{\s+}, trim: true)
      minute = parse_field(minute, @minute_min, @minute_max)
      hour = parse_field(hour, @hour_min, @hour_max)
      day = parse_field(day, @day_min, @day_max)
      month = parse_field(month, @month_min, @month_max)
      day_of_week = parse_field(day_of_week, @dow_min, @dow_max)

      {:ok, %Kron{
        minute: minute,
        hour: hour,
        day: day,
        month: month,
        day_of_week: day_of_week
      }}
    rescue
      _m in MatchError ->
        {:error, "invalid cron: " <> str}
      exception ->
        {:error, Exception.message(exception)}
    end
  end

  defp parse_field(fld_str, min, max) do
    try do
      parse_field_val(fld_str, min, max)
    rescue
      _ in ArgumentError ->
        raise "invalid cron field: " <> fld_str
      exception ->
        raise exception
    end
  end

  defp parse_field_val("*", _, _) do
    :any
  end
  defp parse_field_val(x, min, max) do
    subs = String.split(x, ",", trim: true)
    vals = subs  |> Enum.map(
      fn p ->
        if String.contains?(p, "/") do
          [range, i] = String.split(p, "/", trim: true)
          i = parse_single_val i, min ,max
          range = parse_range_or_val range, min, max
          calc_interval range, i
        else
          parse_range_or_val p, min, max
        end
      end
    )
    vals = vals 
    |> Enum.flat_map(fn v-> v end)
    |> Enum.uniq()
    |> Enum.sort()
    # collapse contiguous list to a range if possible, worth it?
    case Enum.reduce(vals, {true, nil}, fn v, acc ->
      prev = v - 1
      case acc do
        {false, _} ->
          {false, nil}
        {true, nil} ->
          {true, v}
        {true, ^prev} ->
          {true, v}
        _ ->
          {false, nil}
      end
    end) do
      {true, last} ->
        hd(vals)..last
      {false, _} ->
        vals
    end
  end

  defp calc_interval(h..t, i) do
    h..t |> Enum.filter(&(rem(&1 - h, i) == 0))
  end
  defp calc_interval([h|t], i) do
    [h|t] |> Enum.filter(&(rem(&1 - h, i) == 0))
  end

  defp parse_range_or_val(str, min, max) do
    if String.contains?(str, "-") do
      case String.split(str, "-", trim: true) do
        [l, h] ->
          parse_range([l, h], min, max)
        _ ->
          raise "invalid expr #{str}"
      end
    else
      case str do
        "*" ->
          min..max
        _ ->
          [parse_single_val(str, min, max)]
      end
    end
  end

  defp parse_single_val(x, min, max) do
    t = String.to_integer x
    check_range!(t, min, max)
    t
  end

  defp parse_range([l, h], min, max) do
    l = String.to_integer l
    check_range!(l, min, max)
    h = String.to_integer h
    check_range!(h, min, max)
    cond do
      l < h ->
        l..h
      l == h ->
        [l]
      l > h ->
        Enum.to_list(l..max) ++ Enum.to_list(min..h)
    end
  end

  defp check_range!(v, min, max) do
    if v < min or v > max do
      raise "out of range, expecting(#{min}-#{max})"
    end
  end
end