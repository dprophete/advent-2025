import gleam/int

pub type V3 =
  #(Int, Int, Int)

pub fn pp(v: V3) -> String {
  "("
  <> int.to_string(v.0)
  <> ","
  <> int.to_string(v.1)
  <> ","
  <> int.to_string(v.2)
  <> ")"
}

pub fn dist(v1: V3, v2: V3) -> Float {
  let d0 = v1.0 - v2.0
  let d1 = v1.1 - v2.1
  let d2 = v1.2 - v2.2
  let assert Ok(res) = d0 * d0 + d1 * d1 + d2 * d2 |> int.square_root
  res
}

pub fn add(v1: V3, v2: V3) -> V3 {
  #(v1.0 + v2.0, v1.1 + v2.1, v1.2 + v2.2)
}

pub fn sub(v1: V3, v2: V3) -> V3 {
  #(v1.0 - v2.0, v1.1 - v2.1, v1.2 - v2.2)
}

pub fn scale(v: V3, factor: Int) -> V3 {
  #(v.0 * factor, v.1 * factor, v.2 * factor)
}
