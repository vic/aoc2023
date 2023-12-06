package aoc.day01

import scala.io.Source
import scala.util.chaining.*
import scala.annotation.tailrec

object Main {

  def main(args: Array[String]): Unit =
    Source.fromFile(args.head)
      .getLines().to(Iterable)
      .flatMap(skipBlanks)
      .pipe(sum)
      .pipe(println)

  def skipBlanks: String => Iterable[String] =
    case line if line.isBlank() => Nil
    case line => List(line)

  def sum(input: Iterable[String]): Int = 
    input.map: line =>
       val nums = firstDigit(line) ++ lastDigit(line)
       nums.mkString.toInt
    .reduce(_ + _)

  val names = List("one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
  def firstDigit(line: String): Option[Int] = digit(line, names)
  def lastDigit(line: String): Option[Int] = digit(line.reverse, names.map(_.reverse))

  def digit(line: String, names: List[String]): Option[Int] = {
    val digitIdx: List[(Int, Int)] = 
        line.indexWhere(_.isDigit) match 
            case -1 => Nil
            case idx => List(idx -> line.charAt(idx).asDigit)

    val namesIdx: List[(Int, Int)] = names.zipWithIndex.flatMap: (name, nameIdx) =>
      line.indexOf(name) match
        case -1 => None
        case idx => Some(idx -> (nameIdx + 1))

    (digitIdx ++ namesIdx).sortBy(_._1).headOption.map(_._2)
  }

}
