# Genetic mass-spring systems
> String evolution based on user-controlled Genetic Algorithms.  
> Complete source: https://github.com/miccio-dk/genetic_mass_spring

## Concept
This application allows the user to manipulate the parameters of a physical model using a process similar to natural selection.

The user is initially presented with a random population of mass-spring models; using the mouse, they can play each model and verity its characteristics.
Clicking on a model causes a new generation to be spawned, based on the selection.
The new models will be sorted from the least to the most mutated, providing a wide range of variations.

The navigation of different models across multiple generations constitutes the performance.

## Motivation
Genetic Algorithms are a class of bio-inspired procedures for optimization and search tasks, and have been employed in a vast number of fields such as mechanical, robotical, and molecular design.
They are succesful in quickly finding local optima for a given problem.

This project aims at exploring the application of Genetic Algorithms for the design of mass-spring physical models, where there's no established optimal solution, other than the performer's taste.

## Physical model
The physical model in this project is not fixed and varies based on random mutations and user interaction.
It is based on the model found in the `MetalPlate1D` example distributed along with `miPhysics`.
The specifics of each specimen are contained in its _Genome_, which represents the blueprints for the physical model instantiation.

Models are played by applying a force to one of the nodes.
The node to excite is selected by the user whereas the node where the sound is picked up is hard-coded to #5.

### Genome
The genome for this project comprises a list of _Osc1D_ objects (nodes) and their connections.
Each connection is modeled as a spring-dampener combination.
The maxumum number of nodes and connectins is predetermined and can be changed in the code.

A single _Osc1D_ object along with its connections and physical properties is knows as a Gene.
Overall, each gene comprises the following parameters:
- node name
- node position (X, Y)
- node mass
- node constants K, Z
- connections constants K, Z
- list of connected nodes

### Parameters
The following parameters are accessible during the performance:
- Currently playing model: hoving with mouse
- Population parent: clicking with mouse
- Excitation point: horizontal mouse offset 
- Friction: up and down arrow keys

Many more parameters can be configured in the code, such as:
- Size of population
- Amount and probability of mutations
- Initial population distribution

## Results
Due to unfamiliarity with Java language, the application does not entirely fulfil its desired purpose; nevertheless, some interesting results are produced.
In particular, models seem to produce increasingly more complex sounds as new generations are spawned, due to the increased amount of variations.
However, this may sometimes cause models to act erratically, outputting NaN values and disappearing from the screen.
These latter issues are currently still under investigation.

Despite difficulties in adopting the language, _miPhysics_ proves to be a flexible software framework, which can be easily interfaced with external libraries to visualize and reproduce the models.

## Outline
Along with the due reliability improvements and bug-fixing, the following new features could be implemented in the application, and will be subject for further research and development:
- Different loss functions: letting the user choose between selection-driven evolution and arbitrary loss functions would allow for different interaction paradigms. An example alternative loss function could be the similarity with a given input instrument sample (in order to generate models capable of reproducing similar sounds)
- Parameters visualizations: models could be rendered with their geometrical characteristics mirroring the physical ones, making it easier to visualize differences in physical parameters across a population
