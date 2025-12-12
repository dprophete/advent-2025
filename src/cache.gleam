import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom.{type Atom}
import gleam/option.{type Option, None, Some}

pub opaque type TableRef {
  TableRef(Dynamic)
}

@external(erlang, "ets", "info")
fn ets_info(table: Atom) -> Dynamic

@external(erlang, "ets", "delete")
fn ets_delete(table: Atom) -> Bool

@external(erlang, "ets", "new")
fn ets_new(name: Atom, options: List(Atom)) -> Dynamic

@external(erlang, "ets", "insert")
fn ets_insert(table: Atom, object: Dynamic) -> Bool

@external(erlang, "ets", "lookup")
fn ets_lookup(table: Atom, key: Dynamic) -> List(Dynamic)

@external(erlang, "gleam_stdlib", "identity")
fn to_dynamic(a: anything) -> Dynamic

@external(erlang, "gleam_stdlib", "identity")
fn from_dynamic(a: Dynamic) -> anything

fn cache_atom() -> Atom {
  atom.create("cache")
}

fn named_table_atom() -> Atom {
  atom.create("named_table")
}

pub fn setup() -> TableRef {
  let cache = cache_atom()

  // Check if table exists and delete it
  let info = ets_info(cache)
  case dynamic.classify(info) {
    "Atom" -> {
      ets_delete(cache)
      Nil
    }
    _ -> Nil
  }

  // Create new table
  let table_ref = ets_new(cache, [named_table_atom()])
  TableRef(table_ref)
}

pub fn put(key: a, val: b) -> Bool {
  let cache = cache_atom()
  let tuple = to_dynamic(#(key, val))
  ets_insert(cache, tuple)
}

pub fn get(key: a) -> Option(b) {
  let cache = cache_atom()
  let result = ets_lookup(cache, to_dynamic(key))

  case result {
    [first, ..] -> {
      let tuple: #(a, b) = from_dynamic(first)
      Some(tuple.1)
    }
    _ -> None
  }
}
