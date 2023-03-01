export { createDeck, shuffle, deal, simulate }
import { format } from 'node:util'

function createDeck(ranks = ['A','J','Q','K']) {
	const deck = []
	for (var i = 2; i <= 10; i++) ranks.push(i)
	const suits = ['c', 's', 'h', 'd']
	for (var rank of ranks)
		for (var suit of suits)
			deck.push({ rank, suit })
	return deck
}

// a deck with 2 red kings and 38 other random cards that aren't kings
function create40() {
	const pool = shuffle(createDeck(['A','J','Q']))
	const deck = deal(pool, 38)
	deck.push({rank:'K', suit:'h'})
	deck.push({rank:'K', suit:'d'})
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
// of truthy returns, then prints the results.
function simulate(fn, handSize = 5, n = 1000000) {
	var successCount = 0
	for (var i = 0; i < n; i++) {
		const hand = deal(shuffle(create40()), handSize)
		if (fn(hand)) successCount++
	}
	console.log(format('%d/%d = %d', successCount, n, successCount/n))
}
