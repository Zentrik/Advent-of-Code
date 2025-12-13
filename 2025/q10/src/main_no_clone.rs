use itertools::Itertools;

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
            let mut target_joltage: Vec<u8> = Vec::new();
            for button in parts {
                if button.as_bytes()[0] as char == '{' {
                    for joltage_str in button[1..button.len() - 1].split(',') {
                        let joltage: u8 = joltage_str.parse().unwrap();
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

            // SLOW - probably need to iterate strictly in set length order
            // // Iterate over power set of buttons in length order so first match is smallest
            // let num_buttons = buttons_bitmask.len();
            // let mut min_buttons_toggled = (num_buttons + 1) as u32;
            // for powerset_bitmask in 1..(1u16 << num_buttons) {
            //     let set_len = powerset_bitmask.count_ones();
            //     if set_len >= min_buttons_toggled {
            //         continue;
            //     }

            //     let mut indicator_lights = 0u16;
            //     for button in 0..num_buttons {
            //         let button_toggled = (powerset_bitmask & (1 << button)) != 0;
            //         if button_toggled {
            //             indicator_lights ^= buttons_bitmask[button];
            //         }
            //     }
            //     // let combined_bitmask = (0..num_buttons)
            //     //     .filter(|&i| (powerset_bitmask & (1 << i)) != 0)
            //     //     .map(|i| buttons_bitmask[i])
            //     //     .reduce(|acc, x| acc ^ x)
            //     //     .unwrap();
            //     if indicator_lights == target_lights_bitmask {
            //         min_buttons_toggled = std::cmp::min(min_buttons_toggled, set_len);
            //     }
            // }
            // p1_result += min_buttons_toggled;

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
                    p1_result += set_len;
                    break;
                }
            }

            let mut toggled_joltage: Vec<u8> = vec![0; target_joltage.len()];

            // Assume 255 upper bound to prevent infinite loops
            for buttons_toggled in 0..=255 {
                println!("Trying {} toggles", buttons_toggled);
                let result = solve_p2(
                    &buttons_bitmask,
                    &target_joltage,
                    &mut toggled_joltage,
                    buttons_toggled,
                );
                if result {
                    p2_result += buttons_toggled as usize;
                    break;
                }
            }
            println!("Done line");
        }
    }
    println!("Time per run: {:?}", start_time.elapsed() / RUNS as u32);
    println!("Part 1: {}, Part 2: {}", p1_result / RUNS, p2_result / RUNS);
}


fn solve_p2(
    buttons_bitmask: &[u16],
    target_joltage: &Vec<u8>,
    toggled_joltage: &mut Vec<u8>,
    toggles_remaining: u8,
) -> bool {
    if toggles_remaining == 0 {
        return toggled_joltage == target_joltage;
    }
    if buttons_bitmask.len() == 0 {
        return false;
    }
    let toggled_button = buttons_bitmask[0];

    let old_toggled_joltage = toggled_joltage.clone();
    for toggles in 0..=toggles_remaining {
        let mut success = true;

        if toggles > 0 {
            for i in 0..std::mem::size_of_val(&toggled_button)*8 {
                if (toggled_button & (1 << i)) != 0 {
                    toggled_joltage[i as usize] += 1;
                    if toggled_joltage[i as usize] > target_joltage[i as usize] {
                        success = false;
                    }
                }
            }
        }

        if !success {
            for i in 0..std::mem::size_of_val(&toggled_button)*8 {
                if (toggled_button & (1 << i)) != 0 {
                    toggled_joltage[i as usize] -= toggles;
                }
            }
            debug_assert_eq!(toggled_joltage, &old_toggled_joltage);
            return false;
        }
        let success = solve_p2(
            &buttons_bitmask[1..],
            target_joltage,
            toggled_joltage,
            toggles_remaining - toggles,
        );
        if success {
            // Don't need to reset toggled_joltage as we are returning true
            return success;
        }
    }

    // Reset toggled_joltage
    for i in 0..std::mem::size_of_val(&toggled_button)*8 {
        if (toggled_button & (1 << i)) != 0 {
            toggled_joltage[i as usize] -= toggles_remaining;
        }
    }
    debug_assert_eq!(toggled_joltage, &old_toggled_joltage);

    return false;
}