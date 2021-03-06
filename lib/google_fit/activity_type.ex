defmodule GoogleFit.ActivityType do
  @moduledoc """
    This module is a namespace for all supported activity types.
  """

  alias GoogleFit.Dataset.ValueFormatError

  alias __MODULE__, as: Self
  @constants %{
    Self.InVehicle => 0,
    Self.Biking => 1,
    Self.OnFoot => 2,
    Self.StillNotMoving => 3,
    Self.UnknownUnableToDetectActivity => 4,
    Self.TiltingSuddenDeviceGravityChange => 5,
    Self.Walking => 7,
    Self.Running => 8,
    Self.Aerobics => 9,
    Self.Badminton => 10,
    Self.Qaseball => 11,
    Self.Basketball => 12,
    Self.Biathlon => 13,
    Self.Handbiking => 14,
    Self.MountainBiking => 15,
    Self.RoadBiking => 16,
    Self.Spinning => 17,
    Self.StationaryBiking => 18,
    Self.UtilityBiking => 19,
    Self.Boxing => 20,
    Self.Calisthenics => 21,
    Self.CircuitTraining => 22,
    Self.Cricket => 23,
    Self.Dancing => 24,
    Self.Elliptical => 25,
    Self.Fencing => 26,
    Self.FootballAmerican => 27,
    Self.FootballAustralian => 28,
    Self.FootballSoccer => 29,
    Self.Frisbee => 30,
    Self.Gardening => 31,
    Self.Golf => 32,
    Self.Gymnastics => 33,
    Self.Handball => 34,
    Self.Hiking => 35,
    Self.Hockey => 36,
    Self.HorsebackRiding => 37,
    Self.Housework => 38,
    Self.JumpingRope => 39,
    Self.Kayaking => 40,
    Self.KettlebellTraining => 41,
    Self.Kickboxing => 42,
    Self.Kitesurfing => 43,
    Self.MartialArts => 44,
    Self.Meditation => 45,
    Self.MixedMartialArts => 46,
    Self.P90xExercises => 47,
    Self.Paragliding => 48,
    Self.Pilates => 49,
    Self.Polo => 50,
    Self.Racquetball => 51,
    Self.RockClimbing => 52,
    Self.Rowing => 53,
    Self.RowingMachine => 54,
    Self.Rugby => 55,
    Self.Jogging => 56,
    Self.RunningOnSand => 57,
    Self.RunningTreadmill => 58,
    Self.Sailing => 59,
    Self.ScubaDiving => 60,
    Self.Skateboarding => 61,
    Self.Skating => 62,
    Self.CrossSkating => 63,
    Self.InlineSkatingRollerblading => 64,
    Self.Skiing => 65,
    Self.BackCountrySkiing => 66,
    Self.CrossCountrySkiing => 67,
    Self.DownhillSkiing => 68,
    Self.KiteSkiing => 69,
    Self.RollerSkiing => 70,
    Self.Sledding => 71,
    Self.Sleeping => 72,
    Self.Snowboarding => 73,
    Self.Snowmobile => 74,
    Self.Snowshoeing => 75,
    Self.Squash => 76,
    Self.StairClimbing => 77,
    Self.StairClimbingMachine => 78,
    Self.StandUpPaddleboarding => 79,
    Self.StrengthTraining => 80,
    Self.Surfing => 81,
    Self.Swimming => 82,
    Self.SwimmingSwimmingPool => 83,
    Self.SwimmingOpenWater => 84,
    Self.TableTennisPingPong => 85,
    Self.TeamSports => 86,
    Self.Tennis => 87,
    Self.TreadmillWalkingOrRunning => 88,
    Self.Volleyball => 89,
    Self.VolleyballBeach => 90,
    Self.VolleyballIndoor => 91,
    Self.Wakeboarding => 92,
    Self.WalkingFitness => 93,
    Self.NordingWalking => 94,
    Self.WalkingTreadmill => 95,
    Self.Waterpolo => 96,
    Self.Weightlifting => 97,
    Self.Wheelchair => 98,
    Self.Windsurfing => 99,
    Self.Yoga => 100,
    Self.Zumba => 101,
    Self.Diving => 102,
    Self.Ergometer => 103,
    Self.IceSkating => 104,
    Self.IndoorSkating => 105,
    Self.Curling => 106,
    Self.OtherUnclassifiedFitnessActivity => 108,
    Self.LightSleep => 109,
    Self.DeepSleep => 110,
    Self.RemSleep => 111,
    Self.AwakeDuringSleepCycle => 112,
  }

  @name_by_id @constants |> Map.new(fn ({name, val}) -> {val, name} end)

  @doc false
  def code(activity_type) when is_atom(activity_type) do
    Map.fetch!(@constants, activity_type)
  end

  @doc false
  def decode([%{"intVal" => code}]) do
    {find(code), Self}
  end

  def decode(unknown) do
    raise ValueFormatError, message: "Unknown activity type format #{inspect unknown}"
  end

  @doc false
  def find(id), do: @name_by_id[id]
end
