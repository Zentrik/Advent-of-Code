use itertools::Itertools;

fn solve_p1(
    buttons_bitmask: &Vec<u16>,
    target_lights_bitmask: u16,
) -> Option<usize> {
    // slow as allocates a lot
    for set in buttons_bitmask.iter().powerset() {
        if set.len() == 0 {
            continue;
        }
        let set_len = set.len();

        let mut indicator_lights = 0u16;
        for &button in set.iter() {
            indicator_lights ^= button;
        }
        // allocates a lot (but somehow faster? even though flamegraph claims we spend a lot of time here)
        // let indicator_lights = set.into_iter().cloned().reduce(|acc, x| acc ^ x).unwrap();
        if indicator_lights == target_lights_bitmask {
            return Some(set_len);
        }
    }

    None
}

fn get_all_p1_sols(
    buttons_bitmask: &Vec<u16>,
    target_lights_bitmask: u16,
) -> Vec<Vec<&u16>> {
    let mut all_solutions = Vec::new();

    // slow as allocates a lot
    for set in buttons_bitmask.iter().powerset() {
        let mut indicator_lights = 0u16;
        for &button in set.iter() {
            indicator_lights ^= button;
        }
        // allocates a lot (but somehow faster? even though flamegraph claims we spend a lot of time here)
        // let indicator_lights = set.into_iter().cloned().reduce(|acc, x| acc ^ x).unwrap();
        if indicator_lights == target_lights_bitmask {
            all_solutions.push(set);
        }
    }

    return all_solutions;
}

fn get_subproblem_joltage(
    target_joltage: &mut Vec<u16>,
    buttons_bitmask: &Vec<&u16>,
) -> bool{
    let mut joltage_went_negative = false;
    for &&button in buttons_bitmask.iter() {
        for i in 0..std::mem::size_of_val(&button) * 8 {
            if (button & (1 << i)) != 0 {
                if target_joltage[i] == 0 {
                    joltage_went_negative = true;
                }
                target_joltage[i] -= 1;
            }
        }
    }
    for j in target_joltage.iter_mut() {
        *j /= 2;
    }

    return !joltage_went_negative;
}

fn restore_joltage(
    target_joltage: &mut Vec<u16>,
    buttons_bitmask: &Vec<&u16>,
) -> bool{
    for j in target_joltage.iter_mut() {
        *j *= 2;
    }

    for &&button in buttons_bitmask.iter() {
        for i in 0..std::mem::size_of_val(&button) * 8 {
            if (button & (1 << i)) != 0 {
                target_joltage[i] += 1;
            }
        }
    }


    return true;
}

fn solve_p2(buttons_bitmask: &Vec<u16>, target_joltage: &mut Vec<u16>) -> u16 {
    // We have \sum_j a_ij b_j = j_i (a_ij is the j'th buttons effect on counter i, b_j is number of times button j is pressed, j_i is target joltage at counter i)
    // We solve this mod 2, then solve the remaining problem recursively
    if target_joltage.iter().all(|&j| j == 0) {
        return 0;
    }

    let subtarget_joltage_bitmask: u16 = target_joltage.iter().enumerate().map(|(ji, j)| if j % 2 == 1 { 1 << ji } else { 0 }).sum();

    let mut p2_result: u16 = u16::MAX;
    for mod2_sol in get_all_p1_sols(buttons_bitmask, subtarget_joltage_bitmask) {
        if !get_subproblem_joltage(target_joltage, &mod2_sol) {
            // Restore target_joltage
            restore_joltage(target_joltage, &mod2_sol);
            continue;
        }

        let subproblem_soln = solve_p2(buttons_bitmask, target_joltage);

        // Restore target_joltage
        restore_joltage(target_joltage, &mod2_sol);

        if subproblem_soln == u16::MAX {
            continue;
        }
        p2_result = p2_result.min(2 * subproblem_soln + mod2_sol.len() as u16);
    }

    return p2_result;
}

fn main() {
    const RUNS: usize = 1;
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

            p1_result += solve_p1(&buttons_bitmask, target_lights_bitmask).unwrap();
            let _res = solve_p2(&buttons_bitmask, &mut target_joltage);
            assert!(_res != u16::MAX);
            p2_result += _res as usize;
        }
    }
    println!("Time per run: {:?}", start_time.elapsed() / RUNS as u32);
    println!("Part 1: {}, Part 2: {}", p1_result / RUNS, p2_result / RUNS);
}
