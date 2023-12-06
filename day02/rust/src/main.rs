use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::digit1,
    combinator::{map, map_res},
    multi::separated_list1,
    IResult,
};

fn main() {
    let filename = std::env::args().nth(1).expect("no filename given");
    let content = std::fs::read_to_string(&filename).expect("could not read file");
    let games = content
        .split("\n")
        .filter_map(|line| {
            if line.is_empty() {
                None
            } else {
                parse_game(line).ok().map(|(_, game)| game)
            }
        })
        .collect::<Vec<_>>();

    let restriction = BallSet(vec![
        (12, Color::Red),
        (13, Color::Green),
        (14, Color::Blue),
    ]);

    let mut possible_games: u32 = 0;
    let mut power_sum: u32 = 0;
    for game in games {
        if game.is_possible(&restriction) {
            possible_games += game.id;
        }
        power_sum += game.min_product();
    }
    println!("Possible games: {}", possible_games);
    println!("Power sum: {}", power_sum);
}

fn parse_game(input: &str) -> IResult<&str, Game> {
    let (input, _) = tag("Game ")(input)?;
    let (input, game_num) = map_res(digit1, str::parse::<u32>)(input)?;
    let (input, _) = tag(": ")(input)?;
    let (input, ballsets) = parse_ballsets(input)?;
    Ok((
        input,
        Game {
            id: game_num,
            ballsets,
        },
    ))
}

#[derive(Debug, PartialEq)]
enum Color {
    Red,
    Green,
    Blue,
}

#[derive(Debug, PartialEq)]
struct Game {
    id: u32,
    ballsets: BallSets,
}

impl Game {
    fn is_possible(&self, bs: &BallSet) -> bool {
        for a in self.ballsets.0.iter() {
            if !a.is_possible(bs) {
                return false;
            }
        }
        true
    }

    fn min_product(&self) -> u32 {
        let mut prod = 1;
        for bs in self.min_ballset().0.iter() {
            prod *= bs.0;
        }
        println!(
            "Game {} product {}\nBallsets: {:?}\nMinset: {:?}\n",
            self.id,
            prod,
            self.ballsets,
            self.min_ballset()
        );
        return prod;
    }

    fn min_ballset(&self) -> BallSet {
        let mut max_red: Option<u32> = None;
        let mut max_green: Option<u32> = None;
        let mut max_blue: Option<u32> = None;

        for bs in self.ballsets.0.iter() {
            if bs.has_color(&Color::Red) {
                let sum = bs.sum_color(&Color::Red);
                if max_red.is_none() || sum > max_red.unwrap() {
                    max_red = Some(sum);
                }
            }
            if bs.has_color(&Color::Green) {
                let sum = bs.sum_color(&Color::Green);
                if max_green.is_none() || sum > max_green.unwrap() {
                    max_green = Some(sum);
                }
            }
            if bs.has_color(&Color::Blue) {
                let sum = bs.sum_color(&Color::Blue);
                if max_blue.is_none() || sum > max_blue.unwrap() {
                    max_blue = Some(sum);
                }
            }
        }

        let balls = max_red
            .map(|n| (n, Color::Red))
            .into_iter()
            .chain(max_green.map(|n| (n, Color::Green)))
            .chain(max_blue.map(|n| (n, Color::Blue)))
            .collect::<Vec<_>>()
            .into();

        BallSet(balls)
    }
}

#[derive(Debug, PartialEq)]
struct BallSets(Vec<BallSet>);

#[derive(Debug, PartialEq)]
struct BallSet(Vec<(u32, Color)>);

impl BallSet {
    fn has_color(&self, color: &Color) -> bool {
        self.0.iter().any(|(_, c)| c == color)
    }

    fn sum_color(&self, color: &Color) -> u32 {
        self.0
            .iter()
            .filter(|(_, c)| c == color)
            .map(|(n, _)| n)
            .sum()
    }

    fn total(&self) -> u32 {
        self.0.iter().map(|(n, _)| n).sum()
    }

    fn is_possible(&self, having: &BallSet) -> bool {
        self.total() <= having.total()
            && self.sum_color(&Color::Red) <= having.sum_color(&Color::Red)
            && self.sum_color(&Color::Green) <= having.sum_color(&Color::Green)
            && self.sum_color(&Color::Blue) <= having.sum_color(&Color::Blue)
    }
}

fn parse_ballsets(input: &str) -> IResult<&str, BallSets> {
    map(separated_list1(tag("; "), parse_ballset), BallSets)(input)
}

fn parse_ballset(input: &str) -> IResult<&str, BallSet> {
    map(separated_list1(tag(", "), parse_ball), BallSet)(input)
}

fn parse_ball(input: &str) -> IResult<&str, (u32, Color)> {
    let red = map(tag("red"), |_| Color::Red);
    let green = map(tag("green"), |_| Color::Green);
    let blue = map(tag("blue"), |_| Color::Blue);

    let (input, ball_num) = map_res(digit1, str::parse::<u32>)(input)?;
    let (input, _) = tag(" ")(input)?;
    let (input, color) = alt((red, green, blue))(input)?;

    Ok((input, (ball_num, color)))
}
