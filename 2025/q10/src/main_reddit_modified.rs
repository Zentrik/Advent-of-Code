use fxhash::FxHashMap;
use std::time::Instant;

fn parse_joltage_str(joltage_str: &str) -> [u16; 16] {
    let joltage_str = &joltage_str[1..joltage_str.len() - 1];
    let mut joltages = [0; 16];
    joltage_str
        .split(',')
        .map(|sub| sub.parse().unwrap())
        .enumerate()
        .for_each(|(i, val)| joltages[i] = val);
    joltages
}

fn parse_button_str(button_str: &str) -> u16 {
    let button_str = &button_str[1..button_str.len() - 1];
    return button_str
        .split(',')
        .map(|sub| sub.as_bytes()[0] - b'0')
        .map(|i| 1 << i)
        .sum();
}

fn parse_line(line: &str, buttons_as_bitmask: &mut Vec<u16>) -> [u16; 16] {
    buttons_as_bitmask.clear();
    let mut parts = line.split_ascii_whitespace();
    let mut joltages = [0; 16];
    _ = parts.next(); // skip lights
    while let Some(s) = parts.next() {
        if s.as_bytes()[0] as char == '(' {
            buttons_as_bitmask.push(parse_button_str(s));
        } else {
            joltages = parse_joltage_str(s);
        }
    }
    joltages
}

fn get_odd_mask(slice: [u16; 16]) -> usize {
    slice
        .iter()
        .enumerate()
        .fold(0, |acc, (i, x)| acc | ((*x as usize & 1) << i))
}

fn fill_mask_to_diffs_map(
    mask_to_diffs: &mut [Vec<(u16, [u16; 16])>; 1024],
    buttons_masks: &mut Vec<u16>,
) {
    // clear existing map
    for v in mask_to_diffs.iter_mut() {
        v.clear();
    }

    fn backtrack<'a>(
        mask_to_diffs: &mut [Vec<(u16, [u16; 16])>; 1024],
        buttons_masks: &mut Vec<u16>,
        button_idx: usize,
        num_pressed: u16,
        diff: [u16; 16],
        mask: u16,
    ) {
        if button_idx == buttons_masks.len() {
            mask_to_diffs[mask as usize].push((num_pressed, diff.clone()))
        } else {
            // case 1, don't choose this button
            backtrack(
                mask_to_diffs,
                buttons_masks,
                button_idx + 1,
                num_pressed,
                diff.clone(),
                mask,
            );

            // case 2: choose this button
            let mut new_diff = diff.clone();

            let mut b = buttons_masks[button_idx];
            while b != 0 {
                let tz = b.trailing_zeros() as usize;
                new_diff[tz] += 1;
                b &= b - 1;
            }

            let new_mask = mask ^ buttons_masks[button_idx];
            backtrack(
                mask_to_diffs,
                buttons_masks,
                button_idx + 1,
                num_pressed + 1,
                new_diff,
                new_mask,
            );
        }
    }

    // backtrack to fill
    backtrack(mask_to_diffs, buttons_masks, 0, 0, [0; 16], 0);
}

fn dfs(
    memo: &mut FxHashMap<[u16; 16], u16>,
    mask_to_diffs: &[Vec<(u16, [u16; 16])>; 1024],
    joltages: [u16; 16],
    len_so_far: u16,
    best_solution: u16,
) -> u16 {
    if joltages.iter().all(|x| *x == 0) {
        0
    } else if let Some(res) = memo.get(&joltages) {
        *res
    } else {
        let mask = get_odd_mask(joltages);
        let mut best = u16::MAX;
        for (num_pressed, diff) in &mask_to_diffs[mask] {
            if len_so_far + 2 * *num_pressed >= best_solution {
                continue;
            }
            if (0..16).any(|i| diff[i] > joltages[i]) {
                continue;
            }
            let mut next_joltages = [0; 16];
            for i in 0..16 {
                next_joltages[i] = (joltages[i] - diff[i]) / 2;
            }
            let subproblem_soln =
                dfs(memo, mask_to_diffs, next_joltages, len_so_far + 2 * *num_pressed, best_solution);
            best = best.min(subproblem_soln.saturating_mul(2).saturating_add(*num_pressed));
        }
        memo.insert(joltages, best);
        best
    }
}

fn solve_line(
    line: &str,
    memo: &mut FxHashMap<[u16; 16], u16>,
    mask_to_diffs: &mut [Vec<(u16, [u16; 16])>; 1024],
    buttons_as_bitmask: &mut Vec<u16>,
) -> usize {
    let joltages = parse_line(line, buttons_as_bitmask);

    fill_mask_to_diffs_map(mask_to_diffs, buttons_as_bitmask);
    memo.clear();

    dfs(memo, &mask_to_diffs, joltages, 0, u16::MAX) as usize
}

fn main() {
    let start = Instant::now();
    const RUNS: usize = 100;
    let mut result: usize = 0;

    for _ in 0..RUNS {
    let mut memo = FxHashMap::default();
    let mut mask_to_diffs = [const { Vec::new() }; 1024];
    let mut buttons_as_bitmask = Vec::new();

    let file_content = std::fs::read_to_string("q10.txt").unwrap();
    result += file_content
        .lines()
        .map(|line| {
            solve_line(
                line,
                &mut memo,
                &mut mask_to_diffs,
                &mut buttons_as_bitmask,
            )
        })
        .sum::<usize>();
    }
    let execution_time = start.elapsed();
    println!("Answer: {:?}", result / RUNS);
    println!("Execution time: {:?}", execution_time / RUNS as u32)
}
