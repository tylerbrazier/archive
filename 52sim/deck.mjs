export { createDeck, shuffle, deal }

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
