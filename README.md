# Genetic strings
> Simulating instruments using genetic algorithms

## Description
This project allows the _evolution_ of a mass-spring physical model based on user interaction

## Instruction
### Setup
- Download and install **Processing**
- Install [miPhysics_Processing](https://github.com/mi-creative/miPhysics_Processing) and relative dependencies
- Open the `genetic_mass_interaction` sketch
### Usage
- Hover a specimen to hear it being played (horizontal offset determines point of excitation)
- Click on a specimen to generate a new population based on it 
- Rinse and repeat!
- The following hyperparameters can be adjusted from the main file:
  - `NUM_SPECIMEN`: population size
  - `genome[i].evolve(a, x, c)`: `a` is the probability of controlled mutation, `b` is the probability of completely random mutatiom/gene replacement, `c` is the mutation amount
- The size of the genome (number of nodes and connections) can be set in the phyGenome class definition dile


## Known limitation
Depending on how the model parameters mutate:
- Output might become unstable and clip 
- Models might be pushed out of the screen or overlap

## TODO
- implement alternative cost function
- implement crossover
- write report
- better visualization (show masses)
- keep parameter stable