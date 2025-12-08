// import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/order.{Lt}
import gleam/set.{type Set}
import gleam/string
import utils.{list_product, pp_day, time_it}
import v3.{type V3}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

fn add_pos_to_group(
  pos: V3,
  group: Set(V3),
  groups: List(Set(V3)),
) -> List(Set(V3)) {
  let new_group = group |> set.insert(pos)
  groups
  |> list.filter(fn(g) { g != group })
  |> list.append([new_group])
}

fn make_connection(
  sorted_dists: List(#(#(V3, V3), Int)),
  groups: List(Set(V3)),
  nb_connections: Int,
  limit: Int,
  last_connection: #(V3, V3),
) -> #(List(Set(V3)), #(V3, V3)) {
  case nb_connections == limit || list.is_empty(sorted_dists) {
    True -> #(groups, last_connection)
    False -> {
      let assert [first, ..rest] = sorted_dists
      let #(conn, _dist) = first
      let #(pos1, pos2) = conn
      let existing_group = fn(pos) {
        groups
        |> list.find(fn(group) { set.contains(group, pos) })
      }
      case existing_group(pos1), existing_group(pos2) {
        Ok(group1), Ok(group2) if group1 == group2 -> {
          // both positions are already in the same group -> nothing to add
          make_connection(
            rest,
            groups,
            nb_connections + 1,
            limit,
            last_connection,
          )
        }
        Ok(group1), Ok(group2) -> {
          // merge groups
          let new_group = set.union(group1, group2)
          let new_groups =
            groups
            |> list.filter(fn(g) { g != group1 && g != group2 })
            |> list.append([new_group])
          make_connection(rest, new_groups, nb_connections + 1, limit, conn)
        }
        Ok(group1), Error(_) -> {
          // add pos2 to group1
          let new_groups = add_pos_to_group(pos2, group1, groups)
          make_connection(rest, new_groups, nb_connections + 1, limit, conn)
        }
        Error(_), Ok(group2) -> {
          // add pos1 to group2
          let new_groups = add_pos_to_group(pos1, group2, groups)
          make_connection(rest, new_groups, nb_connections + 1, limit, conn)
        }
        _, _ -> {
          // create a new group
          make_connection(
            rest,
            [set.from_list([pos1, pos2]), ..groups],
            nb_connections + 1,
            limit,
            conn,
          )
        }
      }
    }
  }
}

fn do_it(content: String, limit: Int) -> #(List(Set(V3)), #(V3, V3)) {
  let positions =
    content
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [x, y, z] =
        line |> string.split(",") |> list.filter_map(int.parse)
      #(x, y, z)
    })

  // let's compute all the distances?
  let sorted_dists: List(#(#(V3, V3), Int)) =
    positions
    |> list.map(fn(pos1) {
      positions
      |> list.filter_map(fn(pos2) {
        case v3.compare(pos1, pos2) {
          Lt -> Ok(#(#(pos1, pos2), v3.dist_square(pos1, pos2)))
          _ -> Error(Nil)
        }
      })
    })
    |> list.flatten
    |> list.sort(fn(a, b) { int.compare(a.1, b.1) })

  make_connection(sorted_dists, [], 0, limit, #(#(0, 0, 0), #(0, 0, 0)))
}

pub fn p1(content: String, limit: Int) -> Int {
  let #(groups, _) = do_it(content, limit)
  groups
  |> list.map(set.size)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> list_product
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

pub fn p2(content: String) -> Int {
  let #(_, last_conn) = do_it(content, -1)
  last_conn.0.0 * last_conn.1.0
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 8: Playground")
  assert time_it(p1(_, 10), "p1", "data/08_sample.txt") == 40
  assert time_it(p1(_, 1000), "p1", "data/08_input.txt") == 72_150
  assert time_it(p2, "p2", "data/08_sample.txt") == 25_272
  assert time_it(p2, "p2", "data/08_input.txt") == 3_926_518_899
}
