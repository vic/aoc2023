package main

import (
	"bufio"
	"cmp"
	"errors"
	"log"
	"os"
	"slices"
	"strconv"
	"strings"
	"sync"
)

const cards = "23456789TJQKA"

type HandType uint8

const (
	// From lowest to highest rank of hand
	HighCard     HandType = 1
	OnePair               = 2
	TwoPair               = 3
	ThreeOfAKind          = 4
	FullHouse             = 5
	FourOfAKind           = 6
	FiveOfAKind           = 7
)

type HandGroup struct {
	handType  HandType
	slice     *[]*Hand
	inputFeed chan *Hand      // This channel takes a pointer so we can signal the end with nil
	maxRank   chan int        // a channel to announce this group max rank when fully sorted
	wg        *sync.WaitGroup // a waitgroup for when the slice is fully sorted
	prev      *HandGroup      // a pointer to the previous priority group
	winning   int             // sum of winnings of all hands in this group
}

type Hand struct {
	handType HandType
	cards    string
	bid      int
	//cardsScore int // computed from the value of each card on this hand, used for sorting
	rank    int // position of this hand in the game
	winning int // computed by rank * bid
}

func cardsScore(cards string) int {
	rank := 0
	l := len(cards)
	for i, c := range cards {
		cIdx := strings.Index(cards, string(c)) + 1
		rank += (l - i) * cIdx
	}
	return rank
}

func findHandType(cards string) (HandType, error) {
	m := map[rune]int{}
	for _, c := range cards {
		m[c]++
	}
	l := len(m)
	switch l {
	case 1:
		return FiveOfAKind, nil
	case 5:
		return HighCard, nil
	case 4:
		return OnePair, nil
	case 3:
		for _, v := range m {
			if v == 3 {
				return ThreeOfAKind, nil
			}
		}
		return TwoPair, nil
	case 2:
		for _, v := range m {
			if v == 4 {
				return FourOfAKind, nil
			}
		}
		return FullHouse, nil
	}
	return 0, errors.New("Invalid hand")
}

func cmpCard(a, b string) int {
	return cmp.Compare(strings.Index(cards, a), strings.Index(cards, b))
}

func cmpHand(a, b *Hand) int {
	c := cmp.Compare(a.handType, b.handType)
	if c == 0 {
		// c = cmp.Compare(a.cardsScore, b.cardsScore)
		for i := 0; i < len(a.cards); i++ {
			c = cmpCard(a.cards[i:i+1], b.cards[i:i+1])
			if c != 0 {
				break
			}
		}
	}
	return c
}

func cmpHandReverse(a, b *Hand) int {
	return cmpHand(a, b) * -1
}

func readFile(filename string, wgReader *sync.WaitGroup, handGroups *[]*HandGroup) error {
	wgReader.Add(1)
	defer wgReader.Done()

	file, err := os.Open(filename)
	defer file.Close()
	if err != nil {
		log.Fatal(err)
		return err
	}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if len(line) > 0 {
			wgReader.Add(1)
			go (func() {
				defer wgReader.Done()
				hand, err := parseHand(line)
				if err != nil {
					log.Fatal(err)
				}
				(*handGroups)[hand.handType-1].inputFeed <- hand
			})()
		}
	}

	return nil
}

func parseHand(line string) (*Hand, error) {
	s := strings.SplitN(line, " ", 2)
	cards := s[0]
	bid, err := strconv.Atoi(s[1])
	if err != nil {
		return nil, err
	}
	handType, err := findHandType(s[0])
	if err != nil {
		return nil, err
	}
	hand := Hand{cards: cards, bid: bid, handType: handType}
	return &hand, nil
}

func handKeeper(group *HandGroup) {
	group.wg.Add(1)
	hands := make([]*Hand, 0, 1024)
	for {
		select {
		case hand := <-group.inputFeed:
			if hand != nil {
				hands = append(hands, hand)
				continue
			}
			defer group.wg.Done() // signal that this group is done computing its winning
			// log.Println("Group", group.handType, " got poison pill")

			// sort asynchronously
			sorted := make(chan interface{}, 1)
			go func() {
				// Order is from highest value to lowest
				slices.SortFunc(hands, cmpHandReverse)
				group.slice = &hands
				//log.Println("Group", group.handType, "sorted ", len(hands), "hands")
				sorted <- nil
			}()

			prevRank := 0
			if group.prev != nil {
				// println("Waiting for prev group", group.prev.handType)
				prevRank = <-group.prev.maxRank
			}

			l := len(hands)
			maxRank := prevRank + l
			// log.Println("Group", group.handType, "maxRank", maxRank, "len", l)

			// announce the max rank of this group so other can compute their winning concurrently
			group.maxRank <- maxRank
			close(group.maxRank)

			<-sorted // wait for the sorting to be done
			totalWinning := 0
			for i, hand := range hands {
				hand.rank = prevRank + (l - i)
				hand.winning = hand.rank * hand.bid
				totalWinning += hand.winning
				// log.Println("On group ", group.handType, "hand", hand)
			}
			group.winning = totalWinning

			// log.Println("Group", group.handType, "done")
			return // exit this goroutine
		default: // non-blocking
			// hmmm, but it looks like anyways I'm always waiting for something from inputFeed
			// so maybe I could just block this goroutine.
		}
	}
}

func initHandGroups() *[]*HandGroup {
	handGroups := make([]*HandGroup, 7)
	for i := 0; i < 7; i++ {
		handGroups[i] = &HandGroup{
			handType:  HandType(i + 1),
			inputFeed: make(chan *Hand, 1024),
			wg:        &sync.WaitGroup{},
			maxRank:   make(chan int, 1),
		}
		if i > 0 {
			handGroups[i].prev = handGroups[i-1]
		}
		go handKeeper(handGroups[i])
	}
	return &handGroups
}

func main() {
	handGroups := initHandGroups()

	filename := os.Args[1]
	wgReader := &sync.WaitGroup{}
	err := readFile(filename, wgReader, handGroups)
	if (err) != nil {
		log.Fatal(err)
		os.Exit(1)
	}

	wgReader.Wait()
	for _, group := range *handGroups {
		group.inputFeed <- nil // Signal no more inputs and let each group compute async
		close(group.inputFeed)
	}

	// wait for each group, starting with the lowest priority
	total := 0
	for _, group := range *handGroups {
		group.wg.Wait()
		total += group.winning
	}

	log.Println("Total Winning", total)
}
