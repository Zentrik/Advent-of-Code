fn main() {
    const RUNS: i64 = 10_000;
    let start_time = std::time::Instant::now();

    let mut p1_result = 0;
    let mut p2_result = 0;
    for _ in 0..RUNS {
        let input = std::fs::read_to_string("q6.txt").unwrap();
        let lines = input.lines().collect::<Vec<&str>>();

        // let is_mul: Vec<bool> = lines
        //     .last()
        //     .unwrap()
        //     .as_bytes()
        //     .iter()
        //     .filter(|char| char != &&b' ')
        //     .map(|&char| (char as char) == '*')
        //     .collect();

        let is_mul: Vec<bool> = lines
            .last()
            .unwrap()
            .split_ascii_whitespace()
            .map(|op| op == "*")
            .collect();

        let mut p1_problem_sol = is_mul
            .iter()
            .map(|&b| if b { 1 } else { 0 })
            .collect::<Vec<i64>>();
        let mut p2_problem_sol = p1_problem_sol.clone();

        for line in lines[0..lines.len() - 1].iter() {
            for (problem_index, number) in line.split_ascii_whitespace().enumerate() {
                let value = number.parse::<i64>().unwrap();
                if is_mul[problem_index] {
                    p1_problem_sol[problem_index] *= value;
                } else {
                    p1_problem_sol[problem_index] += value;
                }
            }
        }

        // Transposing lines solution to p2 - even slower
        // let lines_transposed = (0..lines[0].len())
        //     .map(|i| lines[0..lines.len()-1].iter().map(|line| line.as_bytes()[i] as char).collect::<String>())
        //     .collect::<Vec<String>>();

        // let mut problem_index = 0;
        // for line in lines_transposed.iter() {
        //     if line.trim().is_empty() {
        //         problem_index += 1;
        //         continue;
        //     }
        //     let value = line.trim().parse::<i64>().unwrap();
        //     if is_mul[problem_index] {
        //         p2_problem_sol[problem_index] *= value;
        //     } else {
        //         p2_problem_sol[problem_index] += value;
        //     }
        // }

        let mut problem_index = 0;
        for i in 0..lines[0].len() {
            let mut num: i64 = 0;
            let mut all_whitespace = true;

            for j in 0..lines.len() - 1 {
                let c = lines[j].as_bytes()[i];
                if !c.is_ascii_whitespace() {
                    num *= 10;
                    num += (c - b'0') as i64;
                    all_whitespace = false;
                }
            }

            if all_whitespace {
                problem_index += 1;
            } else {
                if is_mul[problem_index] {
                    p2_problem_sol[problem_index] *= num;
                } else {
                    p2_problem_sol[problem_index] += num;
                }
            }
        }

        p1_result += p1_problem_sol.iter().sum::<i64>();
        p2_result += p2_problem_sol.iter().sum::<i64>();
    }

    println!("Time per run: {:?}", start_time.elapsed() / RUNS as u32);
    println!("Part 1: {}, Part 2: {}", p1_result / RUNS, p2_result / RUNS);
}
