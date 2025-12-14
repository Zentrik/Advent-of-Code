use bumpalo::{Bump, collections::Vec};
use core::str;
use hashbrown::HashMap;
use memoize::memoize;
use std::time::Instant;

#[memoize(Ignore: device_to_outputs)]
fn count_paths_to_result(
    device: &'static str,
    result: &'static str,
    device_to_outputs: &HashMap<&'static str, Vec<&'static str>>,
) -> usize {
    if device == result {
        1
    } else if let Some(outputs) = device_to_outputs.get(device) {
        outputs
            .iter()
            .map(|&out| count_paths_to_result(out, result, device_to_outputs))
            .sum()
    } else {
        0
    }
}

fn main() {
    let start = Instant::now();
    const RUNS: usize = 10_000;

    let mut p1_result: usize = 0;
    let mut p2_result: usize = 0;

    for _ in 0..RUNS {
        let file_contents: &str = include_str!("q11.txt");
        // let file_contents = fs::read_to_string("q11.txt").unwrap();
        // let file_contents = Box::leak(file_contents.into_boxed_str());

        let bump = Bump::new();
        let mut device_to_outputs = HashMap::<&'static str, Vec<&'static str>>::new();
        for line in file_contents.lines() {
            let (parent, children) = line.split_once(':').unwrap();
            device_to_outputs
                .entry(parent)
                .or_insert_with(|| Vec::new_in(&bump))
                .extend(children.split_ascii_whitespace());
        }

        p1_result += count_paths_to_result("you", "out", &device_to_outputs);

        for path in [["svr", "fft", "dac", "out"], ["svr", "dac", "fft", "out"]].iter() {
            let mut path_count = 1;
            for window in path.windows(2) {
                let from = window[0];
                let to = window[1];
                path_count *= count_paths_to_result(from, to, &device_to_outputs);
            }
            p2_result += path_count;
        }
    }

    let execution_time = start.elapsed();
    println!(
        "P1 Result: {:?}, P2 Result: {:?}",
        p1_result / RUNS,
        p2_result / RUNS
    );
    println!("Execution time: {:?}", execution_time / RUNS as u32)
}
