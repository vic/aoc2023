use std::fs;

fn main() {
    use std::env;

    let input = env::args()
        .nth(1)
        .map(|f| fs::read_to_string(f).unwrap())
        .unwrap();

    let lines = input
        .split("\n")
        .filter(|l| !l.is_empty())
        .collect::<Vec<_>>();

    day1(lines)
}

fn day1(lines: Vec<&str>) {
    let total = lines
        .iter()
        .map(|line| {
            let fd = first_digit(line);
            let ld = last_digit(line);
            println!("GOT <{:?}, {:?}> for {}", fd, ld, line);
            options_to_num(fd, ld)
        })
        .fold(0, |a, i| a + i);
    println!("Total : {}", total);
}

const NAMES: [&str; 9] = [
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
];

fn options_to_num(a: Option<char>, b: Option<char>) -> u32 {
    match (a, b) {
        (Some(x), Some(y)) => char_to_dec(x) * 10 + char_to_dec(y),
        (Some(x), None) => char_to_dec(x),
        (None, Some(y)) => char_to_dec(y),
        _ => 0,
    }
}

fn char_to_dec(c: char) -> u32 {
    println!("Char '{}'", c);
    (c as u32) - ('0' as u32)
}

fn first_digit(line: &str) -> Option<char> {
    digit(&line.to_string(), &NAMES.map(|n| n.to_string()))
}

fn last_digit(line: &str) -> Option<char> {
    digit(
        &line.chars().rev().collect::<String>(),
        &NAMES.map(|n| n.to_string().chars().rev().collect::<String>()),
    )
}

fn first_name(line: &String, names: &[String; 9]) -> Option<char> {
    names.iter().enumerate().find_map(|(idx, word)| {
        if line.starts_with(word) {
            let num = (idx as u32) + 1 + ('0' as u32);
            char::from_u32(num.try_into().unwrap())
        } else {
            None
        }
    })
}

fn digit(line: &String, names: &[String; 9]) -> Option<char> {
    line.chars()
        .next()
        .filter(|t| t.is_digit(10))
        .or(first_name(line, names))
        .or(if line.is_empty() {
            None
        } else {
            let rest = line.chars().skip(1).collect::<String>();
            digit(&rest, names)
        })
}
