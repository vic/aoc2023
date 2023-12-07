package aoc.day04

import scala.util.chaining.*
object Main:

  def main(args: Array[String]): Unit = {
    val cards =
      io.Source
        .fromFile(args(0))
        .getLines
        .filterNot(_.isBlank())
        .map(Card.parse)
        .toList

    lazy val part1 = cards
      .map(_.points)
      .sum
      .pipe(debug("Part1 Points: " + _))

    lazy val part2 =
      cards.pipe(processCards).pipe(debug("Number of cards: " + _))

    part1
    part2
  }

  def processCards(cards: List[Card]): Int =
    val updated = cards.foldLeft(initCount(cards))(updateCount)
    updated.values.sum

  opaque type CardId = Int
  def initCount(cards: List[Card]): Map[CardId, Int] =
    cards.map(_.id).map(_ -> 1).toMap

  def updateCount(state: Map[CardId, Int], card: Card): Map[CardId, Int] =
    val cardCopies = state(card.id)
    card.winningCopies().foldLeft(state) { (state, id) =>
      state.updatedWith(id) {
        case None    => Some(cardCopies)
        case Some(n) => Some(n + cardCopies)
      }
    }

  def debug[A](msg: A => String)(a: A): A = { println(msg(a)); a }

  case class Card(id: CardId, winning: List[Int], having: List[Int]):
    def haveWinning: List[Int] = winning.filter(having.contains)

    def winningCopies(): List[CardId] = {
      val winningNumbers = haveWinning.size
      if (winningNumbers == 0) Nil
      else Range(id + 1, id + 1 + winningNumbers).toList
    }

    def points: Int =
      haveWinning
        .pipe(debug(x => s"Card ${id} has Winning " + x))
        .size match {
        case 0 => 0
        case n =>
          Math.pow(2, n - 1).toInt
      }

  object Card:
    val parse: String => Card = { line =>
      val colIdx = line.indexOf(':')
      val pipeIdx = line.indexOf('|')
      val id = line.substring("Card ".length, colIdx).trim().toInt
      val winning =
        line
          .substring(colIdx + 1, pipeIdx)
          .split(' ')
          .filterNot(_.isBlank())
          .map(_.trim().toInt)
          .toList
          .distinct
      val gotten =
        line
          .substring(pipeIdx + 1)
          .split(' ')
          .filterNot(_.isBlank())
          .map(_.trim().toInt)
          .toList
          .distinct
      Card(id, winning, gotten)
    }
