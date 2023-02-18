export { createDeck, shuffle, deal, simulate }
import { format } from 'node:util'

function createDeck() {
	const deck = []
	const ranks = ['A', 'J', 'Q', 'K']
	for (var i = 2; i <= 10; i++) ranks.push(i)
	const suits = ['c', 's', 'h', 'd']
	for (var rank of ranks)
		for (var suit of suits)
			deck.push({ rank, suit })
	return deck
}

// shuffles deck in place
function shuffle(deck) {
	// This moves random elements in the array to the end of the array
	// https://stackoverflow.com/a/2450976
	// https://bost.ocks.org/mike/shuffle/
	var m = deck.length, t, i
	// while there remain elements to shuffle...
	while (m) {
		// pick a remaining element...
		i = Math.floor(Math.random() * m--)
		// and swap it with the current element
		t = deck[m]
		deck[m] = deck[i]
		deck[i] = t
	}
	return deck
}

// removes and returns n elements from deck
function deal(deck, n) {
	return deck.splice(0, n)
}

// Calls fn(hand) n times with handSize random cards and counts the number
// of truthy returns. A message with the results is returned.
function simulate(fn, n = 1000000, handSize = 5) {
	var successCount = 0
	for (var i = 0; i < n; i++) {
		const hand = deal(shuffle(createDeck()), handSize)
		if (fn(hand)) successCount++
	}
	return format('success/total (%d/%d) = %d',
		successCount, n, successCount/n)
}
