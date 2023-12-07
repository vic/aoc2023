use std::ops::Range;


pub fn range_intesersect<T>(m: &Range<T>, n: &Range<T>) -> Option<Range<T>> where
    T: Ord + Copy {
    let (a, b, x, y) = (m.start, m.end, n.start, n.end);
    if b <= x || y <= a {
        None
    } else {
        Some(std::cmp::max(a, x)..std::cmp::min(b, y))
    }
}


#[cfg(test)]
mod tests {
    use super::range_intesersect;
    #[test]
    fn intersect_conjoint() {
        let a = 1..10;
        let b = 5..7;
        let c = range_intesersect(&a, &b);
        assert_eq!(c.unwrap(), 5..7);
        let c = range_intesersect(&b, &a);
        assert_eq!(c.unwrap(), 5..7);
    }

    #[test]
    fn intersect_outer_left() {
        let a = 1..10;
        let b = 0..2;
        let c = range_intesersect(&a, &b);
        assert_eq!(c.unwrap(), 1..2);
        let c = range_intesersect(&b, &a);
        assert_eq!(c.unwrap(), 1..2);
    }

    #[test]
    fn intersect_outer_right() {
        let a = 1..10;
        let b = 9..11;
        let c = range_intesersect(&a, &b);
        assert_eq!(c.unwrap(), 9..10);
        let c = range_intesersect(&b, &a);
        assert_eq!(c.unwrap(), 9..10);
    }

    #[test]
    fn intersect_disjoint_left() {
        let a = 5..10;
        let b = 0..5;
        let c = range_intesersect(&a, &b);
        assert_eq!(c, None);
        let c = range_intesersect(&b, &a);
        assert_eq!(c, None);
    }

    #[test]
    fn intersect_disjoint_right() {
        let a = 5..10;
        let b = 10..15;
        let c = range_intesersect(&a, &b);
        assert_eq!(c, None);
        let c = range_intesersect(&b, &a);
        assert_eq!(c, None);
    }
}