use hashbrown::HashMap;

use itertools::Itertools;

fn solve_p1(
    powerset_of_buttons_bitmask: &Vec<(u16, Vec<u16>)>,
    target_lights_bitmask: u16,
) -> Option<usize> {
    for (indicator_lights, set) in powerset_of_buttons_bitmask.iter() {
        if set.is_empty() {
            continue;
        }
        if *indicator_lights == target_lights_bitmask {
            return Some(set.len());
        }
    }

    None
}

struct GetAllP1Sols {
    powerset_of_buttons_bitmask: Vec<(u16, Vec<u16>)>,
    cache: HashMap<u16, Vec<usize>>, // indices of subsets matching a mask
}

impl GetAllP1Sols {
    fn new(powerset_of_buttons_bitmask: Vec<(u16, Vec<u16>)>) -> Self {
        Self {
            powerset_of_buttons_bitmask,
            cache: HashMap::new(),
        }
    }

    fn get(&mut self, target_lights_bitmask: u16) -> &Vec<usize> {
        self.cache.entry(target_lights_bitmask).or_insert_with(|| {
            let mut matching_indices = Vec::new();
            for (idx, (indicator_lights, _set)) in
                self.powerset_of_buttons_bitmask.iter().enumerate()
            {
                if *indicator_lights == target_lights_bitmask {
                    matching_indices.push(idx);
                }
            }
            matching_indices
        })
    }
}

fn get_subproblem_joltage(target_joltage: &mut [u16], buttons_bitmask: &[u16]) -> bool {
    for &button in buttons_bitmask {
        let mut b = button;
        while b != 0 {
            let tz = b.trailing_zeros() as usize;
            debug_assert!(tz < target_joltage.len());
            if target_joltage[tz] == 0 {
                return false;
            }
            target_joltage[tz] -= 1;
            b &= b - 1; // clear lowest set bit
        }
    }
    for j in target_joltage.iter_mut() {
        *j /= 2;
    }
    true
}

fn solve_p2(
    get_all_p1_sols: &mut GetAllP1Sols,
    target_joltage: &Vec<u16>,
    toggled_buttons_so_far: u16,
    best_solution: u16,
    memo: &mut HashMap<Vec<u16>, u16>,
) -> u16 {
    // We have \sum_j a_ij b_j = j_i (a_ij is the j'th buttons effect on counter i, b_j is number of times button j is pressed, j_i is target joltage at counter i)
    // We solve this mod 2, then solve the remaining problem recursively
    if target_joltage.iter().all(|&j| j == 0) {
        return 0;
    }

    if let Some(&cached_result) = memo.get(target_joltage) {
        return cached_result;
    }

    let subtarget_joltage_bitmask: u16 = target_joltage
        .iter()
        .enumerate()
        .map(|(ji, j)| if j % 2 == 1 { 1 << ji } else { 0 })
        .sum();

    let mut p2_result: u16 = u16::MAX;

    // reuse a single scratch buffer per call to avoid cloning in the loop
    let mut scratch = vec![0u16; target_joltage.len()];

    let solution_indices = get_all_p1_sols.get(subtarget_joltage_bitmask).clone();
    for idx in solution_indices {
        scratch.copy_from_slice(target_joltage);
        let mut_target_joltage = &mut scratch;
        let mod2_sol = &get_all_p1_sols.powerset_of_buttons_bitmask[idx].1;
        let mod2_len = mod2_sol.len() as u16;

        if !get_subproblem_joltage(mut_target_joltage, mod2_sol) {
            continue;
        }

        if toggled_buttons_so_far + 2 * mod2_len >= best_solution {
            continue;
        }

        let subproblem_soln = solve_p2(get_all_p1_sols, mut_target_joltage, mod2_len, p2_result, memo);
        if subproblem_soln == u16::MAX {
            continue;
        }
        p2_result = p2_result.min(2 * subproblem_soln + mod2_len);
    }

    memo.insert(target_joltage.clone(), p2_result);

    return p2_result;
}

fn main() {
    const RUNS: usize = 100;
    let start_time = std::time::Instant::now();

    let mut p1_result: usize = 0;
    let mut p2_result: usize = 0;
    for _ in 0..RUNS {
        let input = std::fs::read_to_string("q10.txt").unwrap();

        for line in input.lines() {
            let mut parts = line.split_ascii_whitespace();

            let target_lights_str = parts.next().unwrap();
            let target_lights_str = &target_lights_str[1..target_lights_str.len() - 1];

            let target_lights_bitmask: u16 = target_lights_str
                .chars()
                .enumerate()
                .map(|(i, c)| if c == '#' { 1 << i } else { 0 })
                .sum();

            let mut buttons_bitmask: Vec<u16> = Vec::new();
            let mut target_joltage: Vec<u16> = Vec::new();
            for button in parts {
                if button.as_bytes()[0] as char == '{' {
                    for joltage_str in button[1..button.len() - 1].split(',') {
                        let joltage: u16 = joltage_str.parse().unwrap();
                        target_joltage.push(joltage);
                    }
                } else {
                    let button_str = &button[1..button.len() - 1];
                    let button_bitmask: u16 = button_str
                        .split(',')
                        .map(|s| s.parse::<u16>().unwrap())
                        .map(|i| 1 << i)
                        .sum();
                    buttons_bitmask.push(button_bitmask);
                }
            }

            let powerset_of_buttons_bitmask: Vec<(u16, Vec<u16>)> = buttons_bitmask
                .into_iter()
                .powerset()
                .map(|subset| {
                    let indicator = subset.iter().fold(0u16, |acc, &b| acc ^ b);
                    (indicator, subset)
                })
                .collect();
            p1_result += solve_p1(&powerset_of_buttons_bitmask, target_lights_bitmask).unwrap();
            let mut get_all_p1_sols = GetAllP1Sols::new(powerset_of_buttons_bitmask);
            let _res = solve_p2(&mut get_all_p1_sols, &target_joltage, 0, u16::MAX, &mut HashMap::new());
            assert!(_res != u16::MAX);
            p2_result += _res as usize;
        }
    }
    println!("Time per run: {:?}", start_time.elapsed() / RUNS as u32);
    println!("Part 1: {}, Part 2: {}", p1_result / RUNS, p2_result / RUNS);
}
