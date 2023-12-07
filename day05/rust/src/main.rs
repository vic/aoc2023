
mod range_intersection;
use range_intersection::range_intesersect;

use std::{
    fs::File,
    io::{self, Read},
};

use nom::{
    self,
    bytes::complete::tag,
    character::complete::digit1,
    combinator::map_res,
    multi::{many1, separated_list1},
};

fn main() -> Result<(), io::Error> {
    let input = read_file_contents("../input.txt")?;
    let almanac = parse_input(&input).expect("Failed parsing input").1;
    println!("Hello, world! {:?}", almanac.lowest_location());
    Ok(())
}

#[derive(Debug, PartialEq)]
struct AocRange {
    dest_range_start: usize,
    orig_range_start: usize,
    range_length: usize,
}

trait Apply {
    fn apply(&self, orig: usize) -> Option<usize>;
}

impl Apply for AocRange {
    fn apply(&self, orig: usize) -> Option<usize> {
        let range = self.orig_range_start..(self.orig_range_start + self.range_length);
        if range.contains(&orig) {
            let offset = orig - self.orig_range_start;
            Some(self.dest_range_start + offset)
        } else {
            None
        }
    }
}

impl Apply for Vec<AocRange> {
    fn apply(&self, orig: usize) -> Option<usize> {
        for range in self {
            if let Some(result) = range.apply(orig) {
                return Some(result);
            }
        }
        Some(orig) // Not mapped by any range, so return the original value
    }
}

#[derive(Debug, PartialEq)]
struct Almanac {
    seeds: Vec<usize>,
    seed_to_soil: Vec<AocRange>,
    soil_to_fertilizer: Vec<AocRange>,
    fertilizer_to_water: Vec<AocRange>,
    water_to_light: Vec<AocRange>,
    light_to_temperature: Vec<AocRange>,
    temperature_to_humidity: Vec<AocRange>,
    humidity_to_location: Vec<AocRange>,
}

impl Apply for Almanac {
    fn apply(&self, orig: usize) -> Option<usize> {
        let mut result = orig;
        // TODO: This is ugly. Can we do better? How to do function composition in Rust?
        result = self.seed_to_soil.apply(result)?;
        result = self.soil_to_fertilizer.apply(result)?;
        result = self.fertilizer_to_water.apply(result)?;
        result = self.water_to_light.apply(result)?;
        result = self.light_to_temperature.apply(result)?;
        result = self.temperature_to_humidity.apply(result)?;
        result = self.humidity_to_location.apply(result)?;
        Some(result)
    }
}

impl Almanac {
    fn seeds_locations(&self) -> Vec<usize> {
        self.seeds
            .iter()
            .map(|seed| self.apply(*seed).unwrap())
            .collect()
    }

    fn lowest_location(&self) -> usize {
        *self.seeds_locations().iter().min().unwrap()
    }
}

fn parse_input(input: &str) -> nom::IResult<&str, Almanac> {
    let (input, seeds) = parse_seeds(input)?;
    let (input, _) = tag("\n")(input)?;
    let (input, seed_to_soil) = parse_map("seed-to-soil", input)?;
    let (input, _) = tag("\n")(input)?;
    let (input, soil_to_fertilizer) = parse_map("soil-to-fertilizer", input)?;
    let (input, _) = tag("\n")(input)?;
    let (input, fertilizer_to_water) = parse_map("fertilizer-to-water", input)?;
    let (input, _) = tag("\n")(input)?;
    let (input, water_to_light) = parse_map("water-to-light", input)?;
    let (input, _) = tag("\n")(input)?;
    let (input, light_to_temperature) = parse_map("light-to-temperature", input)?;
    let (input, _) = tag("\n")(input)?;
    let (input, temperature_to_humidity) = parse_map("temperature-to-humidity", input)?;
    let (input, _) = tag("\n")(input)?;
    let (input, humidity_to_location) = parse_map("humidity-to-location", input)?;
    Ok((
        input,
        Almanac {
            seeds,
            seed_to_soil,
            soil_to_fertilizer,
            fertilizer_to_water,
            water_to_light,
            light_to_temperature,
            temperature_to_humidity,
            humidity_to_location,
        },
    ))
}

fn parse_seeds(input: &str) -> nom::IResult<&str, Vec<usize>> {
    let (input, _) = tag("seeds: ")(input)?;
    let n = map_res(digit1, str::parse::<usize>);
    let (input, seeds) = separated_list1(tag(" "), n)(input)?;
    let (input, _) = tag("\n")(input)?;
    Ok((input, seeds))
}

fn parse_map<'a>(map_name: &'a str, input: &'a str) -> nom::IResult<&'a str, Vec<AocRange>> {
    let (input, _) = tag(map_name)(input)?;
    let (input, _) = tag(" map:\n")(input)?;
    let (input, ranges) = separated_list1(tag("\n"), parse_range)(input)?;
    let (input, _) = tag("\n")(input)?;
    Ok((input, ranges))
}

fn parse_range(input: &str) -> nom::IResult<&str, AocRange> {
    let mut n = map_res(digit1, str::parse::<usize>);
    let (input, dest_range_start) = n(input)?;
    let (input, _) = many1(tag(" "))(input)?;
    let (input, orig_range_start) = n(input)?;
    let (input, _) = many1(tag(" "))(input)?;
    let (input, range_length) = n(input)?;
    Ok((
        input,
        AocRange {
            dest_range_start,
            orig_range_start,
            range_length,
        },
    ))
}

fn read_file_contents(path: &str) -> Result<String, io::Error> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}
