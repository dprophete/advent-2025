import gleam/format.{printf}
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

fn make_connections(
  sorted_dists: List(#(#(V3, V3), Int)),
  groups: List(Set(V3)),
  nb_connections: Int,
  limit: Int,
) -> #(List(#(#(V3, V3), Int)), List(Set(V3)), Int) {
  case nb_connections == limit {
    True -> #(sorted_dists, groups, nb_connections)
    False -> {
      let assert [first, ..rest] = sorted_dists
      let #(#(pos1, pos2), _) = first
      let existing_group = fn(pos) {
        groups
        |> list.find(fn(group) { set.contains(group, pos) })
      }
      case existing_group(pos1), existing_group(pos2) {
        Ok(group1), Ok(group2) if group1 == group2 -> {
          // both positions are already in the same group -> nothing to add
          make_connections(rest, groups, nb_connections + 1, limit)
        }
        Ok(group1), Ok(group2) -> {
          // merge groups
          let new_group = set.union(group1, group2)
          let new_groups =
            groups
            |> list.filter(fn(g) { g != group1 && g != group2 })
            |> list.append([new_group])
          printf("merging groups for ~s and ~s\n", #(v3.pp(pos1), v3.pp(pos2)))
          make_connections(rest, new_groups, nb_connections + 1, limit)
        }
        Ok(group1), Error(_) -> {
          // add pos2 to group1
          let new_groups = add_pos_to_group(pos2, group1, groups)
          printf("adding ~s to group of ~s\n", #(v3.pp(pos1), v3.pp(pos2)))
          make_connections(rest, new_groups, nb_connections + 1, limit)
        }
        Error(_), Ok(group2) -> {
          // add pos1 to group2
          let new_groups = add_pos_to_group(pos1, group2, groups)
          printf("adding ~s to group of ~s\n", #(v3.pp(pos2), v3.pp(pos1)))
          make_connections(rest, new_groups, nb_connections + 1, limit)
        }
        _, _ -> {
          // create a new group
          printf("creating new group for ~s and ~s\n", #(
            v3.pp(pos2),
            v3.pp(pos1),
          ))
          make_connections(
            rest,
            [set.from_list([pos1, pos2]), ..groups],
            nb_connections + 1,
            limit,
          )
        }
      }
    }
  }
}

pub fn p1(content: String, limit: Int) -> Int {
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

  let #(_, groups, _) = make_connections(sorted_dists, [], 0, limit)
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

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 8: Playground")
  assert time_it(p1(_, 10), "p1", "data/08_sample.txt") == 40
  assert time_it(p1(_, 1000), "p1", "data/08_input.txt") == 72_150
  // assert time_it(p2, "p2", "data/08_sample.txt") == 40
  // assert time_it(p2, "p2", "data/08_input.txt") == 15_093_663_987_272
}
