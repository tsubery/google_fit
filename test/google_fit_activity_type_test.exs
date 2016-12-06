defmodule GoogleFitTest.ActivityType do
  alias GoogleFit.ActivityType
  use ExUnit.Case
  doctest ActivityType

  test "yoga type" do
    assert ActivityType.Yoga.code == 100
    assert ActivityType.find(100) == ActivityType.Yoga
  end

  test "biking type" do
    assert ActivityType.Biking.code == 1
    assert ActivityType.find(1) == ActivityType.Biking
  end

  test "sleeping type" do
    assert ActivityType.Sleeping.code == 72
    assert ActivityType.find(72) == ActivityType.Sleeping
  end
end
