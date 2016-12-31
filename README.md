# GoogleFit [![Build Status](https://travis-ci.org/tsubery/google_fit.svg?branch=master)](https://travis-ci.org/tsubery/google_fit)

This Library wraps GoogleFit API. With user's consent it allows to read data about sport activities, weight & nutrition, sleep and more.
You can see usage examples [here](../master/test/regression_test.exs#L71).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `google_fit` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:google_fit, "~> 0.1.0"}]
    end
    ```

  2. Ensure `google_fit` is started before your application:

    ```elixir
    def application do
      [applications: [:google_fit]]
    end
    ```

