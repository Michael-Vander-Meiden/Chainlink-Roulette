# this is a monte carlo simulation to see reserves required to avoid risk of ruin
import random

iterations = 10000000
max_bet = 1.0
initial_reserves = 1000.0

#what portion of our reserves is allowed to be bet?
allowed_bet_ratio = 1000

num_won = 0
num_lost = 0
results = []

for j in range(100):
	reserves = 1000.0
	for i in range(iterations):
		#choose a random number between 0 and our max bet
		bet_size = random.random()*reserves/allowed_bet_ratio
		
		#add bet to reserves
		reserves += bet_size
		result = random.random()*33

		#if result is a "winner", subtract from reserves
		if result < 1.0:
			reserves = reserves - (bet_size*32)

	# record result
	if reserves > initial_reserves:
		results.append(1)
	else:
		results.append(0)
print("~~~~~~~~~~~~~~~Results after {} iterations ~~~~~~~~~~~~~~~~~~~~~~".format(iterations))
print(results)
print(sum(results))






