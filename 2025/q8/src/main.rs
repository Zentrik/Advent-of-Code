use std::vec;

use itertools::Itertools;

fn main() {
    const RUNS: i64 = 100;
    let start_time = std::time::Instant::now();

    let mut p1_result = 0;
    let mut p2_result = 0;
    for _ in 0..RUNS {
        let input = std::fs::read_to_string("q8.txt").unwrap();
        let num_connections_to_make = 1000;

        let num_input_lines = input.lines().count();
        let mut x: Vec<i64> = vec![0; num_input_lines];
        let mut y: Vec<i64> = vec![0; num_input_lines];
        let mut z: Vec<i64> = vec![0; num_input_lines];

        for (i, line) in input.lines().enumerate() {
            let mut coords = line.split(',');
            x[i] = coords.next().unwrap().parse().unwrap();
            y[i] = coords.next().unwrap().parse().unwrap();
            z[i] = coords.next().unwrap().parse().unwrap();
        }

        // let mut pair_distances = Vec::with_capacity(num_input_lines * (num_input_lines - 1) / 2);

        let iter = (0..num_input_lines).flat_map(|i| {
            let x = &x;
            let y = &y;
            let z = &z;
            (i + 1..num_input_lines).map(move |j| {
                let dx = x[i] - x[j];
                let dy = y[i] - y[j];
                let dz = z[i] - z[j];
                let dist_sq = dx * dx + dy * dy + dz * dz;
                (i, j, dist_sq)
            })
        }).k_smallest_relaxed_by_key(num_input_lines*20, |&(_, _, dist_sq)| dist_sq);
        // }).sorted_unstable_by_key(|&d| d.2);
        // for (dist_sq, i, j) in iter {
        //     pair_distances.push((dist_sq, i, j));
        // }

        let mut point_to_circuit = vec![-1 as i32; num_input_lines];
        let mut circuit_sizes = vec![0; num_input_lines];
        let mut largest_circuit_size = 0;

        let mut num_connections = 0;
        for (point_1, point_2, _) in
            iter
        {
            num_connections += 1;
            let circuit_1 = point_to_circuit[point_1];
            let circuit_2 = point_to_circuit[point_2];

            if circuit_1 == -1 && circuit_2 == -1 {
                let new_circuit_id = point_1 as i32;
                point_to_circuit[point_1] = new_circuit_id;
                point_to_circuit[point_2] = new_circuit_id;
                circuit_sizes[new_circuit_id as usize] = 2;
                largest_circuit_size = std::cmp::max(2, largest_circuit_size);
            } else if circuit_1 == -1 {
                point_to_circuit[point_1] = circuit_2;
                circuit_sizes[circuit_2 as usize] += 1;
                largest_circuit_size = std::cmp::max(circuit_sizes[circuit_2 as usize], largest_circuit_size);
            } else if circuit_2 == -1 {
                point_to_circuit[point_2] = circuit_1;
                circuit_sizes[circuit_1 as usize] += 1;
                largest_circuit_size = std::cmp::max(circuit_sizes[circuit_1 as usize], largest_circuit_size);
            } else if circuit_1 != circuit_2 {
                // Both points are in different circuits, need to merge
                for p in 0..num_input_lines {
                    if point_to_circuit[p] == circuit_2 {
                        point_to_circuit[p] = circuit_1;
                    }
                }
                circuit_sizes[circuit_1 as usize] += circuit_sizes[circuit_2 as usize];
                largest_circuit_size = std::cmp::max(circuit_sizes[circuit_1 as usize], largest_circuit_size);
                circuit_sizes[circuit_2 as usize] = 0;
            }

            if num_connections == num_connections_to_make {
                let mut sorted_sizes = circuit_sizes.clone();
                sorted_sizes.select_nth_unstable_by_key(2, |&s| std::cmp::Reverse(s));
                p1_result += sorted_sizes[..3].iter().product::<usize>() as i64;
            }

            if largest_circuit_size == num_input_lines {
                p2_result += x[point_1] * x[point_2];
                break;
            }

        }
    }
    println!("Time per run: {:?}", start_time.elapsed() / RUNS as u32);
    println!("Part 1: {}, Part 2: {}", p1_result / RUNS, p2_result / RUNS);
}
