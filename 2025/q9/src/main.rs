use std::vec;


fn is_valid_p2_rectangle(x: &Vec<i64>, y: &Vec<i64>, i: usize, j: usize) -> bool {
    let (x1, y1, x2, y2) = (x[i], y[i], x[j], y[j]);

    for k in 0..x.len() {
        let (xk, yk) = (x[k], y[k]);
        // Check if any point is inside the rectangle formed by (x1, y1) and (x2, y2) on opposite corners
        // If they are the rectangle must not be fully tiled
        if std::cmp::min(x1, x2) < xk && xk < std::cmp::max(x1, x2) && std::cmp::min(y1, y2) < yk && yk < std::cmp::max(y1, y2) {
            return false;
        }
        let (xkn, ykn) = (x[(k + 1) % x.len()], y[(k + 1) % y.len()]);

        // If we have a horizontal line segment that crosses the interior of the rectangle, it is invalid
        if std::cmp::min(xk, xkn) <= std::cmp::min(x1, x2) && std::cmp::max(xk, xkn) >= std::cmp::max(x1, x2) &&
           yk == ykn && std::cmp::min(y1, y2) < yk && yk < std::cmp::max(y1, y2) {
            return false;
        }

        // If we have a vertical line segment that crosses the interior of the rectangle, it is invalid
        if std::cmp::min(yk, ykn) <= std::cmp::min(y1, y2) && std::cmp::max(yk, ykn) >= std::cmp::max(y1, y2) &&
           xk == xkn && std::cmp::min(x1, x2) < xk && xk < std::cmp::max(x1, x2) {
            return false;
        }
    }

    // Test if a point inside the rectangle is inside the polygon
    // We test the point (min(x1, x2) + 0.5, min(y1, y2) + 0.5)
    // Note: we don't want to test a point on the edge of the rectangle/polygon as it gets confusing as to which lines to count
    // See https://www.eecs.umich.edu/courses/eecs380/HANDOUTS/PROJ2/InsidePoly.html

    let mut count = 0;

    let test_x = std::cmp::min(x1, x2) as f64 + 0.5;
    let test_y = std::cmp::min(y1, y2) as f64 + 0.5;
    for k in 0..x.len() {
        let (xk, yk) = (x[k], y[k]);
        let (xkn, ykn) = (x[(k+1) % x.len()], y[(k+1) % y.len()]);

        // Count number of times rectangle perimeter crosses line x=test_x for y < test_y
        // Checking if line segment (xk, yk) to (xkn, ykn) crosses line x=test_x below test_y
        if std::cmp::min(xk, xkn) as f64 <= test_x && std::cmp::max(xk, xkn) as f64 >= test_x && yk == ykn && (yk as f64) < test_y {
            count += 1;
        }
    }

    return count % 2 == 1;
}

fn main() {
    const RUNS: i64 = 100;
    let start_time = std::time::Instant::now();

    let mut p1_result = 0;
    let mut p2_result = 0;
    for _ in 0..RUNS {
        let input = std::fs::read_to_string("q9.txt").unwrap();

        let num_input_lines = input.lines().count();
        let mut x: Vec<i64> = vec![0; num_input_lines];
        let mut y: Vec<i64> = vec![0; num_input_lines];

        for (i, line) in input.lines().enumerate() {
            let mut coords = line.split(',');
            x[i] = coords.next().unwrap().parse().unwrap();
            y[i] = coords.next().unwrap().parse().unwrap();
        }

        let mut p1_max_area = 0;
        let mut p2_max_area = 0;

        for i in 0..num_input_lines {
            for j in i+2..num_input_lines {
                let dx = x[i] - x[j];
                let dy = y[i] - y[j];
                let area = (dx.abs() + 1) * (dy.abs() + 1);
                p1_max_area = p1_max_area.max(area);

                if area > p2_max_area && is_valid_p2_rectangle(&x, &y, i, j) {
                    p2_max_area = p2_max_area.max(area);
                }
            }
        }

        p1_result += p1_max_area;
        p2_result += p2_max_area;
    }
    println!("Time per run: {:?}", start_time.elapsed() / RUNS as u32);
    println!("Part 1: {}, Part 2: {}", p1_result / RUNS, p2_result / RUNS);
}
