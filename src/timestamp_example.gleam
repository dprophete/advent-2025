import gleam/float
import gleam/io
import gleam/time/timestamp

pub fn main() {
  let ts = timestamp.system_time()
  let seconds = timestamp.to_unix_seconds(ts)
  let milliseconds = seconds *. 1000.0
  io.println("Current timestamp (milliseconds): " <> float.to_string(milliseconds))
}
