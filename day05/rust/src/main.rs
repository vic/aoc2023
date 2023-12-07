mod range_intersection;
use range_intersection::range_intersect;

use std::{
    env::args,
    fs::File,
    io::{self, Read},
    ops::Range,
};

use nom::{
    self,
    bytes::complete::tag,
    character::complete::digit1,
    combinator::map_res,
    multi::{many1, separated_list1},
};

fn main() -> Result<(), io::Error> {
    let filename = args().nth(1).expect("No input file provided");
    let input = read_file_contents(&filename)?;
    let almanac = parse_input(&input).expect("Failed parsing input").1;
    println!("Lowest location {:?}", almanac.lowest_location());
    Ok(())
}

//
//
//              .-""""-.
//             /        \
//            /_        _\
//           // \      / \\
//           |\__\    /__/|
//            \    ||    /
//             \        /
//              \  __  /
//               '.__.'
//
//
//
#[derive(Debug, PartialEq, Clone)]
struct AocRange {
    orig: Range<usize>,
    dest: Range<usize>,
}

impl AocRange {
    fn width(r: &Range<usize>) -> usize {
        r.end - r.start
    }

    fn new(orig: Range<usize>, dest: Range<usize>) -> AocRange {
        assert_eq!(AocRange::width(&orig), AocRange::width(&dest));
        AocRange {
            orig: orig,
            dest: dest,
        }
    }

    fn slice_input(&self, input: &Range<usize>) -> Option<AocRange> {
        range_intersect(&self.orig, input).map(|o| {
            let offset = o.start - self.orig.start;
            let start = self.dest.start + offset;
            let end = self.dest.start + offset + AocRange::width(&o);
            AocRange::new(o, start..end)
        })
    }

    fn compose(&self, other: &AocRange) -> Option<AocRange> {
        other.slice_input(&self.dest).map(|other| {
            let offset = other.orig.start - self.dest.start;
            let width = AocRange::width(&other.orig);
            let start = self.orig.start + offset;
            let end = self.orig.start + offset + width;
            AocRange::new(start..end, other.dest)
        })
    }

    fn fill_gaps(ranges: Vec<AocRange>) -> Vec<AocRange> {
        let mut result = ranges;
        result.sort_by(|a, b| a.orig.start.cmp(&b.orig.start));
        // fill in the gaps
        let mut result = result.iter().fold(Vec::<AocRange>::new(), |acc, b| {
            let mut res = acc;
            match res.last() {
                None if b.orig.start > 0 => {
                    let gap: AocRange = AocRange::new(0..b.orig.start, 0..b.orig.start);
                    res.push(gap);
                    res.push(b.to_owned());
                }
                None => res.push(b.to_owned()),
                Some(a) if a.orig.end == b.orig.start => res.push(b.to_owned()),
                Some(a) => {
                    let gap = AocRange::new(a.orig.end..b.orig.start, a.orig.end..b.orig.start);
                    res.push(gap);
                    res.push(b.to_owned());
                }
            }
            res
        });
        match result.last() {
            None => (),
            Some(a) => {
                let gap = AocRange::new(a.orig.end..usize::MAX, a.orig.end..usize::MAX);
                result.push(gap);
            }
        }
        result
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

fn connect(ax: &Vec<AocRange>, bx: &Vec<AocRange>) -> Vec<AocRange> {
    ax.iter()
        .flat_map(|a| bx.iter().flat_map(|b| a.compose(b)))
        .collect::<Vec<_>>()
}

impl Almanac {
    fn connect_all(&self) -> Vec<AocRange> {
        let result = connect(&self.temperature_to_humidity, &self.humidity_to_location);
        let result = connect(&self.light_to_temperature, &result);
        let result = connect(&self.water_to_light, &result);
        let result = connect(&self.fertilizer_to_water, &result);
        let result = connect(&self.soil_to_fertilizer, &result);
        let result = connect(&self.seed_to_soil, &result);
        result
    }

    fn seeds_ranges(&self) -> Vec<Range<usize>> {
        self.seeds
            .as_slice()
            .chunks(2)
            .map(|pair| pair[0]..(pair[0] + pair[1]))
            .collect()
    }

    fn restrict(seeds: Vec<Range<usize>>, apps: Vec<AocRange>) -> Vec<AocRange> {
        seeds
            .iter()
            .flat_map(|s| apps.iter().flat_map(|a| a.slice_input(s)))
            .collect::<Vec<_>>()
    }

    fn lowest_location(&self) -> usize {
        let ranges = Almanac::restrict(self.seeds_ranges(), self.connect_all());
        let min_location = ranges
            .iter()
            .min_by_key(|r| r.dest.start)
            .unwrap()
            .dest
            .start;
        min_location
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
    Ok((input, AocRange::fill_gaps(ranges)))
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
        AocRange::new(
            orig_range_start..(orig_range_start + range_length),
            dest_range_start..(dest_range_start + range_length),
        ),
    ))
}

fn read_file_contents(path: &str) -> Result<String, io::Error> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}
