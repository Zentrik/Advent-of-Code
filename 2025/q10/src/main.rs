use fxhash::FxHashMap;
use rayon::prelude::*;
use std::cell::RefCell;
use std::time::Instant;

struct WorkerScratch {
    memo: FxHashMap<[u16; 16], usize>,
    mask_to_diffs: [Vec<(usize, [u16; 16])>; 1024],
    buttons_vec: Vec<[u16; 16]>,
    buttons_masks: Vec<usize>,
}

impl WorkerScratch {
    fn new() -> Self {
        Self {
            memo: FxHashMap::default(),
            mask_to_diffs: std::array::from_fn(|_| Vec::new()),
            buttons_vec: Vec::new(),
            buttons_masks: Vec::new(),
        }
    }

    fn solve_with_scratch(&mut self, line: &str) -> (usize, usize) {
        solve_line(
            line,
            &mut self.memo,
            &mut self.mask_to_diffs,
            &mut self.buttons_vec,
            &mut self.buttons_masks,
        )
    }
}

thread_local! {
    static SCRATCH: RefCell<WorkerScratch> = RefCell::new(WorkerScratch::new());
}

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

fn parse_button_str(button_str: &str) -> [u16; 16] {
    let button_str = &button_str[1..button_str.len() - 1];
    let mut button = [0; 16];
    button_str
        .split(',')
        .map(|sub| sub.as_bytes()[0] - b'0')
        .for_each(|i| button[i as usize] = 1);
    button
}

fn parse_lights_str(lights_str: &str) -> u16 {
    let lights_str = &lights_str[1..lights_str.len() - 1];
    lights_str
        .as_bytes()
        .iter().enumerate()
        .map(|(i, &b)| if b == b'#' { 1 << i} else { 0 })
        .sum()
}

fn parse_line(line: &str, buttons_vec: &mut Vec<[u16; 16]>) -> (u16, [u16; 16]) {
    buttons_vec.clear();
    let mut parts = line.split(" ");
    let mut joltages = [0; 16];
    let lights = parse_lights_str(parts.next().unwrap());
    while let Some(s) = parts.next() {
        if s.contains("(") {
            buttons_vec.push(parse_button_str(s));
        } else {
            joltages = parse_joltage_str(s);
        }
    }
    (lights, joltages)
}

fn get_odd_mask(slice: [u16; 16]) -> usize {
    slice
        .iter()
        .enumerate()
        .fold(0, |acc, (i, x)| acc | ((*x as usize & 1) << i))
}

fn fill_mask_to_diffs_map(
    mask_to_diffs: &mut [Vec<(usize, [u16; 16])>; 1024],
    buttons: &Vec<[u16; 16]>,
    buttons_masks: &mut Vec<usize>,
) {
    fn backtrack<'a>(
        mask_to_diffs: &mut [Vec<(usize, [u16; 16])>; 1024],
        buttons: &'a Vec<[u16; 16]>,
        buttons_masks: &mut Vec<usize>,
        button_idx: usize,
        num_pressed: usize,
        diff: [u16; 16],
        mask: usize,
    ) {
        if button_idx == buttons.len() {
            mask_to_diffs[mask].push((num_pressed, diff.clone()))
        } else {
            // case 1, don't choose this button
            backtrack(
                mask_to_diffs,
                buttons,
                buttons_masks,
                button_idx + 1,
                num_pressed,
                diff.clone(),
                mask,
            );

            // case 2: choose this button
            let mut new_diff = diff.clone();
            for i in 0..16 {
                new_diff[i] += buttons[button_idx][i];
            }
            let new_mask = mask ^ buttons_masks[button_idx];
            backtrack(
                mask_to_diffs,
                buttons,
                buttons_masks,
                button_idx + 1,
                num_pressed + 1,
                new_diff,
                new_mask,
            );
        }
    }

    // clear existing map
    for v in mask_to_diffs.iter_mut() {
        v.clear();
    }

    // create button masks
    buttons_masks.clear();
    for button in buttons {
        buttons_masks.push(get_odd_mask(*button));
    }

    // backtrack to fill
    backtrack(mask_to_diffs, &buttons, buttons_masks, 0, 0, [0; 16], 0);
}

fn dfs(
    memo: &mut FxHashMap<[u16; 16], usize>,
    mask_to_diffs: &[Vec<(usize, [u16; 16])>; 1024],
    joltages: [u16; 16],
) -> usize {
    if joltages.iter().all(|x| *x == 0) {
        0
    } else if let Some(res) = memo.get(&joltages) {
        *res
    } else {
        let mask = get_odd_mask(joltages);
        let mut best = 99999;
        for (num_pressed, diff) in &mask_to_diffs[mask] {
            if (0..16).any(|i| diff[i] > joltages[i]) {
                continue;
            }
            let mut next_joltages = [0; 16];
            for i in 0..16 {
                next_joltages[i] = (joltages[i] - diff[i]) / 2;
            }
            best = best.min(num_pressed + 2 * dfs(memo, mask_to_diffs, next_joltages))
        }
        memo.insert(joltages, best);
        best
    }
}

fn solve_line(
    line: &str,
    memo: &mut FxHashMap<[u16; 16], usize>,
    mask_to_diffs: &mut [Vec<(usize, [u16; 16])>; 1024],
    buttons_vec: &mut Vec<[u16; 16]>,
    buttons_masks: &mut Vec<usize>,
) -> (usize, usize) {
    let (lights, joltages) = parse_line(line, buttons_vec);

    fill_mask_to_diffs_map(mask_to_diffs, buttons_vec, buttons_masks);
    memo.clear();

    let p1_result = mask_to_diffs[lights as usize].iter().min_by_key(|(num_pressed, _)| num_pressed).unwrap().0;
    let p2_result = dfs(memo, &mask_to_diffs, joltages);
    (p1_result, p2_result)
}

fn main() {
    let start = Instant::now();
    const RUNS: usize = 1000;

    let mut p1_result: usize = 0;
    let mut p2_result: usize = 0;

    for _ in 0..RUNS {
        let file_content = std::fs::read_to_string("q10.txt").unwrap();
        let lines: Vec<&str> = file_content.lines().collect();
        let (p1, p2) = lines
            .par_iter()
            .map(|line| {
                SCRATCH.with(|scratch_cell| scratch_cell.borrow_mut().solve_with_scratch(line))
            })
            .reduce(|| (0, 0), |(p1a, p2a), (p1b, p2b)| (p1a + p1b, p2a + p2b));
        p1_result += p1;
        p2_result += p2;
    }

    let execution_time = start.elapsed();
    println!("P1 Result: {:?}, P2 Result: {:?}", p1_result / RUNS, p2_result / RUNS);
    println!("Execution time: {:?}", execution_time / RUNS as u32)
}
