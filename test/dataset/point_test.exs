defmodule GoogleFitTest.Dataset.Point do
  alias GoogleFit.Dataset.Point
  use ExUnit.Case

  test "decode_value for unknown data type" do
    {value, unit} = Point.decode_value("something_new", :test_target)
    assert unit == :unknown
    assert value == :test_target
  end

  test "decode_value com.google.calories.expended" do
    {value, unit} = Point.decode_value("calories.expended", [%{"fpVal" => 2236.033203125, "mapVal" => []}])
    assert unit == :kCal
    assert value == 2236.033203125
  end

  test "decode_value com.google.step_count.delta" do
    {value, unit} = Point.decode_value("step_count.delta", [%{"intVal" => 184, "mapVal" => []}])
    assert unit == :steps
    assert value == 184
  end

  test "decode com.google.calories.expended" do
    {value, unit} = Point.decode_value("calories.expended", [%{"intVal" => 54_321}])
    assert value == 54_321
    assert unit == :kCal

    {value, unit} = Point.decode_value("calories.expended", [%{"fpVal" => 12_345}])
    assert value == 12_345
    assert unit == :kCal
  end
  test "decode com.google.distance.delta" do
    {value, unit} = Point.decode_value("calories.bmr", [%{"intVal" => 54_321}])
    assert value == 54_321

    assert unit == :"kCal/day"
    {value, unit} = Point.decode_value("calories.bmr", [%{"fpVal" => 12_345}])
    assert value == 12_345
    assert unit == :"kCal/day"
  end
  test "decode com.google.calories.bmr" do
    {value, unit} = Point.decode_value("calories.bmr", [%{"intVal" => 54_321}])
    assert value == 54_321
    assert unit == :"kCal/day"

    {value, unit} = Point.decode_value("calories.bmr", [%{"fpVal" => 12_345}])
    assert value == 12_345
    assert unit == :"kCal/day"
  end
  test "decode com.google.hydration" do
    {value, unit} = Point.decode_value("hydration", [%{"intVal" => 54_321}])
    assert value == 54_321
    assert unit == :liters

    {value, unit} = Point.decode_value("hydration", [%{"fpVal" => 12_345}])
    assert value == 12_345
    assert unit == :liters
  end
  test "decode com.google.weight" do
    {value, unit} = Point.decode_value("weight", [%{"intVal" => 54_321}])
    assert value == 54_321
    assert unit == :kg

    {value, unit} = Point.decode_value("weight", [%{"fpVal" => 12_345}])
    assert value == 12_345
    assert unit == :kg
  end
  test "decode com.google.speed" do
    {value, unit} = Point.decode_value("speed", [%{"intVal" => 54_321}])
    assert value == 54_321
    assert unit == :"meters/second"

    {value, unit} = Point.decode_value("speed", [%{"fpVal" => 12_345}])
    assert value == 12_345
    assert unit == :"meters/second"
  end

  test "decode_value com.google.activity.summary" do
    {value, unit} = Point.decode_value("activity.summary", [%{"intVal" => 3, "mapVal" => []}, %{"intVal" => 61_751_051, "mapVal" => []}, %{"intVal" => 24, "mapVal" => []}])
    assert unit == GoogleFit.Dataset.ActivitySummary
    assert value == %GoogleFit.Dataset.ActivitySummary{activity: GoogleFit.ActivityType.StillNotMoving, duration_millis: 61_751_051, num_segments: 24}
  end

  test "decode_value com.google.nutrition.summary" do
    {value, unit} = Point.decode_value("nutrition.summary", [%{"mapVal" => [%{"key" => "fat.monounsaturated", "value" => %{"fpVal" => 23.18144416809082}}, %{"key" => "fat.total", "value" => %{"fpVal" => 61.40793991088867}}, %{"key" => "sodium", "value" => %{"fpVal" => 1.80509614944458}}, %{"key" => "potassium", "value" => %{"fpVal" => 0.3783780038356781}}, %{"key" => "fat.saturated", "value" => %{"fpVal" => 14.052756309509277}}, %{"key" => "protein", "value" => %{"fpVal" => 99.0836181640625}}, %{"key" => "carbs.total", "value" => %{"fpVal" => 166.26512145996094}}, %{"key" => "cholesterol", "value" => %{"fpVal" => 1.1763180494308472}}, %{"key" => "calories", "value" => %{"fpVal" => 1624.3040771484375}}, %{"key" => "sugar", "value" => %{"fpVal" => 26.13641929626465}}, %{"key" => "dietary_fiber", "value" => %{"fpVal" => 9.0}}]}, %{"intVal" => 0, "mapVal" => []}])
    assert unit == GoogleFit.Dataset.Nutrition
    assert value == %GoogleFit.Dataset.Nutrition{:fat_monounsaturated => 23.18144416809082, :fat_total => 61.40793991088867, :sodium => 1.80509614944458, :potassium => 0.3783780038356781, :fat_saturated => 14.052756309509277, :protein => 99.0836181640625, :carbs_total => 166.26512145996094, :cholesterol => 1.1763180494308472, :calories => 1624.3040771484375, :sugar => 26.13641929626465, :dietary_fiber => 9.0, meal_type: Unknown}
  end

  test "decode_value com.google.nutrition" do
    {value, unit} = Point.decode_value("nutrition", [%{"mapVal" => [%{"key" => "potassium", "value" => %{"fpVal" => 0.49000000953674316}}, %{"key" => "fat.total", "value" => %{"fpVal" => 2.0}}, %{"key" => "sodium", "value" => %{"fpVal" => 0.1599999964237213}}, %{"key" => "dietary_fiber", "value" => %{"fpVal" => 3.0}}, %{"key" => "protein", "value" => %{"fpVal" => 51.0}}, %{"key" => "calories", "value" => %{"fpVal" => 240.0}}, %{"key" => "sugar", "value" => %{"fpVal" => 2.0}}, %{"key" => "carbs.total", "value" => %{"fpVal" => 7.0}}, %{"key" => "fat.saturated", "value" => %{"fpVal" => 1.0}}]}, %{"intVal" => 3, "mapVal" => []}, %{"mapVal" => [], "stringVal" => "Rtd 51 frosty chocolate protein ready-to-drink shake by met-rx"}])
    assert unit == GoogleFit.Dataset.Nutrition
    assert value == %GoogleFit.Dataset.Nutrition{calcium: nil, calories: 240.0, carbs_total: 7.0, cholesterol: nil, dietary_fiber: 3.0, fat_monounsaturated: nil, fat_polyunsaturated: nil, fat_saturated: 1.0, fat_total: 2.0, fat_trans: nil, fat_unsaturated: nil, food_item: "Rtd 51 frosty chocolate protein ready-to-drink shake by met-rx", meal_type: Dinner, potassium: 0.49000000953674316, protein: 51.0, sodium: 0.1599999964237213, sugar: 2.0, vitamin_a: nil, vitamin_c: nil}
  end

  test "decode_value com.google.weight.summary" do
    {value, unit} = Point.decode_value("weight.summary", [%{"fpVal" => 66.65887451171875, "mapVal" => []}, %{"fpVal" => 68.5831069946289, "mapVal" => []}, %{"fpVal" => 66.40586853027344, "mapVal" => []}])
    assert unit == GoogleFit.Dataset.NumberSummary
    assert value == %GoogleFit.Dataset.NumberSummary{average: 66.65887451171875, maximum: 68.5831069946289, minimum: 66.40586853027344}
  end

  test "unsupported formats" do
    wrong_format = [%{"sum" => "ting wong"}]
    Point.decoder_names |> Enum.each(fn(data_type_name)->
      {value, unit} = Point.decode_value(data_type_name, wrong_format)
      assert unit == :unknown
      assert value == wrong_format
    end)
  end
end
