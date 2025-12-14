use hashbrown::HashMap;

fn solve_p1(solutions_by_mask: &Vec<Vec<u16>>, target_lights_bitmask: u16) -> Option<usize> {
    let sols = &solutions_by_mask[target_lights_bitmask as usize];
    sols.iter().map(|mask| mask.count_ones() as usize).min()
}

struct GetAllP1Sols {
    solutions_by_mask: Vec<Vec<u16>>, // mask -> subset bitmasks (buttons <= 16)
    buttons_bitmask: Vec<u16>,        // original buttons
}

impl GetAllP1Sols {
    fn new(solutions_by_mask: Vec<Vec<u16>>, buttons_bitmask: Vec<u16>) -> Self {
        Self {
            solutions_by_mask,
            buttons_bitmask,
        }
    }

    fn get(&self, target_lights_bitmask: u16) -> &Vec<u16> {
        &self.solutions_by_mask[target_lights_bitmask as usize]
    }

    fn buttons(&self) -> &[u16] {
        &self.buttons_bitmask
    }
}

fn get_subproblem_joltage(target_joltage: &mut [u16], buttons_bitmask: &[u16], subset_mask: u16) -> bool {
    let mut mask = subset_mask;
    while mask != 0 {
        let idx = mask.trailing_zeros() as usize;
        let button = buttons_bitmask[idx];
        let mut b = button;
        while b != 0 {
            let tz = b.trailing_zeros() as usize;
            debug_assert!(tz < target_joltage.len());
            if target_joltage[tz] == 0 {
                return false;
            }
            target_joltage[tz] -= 1;
            b &= b - 1;
        }
        mask &= mask - 1;
    }
    for j in target_joltage.iter_mut() {
        *j /= 2;
    }
    true
}

fn solve_p2(
    get_all_p1_sols: &GetAllP1Sols,
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

    let solution_masks = get_all_p1_sols.get(subtarget_joltage_bitmask).clone();
    for subset_mask in solution_masks {
        scratch.copy_from_slice(target_joltage);
        let mut_target_joltage = &mut scratch;
        let mod2_len = subset_mask.count_ones() as u16;

        if !get_subproblem_joltage(mut_target_joltage, get_all_p1_sols.buttons(), subset_mask) {
            continue;
        }

        if toggled_buttons_so_far + 2 * mod2_len >= best_solution {
            continue;
        }

        let subproblem_soln = solve_p2(
            get_all_p1_sols,
            mut_target_joltage,
            mod2_len,
            p2_result,
            memo,
        );
        if subproblem_soln == u16::MAX {
            continue;
        }
        p2_result = p2_result.min(2 * subproblem_soln + mod2_len);
    }

    memo.insert(target_joltage.clone(), p2_result);

    p2_result
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

            let mut max_bit: usize = 0;
            for &b in buttons_bitmask.iter() {
                if b != 0 {
                    max_bit = max_bit.max((u16::BITS - 1 - b.leading_zeros()) as usize);
                }
            }
            if target_lights_bitmask != 0 {
                max_bit = max_bit.max((u16::BITS - 1 - target_lights_bitmask.leading_zeros()) as usize);
            }
            let table_size = 1usize << (max_bit + 1);
            let mut solutions_by_mask: Vec<Vec<u16>> = vec![Vec::new(); table_size];
            solutions_by_mask[0].push(0);

            let total_subsets = 1u16 << buttons_bitmask.len();
            for subset_mask in 1u16..total_subsets {
                let mut indicator: u16 = 0;
                let mut m = subset_mask;
                while m != 0 {
                    let b_idx = m.trailing_zeros() as usize;
                    indicator ^= buttons_bitmask[b_idx];
                    m &= m - 1;
                }
                solutions_by_mask[indicator as usize].push(subset_mask);
            }


            p1_result += solve_p1(&solutions_by_mask, target_lights_bitmask).unwrap();
            let mut memo = HashMap::new();
            let solver = GetAllP1Sols::new(solutions_by_mask, buttons_bitmask);
            let _res = solve_p2(
                &solver,
                &target_joltage,
                0,
                u16::MAX,
                &mut memo,
            );
            assert!(_res != u16::MAX);
            p2_result += _res as usize;
        }
    }
    println!("Time per run: {:?}", start_time.elapsed() / RUNS as u32);
    println!("Part 1: {}, Part 2: {}", p1_result / RUNS, p2_result / RUNS);
}
