export { containsRun, }
import { simulate } from './base.mjs'
import { fileURLToPath } from 'node:url'

// Returns the first run of size n found, false otherwise.
// If aces are high and low, then wrapping is allowed (K,A,2 counts as a run)
function containsRun(hand, n, acesLow = true, acesHigh = true) {
	for (var i = 0; i < hand.length; i++) {
		var sequence = run(hand, n, [hand[i]], acesLow, acesHigh)
		if (sequence) return sequence
	}
	return false
}

// Recursive function that builds up a sequence of cards from hand,
// returning the sequence if it's n size or false if it can't reach it.
function run(hand, n, sequence, acesLow, acesHigh) {
	if (sequence.length >= n) return sequence
	var nextRank = nextRankInSequence(sequence.at(-1), acesLow, acesHigh)
	var nextCard = containsRank(hand, nextRank)
	if (nextCard) {
		sequence.push(nextCard)
		return run(hand, n, sequence, acesLow, acesHigh)
	} else {
		false
	}
}

function containsRank(hand, rank) {
	if (!rank) return false
	for (var card of hand)
		if (card.rank === rank)
			return card
	return false
}

// returns the rank of the next card in sequence
function nextRankInSequence(card, acesLow, acesHigh) {
	switch (card.rank) {
		case 10: return 'J'
		case 'J': return 'Q'
		case 'Q': return 'K'
		case 'K': return acesHigh ? 'A' : null
		case 'A': return acesLow ? 2 : null
		default: return card.rank+1
	}
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
	for (var h = 5; h <= 7; h++) {
		console.log(h, 'card hand:')
		for (var r = 3; r <= 7; r++) {
			if (r > h) continue;

			process.stdout.write('Run of '+r+' (Aces low): ')
			simulate(hand => containsRun(hand, r, true, false), h)

			// process.stdout.write('Aces high only: ')
			// simulate(hand => containsRun(hand, r, false, true), h)

			// process.stdout.write('Aces high and low: ')
			// simulate(hand => containsRun(hand, r, true, true), h)

		}
		console.log()
	}
}
