//
//  File Name: NeuralNet.swift
//  Project: Neural Jump
//  By: Blake Bollinger
//

/*

This is the backbone of the entire project
 
Processes all training and infrences for the neural network

*/

import Foundation
import Accelerate

public final class NeuralNet {

    public enum Error: Swift.Error {
        case initialization(String)
        case weights(String)
        case inference(String)
        case train(String)
    }
    public let numLayers: Int
    public let layerNodeCounts: [Int]
    public let batchSize: Int
    public var hiddenActivation: ActivationFunction.Hidden
    public var outputActivation: ActivationFunction.Output
    public var learningRate: Float {
        didSet {
            adjustedLearningRate = ((1 - momentumFactor) * learningRate) / Float(batchSize)
        }
    }
    public var momentumFactor: Float {
        didSet {
            adjustedLearningRate = ((1 - momentumFactor) * learningRate) / Float(batchSize)
        }
    }
    fileprivate var cache: Cache
    fileprivate var adjustedLearningRate: Float
    
    public init(structure: Structure, weights: [[Float]]? = nil) throws {
        // Initialize basic properties
        self.numLayers = structure.numLayers
        self.layerNodeCounts = structure.layerNodeCounts
        self.batchSize = structure.batchSize
        self.hiddenActivation = structure.hiddenActivation
        self.outputActivation = structure.outputActivation
        self.learningRate = structure.learningRate
        self.momentumFactor = structure.momentumFactor
        self.adjustedLearningRate = ((1 - structure.momentumFactor) * structure.learningRate) / Float(structure.batchSize)
        
        // Initialize computed properties and caches
        self.cache = Cache(structure: structure)
        
        // Set initial weights, or randomize if none are provided
        if let weights = weights {
            try self.setWeights(weights)
        } else {
            randomizeWeights()
        }
    }
    
}



public extension NeuralNet {
    
    /// Resets the network with the given weights (i.e. from a pre-trained network).
    /// This change may safely be performed at any time.
    func setWeights(_ weights: [[Float]]) throws {
        
        // Reset all weights in the network
        cache.layerWeights = weights
    }
    
    /// Returns an array of the network's current weights for each layer.
    func allWeights() -> [[Float]] {
        return cache.layerWeights
    }
    
    /// Randomizes all of the network's weights.
    fileprivate func randomizeWeights() {
        // Randomize weights for each layer independently
        // Note: Output weights and all biases do not need initialization; they remain 0 until training begins
        for layer in 1..<(numLayers - 1) {
            // Randomize weights
            for weight in 0..<cache.layerWeightCounts[layer] {
                cache.layerWeights[layer][weight] = randomWeight(fanIn: layerNodeCounts[layer - 1], fanOut: layerNodeCounts[layer + 1])
            }
        }
    }
    
    /// Generates a single random weight.
    private func randomWeight(fanIn: Int, fanOut: Int) -> Float {
        // sqrt(6 / (fanOut + fanIn))
        let range = sqrt(6 / Float(fanIn + fanOut))
        let rangeInt = UInt32(2_000_000_000 * range)
        let randomFloat = (Float(arc4random_uniform(rangeInt)) - Float(rangeInt / 2)) / 1_000_000_000
        
        switch hiddenActivation {
        default:
            return randomFloat
        }
    }
    
}

public extension NeuralNet {
    
    
    /// Minibatch inference: propagates the given batch of inputs through the neural network, returning the network's output.
    ///
    /// - Parameter inputs: A batch of inputs sets. The number of input sets must exactly match net network's `batchSize`.
    /// - Returns: The full batch of outputs corresponding to the provided inputs.
    /// - Throws: An error if the number of batches or inputs per set are incorrect.
    @discardableResult
    func infer(_ inputs: [[Float]]) throws -> [[Float]] {
        // Make sure the correct number of batches was provided
        guard inputs.count == batchSize else {
            throw Error.inference("Incnumber of input sets provided: \(inputs.count). Expected: \(batchSize). The number of input sets must exactly match the network's batch size.")
        }
        
        // Serialize full batch of inputs into a single array
        // Note: This is *much* faster than using `inputs.reduce([], +)`
        var input: [Float] = [Float](repeatElement(0, count: batchSize * layerNodeCounts[0]))
        for a in 0..<batchSize {
            for i in 0..<layerNodeCounts[0] {
                let idx = a * layerNodeCounts[0] + i
                input[idx] = inputs[a][i]
            }
        }
        
        // Perform inference
        let outputs = try infer(input)
        
        // Split result (full batch) into individual rows
        let outputLength = layerNodeCounts[numLayers - 1]
        let count = outputLength * batchSize
        return stride(from: 0, to: count, by: outputLength).map {
            Array(outputs[$0..<min($0 + outputLength, count)])
        }
    }
    
