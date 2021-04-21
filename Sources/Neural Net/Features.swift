//
//  File Name: Features.swift
//  Project: Neural Jump
//  By: Blake Bollinger
//

/*

 Provides an interface between the neural networks and the game. This file takes in features from the game and puts them into a format readable by the neural network.

*/

import Foundation
import SpriteKit

// Define a null sprite node
let null = SKSpriteNode()

public class Features {
	
	// MARK: Gen Output
	
	/// A function to turn the current state of the game into features for the neural network of `player`
	///
	/// - Parameter player: the player from which some data will be calculated
	/// - Returns: An array of features for the neural net
	public static func genOutput(player: SKShapeNode) -> Array<Float> {
		
		// An array that will be built off of
		var out: Array<Float> = []
		
		// Initialize the obstacles as null if they do not exist
		var firstObstacle: SKSpriteNode = null
		var secondObstacle: SKSpriteNode = null
		var thirdObstacle: SKSpriteNode = null
		
		// If obstacles exist, add overwrite the above values
		switch MainScene.obstacles.count {
			case 1:
				firstObstacle = MainScene.obstacles[0]
				break
			case 2:
				firstObstacle = MainScene.obstacles[0]
				secondObstacle = MainScene.obstacles[1]
				break
			case 3:
				firstObstacle = MainScene.obstacles[0]
				secondObstacle = MainScene.obstacles[1]
				thirdObstacle = MainScene.obstacles[2]
			default:
				break
		}
		
		// Append the distance from the player to the first obstacle
		out.append(calcDistanceBetween(nodeA: firstObstacle, nodeB: player))
		
		// Append the lower bound of the height of the first obstacle
		out.append(calcLowerBound(node: firstObstacle))
		
		// Append the upper bound of the height of the first obstacle
		out.append(calcUpperBound(node: firstObstacle))
		
		// Append the distance from the first obstacle to the second obstacle
		out.append(calcDistanceBetween(nodeA: firstObstacle, nodeB: secondObstacle))
		
		// Append the lower bound of the height of the second obstacle
		out.append(calcUpperBound(node: secondObstacle))
		
		// Append the upper bound of the height of the second obstacle
		out.append(calcLowerBound(node: secondObstacle))
		
		// Append the distance from the second obstacle to the third obstacle
		out.append(calcDistanceBetween(nodeA: secondObstacle, nodeB: thirdObstacle))
		
		// Append the lower bound of the height of the third obstacle
		out.append(calcUpperBound(node: thirdObstacle))
		
		// Append the upper bound of the height of the third obstacle
		out.append(calcLowerBound(node: thirdObstacle))
		
		// Append the current height of the player
		out.append(Float(player.position.y)/1024)
		
		return out
		
	}
	
	// MARK: Calc Distance Between
	
	/// A function for calculating the distance between nodes
	///
	/// - Parameter nodeA: the first node to calculate distance from
	/// - Parameter nodeB: the second node to calculate distance from
	/// - Returns: a float representing the distance between the obstacles
	static func calcDistanceBetween(nodeA: SKNode, nodeB: SKNode) -> Float {
		
		// If either node doesnt exist, return 0
		if (nodeA == null || nodeB == null) {
			
			return 0
			
		}
		
		// return the calculated distance
		return abs(calcLeftBound(node: nodeB)-calcRightBound(node: nodeA))/1024
		
	}
	
	// MARK: Calc Left Bound
	
	/// A function that calculates the left bound of a given node
	///
	/// - Parameter node: the node to calculate the left bound of
	/// - Returns: A float representation of the left bound's position on the screen
	static func calcLeftBound(node: SKNode) -> Float {
		
		// If the node doesnt exist return 0
		if node == null {
			
			return 0
			
		}
		
		// Return the calculated left bound
		return Float(node.position.x-(node.frame.size.width/2))
		
	}
	
	// MARK: Calc Right Bound
	
	/// A function that calculates the right bound of a given node
	///
	/// - Parameter node: the node to calculate the right bound of
	/// - Returns: A float representation of the right bound's position on the screen
	static func calcRightBound(node: SKNode) -> Float {
		
		// If the node doesnt exist return 0
		if node == null {
			
			return 0
			
		}
		
		// Return the calculated right bound
		return Float(node.position.x+(node.frame.size.width/2))

	}
	
	// MARK: Calc Lower Bound
	
	/// A function that calculates the lower bound of a given node
	///
	/// - Parameter node: the node to calculate the lower bound of
	/// - Returns: A float representation of the lower bound's position on the screen
	static func calcLowerBound(node: SKNode) -> Float {
		
		// If the node doesnt exist return 0
		if node == null {
			
			return 0
			
		}
		
		// Return the calculated lower bound
		return Float(node.position.y-(node.frame.size.height/2))/1024
		
	}
	
	// MARK: Calc Upper Bound
	
	/// A function that calculates the upper bound of a given node
	///
	/// - Parameter node: the node to calculate the upper bound of
	/// - Returns: A float representation of the upper bound's position on the screen
	static func calcUpperBound(node: SKNode) -> Float {
		
		// If the node doesnt exist return 0
		if node == null {
			
			return 0
			
		}
		
		// Return the calculated upper bound
		return Float(node.position.y+(node.frame.size.height/2))/1024

		
	}
	
}
