import gleeunit
import gleeunit/should
import utils

pub fn main() {
  gleeunit.main()
}

// Test positive modulo with positive numbers
pub fn pos_mod_positive_numbers_test() {
  7 |> utils.pos_mod(3) |> should.equal(1)
  10 |> utils.pos_mod(5) |> should.equal(0)
  17 |> utils.pos_mod(4) |> should.equal(1)
}

// Test positive modulo with negative numbers - this is the key feature
pub fn pos_mod_negative_numbers_test() {
  -1 |> utils.pos_mod(5) |> should.equal(4)
  -7 |> utils.pos_mod(3) |> should.equal(2)
  -10 |> utils.pos_mod(5) |> should.equal(0)
  -11 |> utils.pos_mod(5) |> should.equal(4)
}

// Test edge cases
pub fn pos_mod_edge_cases_test() {
  0 |> utils.pos_mod(5) |> should.equal(0)
  5 |> utils.pos_mod(5) |> should.equal(0)
  -5 |> utils.pos_mod(5) |> should.equal(0)
}

// Test with larger modulo values
pub fn pos_mod_larger_modulo_test() {
  -1 |> utils.pos_mod(10) |> should.equal(9)
  -15 |> utils.pos_mod(10) |> should.equal(5)
  25 |> utils.pos_mod(10) |> should.equal(5)
}
