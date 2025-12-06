import gleam/float
import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/string
import gleam/time/duration
import gleam/time/timestamp
import simplifile

pub fn arr_to_pair(arr: List(a)) -> #(a, a) {
  let assert [a, b] = arr
  #(a, b)
}

pub fn list_sum(lst: List(Int)) -> Int {
  list.fold(lst, 0, fn(acc, nb) { acc + nb })
}

pub fn nb_digits(nb: Int) -> Int {
  case nb {
    0 -> 1
    _ -> {
      let abs_nb = if_then_else(nb < 0, -nb, nb)
      abs_nb
      |> int_log
      |> float.to_precision(10)
      |> float.floor
      |> float.round
      |> int.add(1)
    }
  }
}

pub fn int_pow(base: Int, exp: Int) -> Int {
  let assert Ok(res) = int.power(base, int.to_float(exp))
  float.round(res)
}

pub fn float_pow(base: Float, exp: Float) -> Float {
  let assert Ok(res) = float.power(base, exp)
  res
}

pub fn int_ln(nb: Int) -> Float {
  nb |> int.to_float |> float_ln
}

pub fn int_log(nb: Int) -> Float {
  nb |> int.to_float |> float_log
}

pub fn float_ln(nb: Float) -> Float {
  let assert Ok(res) = nb |> float.logarithm
  res
}

pub fn float_log(nb: Float) -> Float {
  float_ln(nb) /. float_ln(10.0)
}

pub fn pp_day(txt: String) {
  printf("\n#### ~s\n", txt)
}

// modulo but make sure the result is always positive
pub fn pos_mod(nb: Int, mod: Int) -> Int {
  { { nb % mod } + mod } % mod
}

pub fn if_then_else(cond: Bool, if_true: a, if_false: a) -> a {
  case cond {
    True -> if_true
    False -> if_false
  }
}

pub fn fmt_duration(dur: duration.Duration) -> String {
  let secs_float = duration.to_seconds(dur)
  let with_2 = float.to_precision(secs_float, 2)
  float.to_string(with_2) <> "s"
}

pub fn run_it(fn_to_run: fn(String) -> a, file: String) -> a {
  let assert Ok(content) = simplifile.read(file)
  fn_to_run(content |> string.trim_end())
}

pub fn time_it(fn_to_run: fn(String) -> a, p: String, file: String) -> a {
  let start = timestamp.system_time()
  let res = run_it(fn_to_run, file)
  let end = timestamp.system_time()
  let dur = timestamp.difference(start, end)
  printf("[~s] ~s : ~s -> ~p\n", #(fmt_duration(dur), p, file, res))
  res
}
