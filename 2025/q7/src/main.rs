fn main() {
    const RUNS: i64 = 50_000;
    let start_time = std::time::Instant::now();

    let mut p1_result = 0;
    let mut p2_result = 0;
    for _ in 0..RUNS {
        let input = std::fs::read_to_string("q7.txt").unwrap();
        
        let mut active_timelines: Vec<i64> = vec![0; input.lines().next().unwrap().len()];
        let mut next_active_timelines: Vec<i64> = vec![0; input.lines().next().unwrap().len()];

        let mut lines = input.lines();
        for (i, &loc) in lines.next().unwrap().as_bytes().iter().enumerate() {
            // process first line
            if (loc as char) == 'S' {
                active_timelines[i] = 1;
            }
        }

        for line in lines {
            // process remaining lines
            for i in 0..active_timelines.len() {
                let timelines = active_timelines[i];
                if timelines > 0 {
                    // update active beams
                    if line.as_bytes()[i] as char == '^' {
                        p1_result += 1;
                        if i > 0 {
                            next_active_timelines[i - 1] += timelines;
                        }
                        if i + 1 < line.len() {
                            next_active_timelines[i + 1] += timelines;
                        }
                    } else {
                        next_active_timelines[i] += timelines;
                    }
                }
                active_timelines[i] = 0; // reset current timeline for next line
            }
            std::mem::swap(&mut active_timelines, &mut next_active_timelines);
        }

        p2_result += active_timelines.iter().sum::<i64>();
    }

    println!("Time per run: {:?}", start_time.elapsed() / RUNS as u32);
    println!("Part 1: {}, Part 2: {}", p1_result / RUNS, p2_result / RUNS);
}
