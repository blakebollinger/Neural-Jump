//
//  File Name: Population.swift
//  Project: Neural Jump
//  By: Blake Bollinger
//

/*

 This class provides the functionality for aggregating individuals as a population. Furthermore, these individuals can then be used to create a new generation.

*/

import Foundation

public class Population {
	
	// MARK: Initialize
	
	// Initialize the number of times an individual is added to the population
	static let ELITISM_K: Int = 5
	
	// Initialize population size
	static let POP_SIZE: Int = 95 + ELITISM_K

	// Initialize mutation rate
	static let MUTATION_RATE: Double = 0.05
	
	// Initialize crossover rate
	static let CROSSOVER_RATE:Double = 0.7

	public var m_population: Array<Individual> = []
	public var totalFitness: Double = 0.0

	/// Default init function
	init() {

		
	}
	
	// MARK: Add Member
	
	/// A function for adding individuals to a population
	///
	/// - Parameter genes: the genes of the individual to be added
	/// - Parameter fitness: the fitness of the indivudal to be added
	public func addMember(genes: [[Float]], fitness: Int) {
		
		// Intializes an individual with the given genes
		let member = Individual()
		member.setGene(val: genes)
		member.setFitnessValue(val: fitness)
		m_population.append(member)
		
	}

	// MARK: Set Population
	
	/// A function for overwriting the current population
	///
	/// - Parameter newPop: An array of individuals to be written to the new population
	public func setPopulation(newPop: Array<Individual>) {
		self.m_population = newPop
	}

	// MARK: Get Population
	
	/// A function for accessing the current population
	///
	/// - Returns: an array of individuals in the current population
	public func getPopulation() -> Array<Individual> {
		return self.m_population
	}

	// MARK: Evaluate
	
	/// A function for evaluating the fitness of a population
	///
	/// - Returns: A double representing the total population fitness
	public func evaluate() -> Double {
		
		self.totalFitness = 0.0
		
		// Adds the fitness of each individual to the total fitness
		for i in Range(0...self.m_population.count-1) {
		
			self.totalFitness += Double(m_population[i].getFitnessValue())
	
		}
		
		return self.totalFitness

	}

	// MARK: Weighted Selection
	
	/// A function for the weighted selection of individuals in a population
	/// Individuals are weighted accoring to their fitness values
	///
	/// - Returns: An indiviudal selected based on the weighted selection algorithm
	public func weightedSelection() -> Individual {
		
		var weightedArray: Array<Individual> = []
		
		// Adds individuals to a selection array based on their fitness values
		for i in m_population {
			
			for _ in (0...i.getFitnessValue()) {
				
				weightedArray.append(i)
				
			}
			
		}
		
		// If all individuals have fitness of 0, select a random one
		if weightedArray.count == 0 {
			
			return m_population.randomElement()!
			
		}
		
		return weightedArray.randomElement()!
	}

	// MARK: Find Best Individual
	
	/// A function for finding the best individual in a population
	///
	/// - Returns: The most fit individual in a population
	public func findBestIndividual() -> Individual{
		
		if self.evaluate() == 0 {
						
			return m_population.randomElement()!
			
		}
		
		return m_population.max()!        // maximization
	}

	// MARK: Crossover
	
	/// A function that mimics the process of genetic crossover in nature
	///
	/// - Parameter indiv1: The first parent to be used in the crossover
	/// - Parameter indiv2: The second parent to be used in the crossover
	public static func crossover(indiv1: Individual, indiv2: Individual) -> Array<Individual> {
		
		// Create an array of the two children that will be created
		var newIndiv: Array<Individual> = []
		newIndiv.append(Individual())
		newIndiv.append(Individual())
		
		// Select a random point in the gene array.
		// The gene data before this point will be from the first parent.
		// The data at and after this point will come from the second parent.
		let randPoint: Int = Int.random(in: Range(1...Individual.SIZE-1))
				
		// Populare the children with the DNA from the first parent up to the generated point
		for i in Range(0...randPoint) {
			newIndiv[0].setGene(index: i, val: indiv1.getGene(index: i))
			newIndiv[1].setGene(index: i, val: indiv2.getGene(index: i))
		}
		
		// Populate the children with the gene data from the second parent at and after the generated point
		for i in Range(randPoint-1...Individual.SIZE-1) {
			newIndiv[0].setGene(index: i, val: indiv2.getGene(index: i))
			newIndiv[1].setGene(index: i, val: indiv1.getGene(index: i))
		}
		
		return newIndiv
	
	}
}