    /// Inference: propagates the given inputs through the neural network, returning the network's output.
    /// This method should be used for performing inference on a single set of inputs,
    /// or for minibatch inference where all inputs have been serialized into a single array.
    /// Regardless, the number of sets must exactly match the `batchSize` defined in the network's `Structure`.
    ///
    /// - Parameter inputs: A single set of inputs, or a minibatch serialized into a single array.
    /// - Returns: The network's output after applying the given inputs.
    ///            The number of output sets will equal the `batchSize` defined in the network's `Structure`.
    /// - Throws: An error if an incorrect number of inputs is provided.
    /// - IMPORTANT: The number of inputs provided must exactly match the network's number of inputs (defined in its `Structure`).
    @discardableResult
    func infer(_ inputs: [Float]) throws -> [Float] {
        // Ensure that the correct number of inputs is given
        guard inputs.count == layerNodeCounts[0] * batchSize else {
            throw Error.inference("Incorrect number of input sets provided: \(inputs.count). Expected: \(batchSize). The number of input sets must exactly match the network's batch size.")
        }
        
        // Cache the inputs
        cache.layerOutputs[0] = inputs
        
        // Loop through each layer in the network and calculate the layer's output.
        // Note: We don't apply any weights or activation to the first (input) layer.
        for layer in 1..<numLayers {
            // Calculate the weighted, summed input for this layer
            // (Stored temporarily in its output cache)
            vDSP_mmul(cache.layerOutputs[layer - 1], 1,
                      cache.layerWeights[layer], 1,
                      &cache.layerOutputs[layer][0], 1,
                      vDSP_Length(batchSize),
                      vDSP_Length(layerNodeCounts[layer]),
                      vDSP_Length(layerNodeCounts[layer - 1]))
            
            // Add each node's bias to its own input, for every item in the batch
            // TODO: Figure out how to vectorize this operation
            // Here, we add the layer's bias (row vector) to each row in the input matrix.
            for b in 0..<batchSize {
                for n in 0..<layerNodeCounts[layer] {
                    let idx = b * layerNodeCounts[layer] + n
                    cache.layerOutputs[layer][idx] += cache.layerBiases[layer][n]
                }
            }
            
            // Apply the activation function to each node in this layer
            if layer == numLayers - 1 {
                // Output layer; special activation
                outputActivation.computeActivation(cache.layerOutputs[layer], result: &cache.layerOutputs[layer],
                                                   rows: batchSize, cols: layerNodeCounts[layer])
            } else {
                // Hidden layer
                hiddenActivation.computeActivation(cache.layerOutputs[layer], result: &cache.layerOutputs[layer],
                                                   rows: batchSize, cols: layerNodeCounts[layer])
            }
        }
        
        // Return the final layer's output
        return cache.layerOutputs[numLayers - 1]
    }
}

fileprivate extension NeuralNet {
    
    /// Sums the rows of the given matrix into a single column vector.
    func sumRows(of matrix: [Float], into destination: inout [Float], rows: Int, columns: Int) {
        matrix.withUnsafeBufferPointer { matrix in
            destination.withUnsafeMutableBufferPointer { destination in
                for row in 0..<rows {
                    vDSP_sve(matrix.baseAddress! + row * columns, 1,
                             destination.baseAddress! + row, vDSP_Length(columns))
                }
            }
        }
    }
    
}
