//
//  File Name: Individual.swift
//  Project: Neural Jump
//  By: Blake Bollinger
//

/*
 
 This class allows players in the game to be converted to "Individuals". This conversion takes place because the individual class provides easier access to the genes (neural network weights). This streamlines the process of passing on genes.

*/

import Foundation

public class Individual: Comparable {
	
	// Initializes the size of an individual's genes
	public static var SIZE: Int = 120
	
	// Initializes an array of genes
	public var genes: [Float] = []
	
	// Initializes a fitness value
	private var fitnessValue: Int = 0

	/// Initializes an individual with all 0 for genes
	init() {
		
		for _ in Range(0...119) {
			
			genes.append(0.0)
			
		}
		
	}
	
	// MARK: Get Fitness Value
	
	/// A function to access an individuals fitness values
	///
	/// - Returns: The fitness value of the individual
	public func getFitnessValue() -> Int {
		return fitnessValue
	}
	
	// MARK: Set Fitness Value
	
	/// A function to set the individual's fitness value
	///
	/// - Parameter val: the fitness value to set
	public func setFitnessValue(val: Int) {
		self.fitnessValue = val
	}

	// MARK: Get Gene
	
	/// A function to return a specific gene index
	///
	/// - Parameter index: the index to return
	/// - Returns: the value of that gene index
	public func getGene(index: Int) -> Float{
		return genes[index]
	}

	// MARK: Set All Genes
	
	/// A function to set an individuals entire gene array
	///
	/// - Parameter val: the array of genes to put into the individual
	public func setGene(val: [[Float]]) {
		
		genes = []
		
		for i in val {
			
			for j in i {
				
				genes.append(j)
				
			}
			
		}
		
	}
	
	// MARK: Set Specific Genes
	
	/// A function to set specific genes in the individual
	///
	/// - Parameter index: the index at which to set the value
	/// - Parameter val: the value to set at the index
	public func setGene(index: Int, val: Float) {
		
		genes[index] = val
		
	}
	
	// MARK: Get All Genes
	
	/// A function to return all genes of an individual
	///
	/// - Returns: A 2D array of the individuals genes
	public func getGenes() -> [[Float]] {
		
		// Packages the genes into a 2D array for the neual network
		var out: [[Float]] = [[]]
		
		var build: [Float] = []
		
		out.append(contentsOf: [])

		out.append(contentsOf: [])

		out.append(contentsOf: [])

		for i in Range(0...99) {
			
			build.append(genes[i])
			
		}
		
		out.append(build)
		
		build = []
		
		for i in Range(100...119) {
			
			build.append(genes[i])
		
		}
		
		out.append(build)
		
		return out
				
	}

	// MARK: Mutate
	
	/// A function to handle a mutaiton in an individual's genes
	public func mutate() {
		
		// Ensure the individual has genes, and if so, mutate a random gene
		if genes.count > 0 {
			
			let index = Int.random(in: 0...genes.count-1)
			self.setGene(index: index, val: self.getGene(index: index)*(Float.random(in: 0.75...1.25)))
			
		} else {
			
			print("Error in mutation")
			
		}
	}

	// MARK: Comparable
	
	// Implements a comparable interface to get the most fit individual
	
	public static func < (lhs: Individual, rhs: Individual) -> Bool {
		
		return lhs.fitnessValue < rhs.fitnessValue
		
	}
	
	public static func == (lhs: Individual, rhs: Individual) -> Bool {
		
		return lhs.fitnessValue == rhs.fitnessValue
		
	}
	
}
