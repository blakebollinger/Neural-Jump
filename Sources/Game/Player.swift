//
//  File Name: Player.swift
//  Project: Neural Jump
//  By: Blake Bollinger
//

/*

 A subclass of SKShapeNode, this class provides the basis for all player generation. Essentially, this allows a neural network to be paired with every player in the game.

*/

import Foundation
import SpriteKit

// Defines screen width/height
let screenHeight: Double = 768.0
let screenWidth: Double = 1024.0

public class Player: SKShapeNode {
	
	// Initializes neural net structure
	public var structure: NeuralNet.Structure = try! NeuralNet.Structure(nodes: [10, 10, 2], hiddenActivation: .rectifiedLinear, outputActivation: .softmax, batchSize: 1, learningRate: 0.9, momentum: 0.9)
	
	// Initializes neural net
	public var nn: NeuralNet

	// Initializes a bool representing if a player has a neural net
	public static var neuralNet = true
	
	/// Intiializes a player with the given radius
	init(circleOfRadius: Int) {
		
		// Assigns the structure to the neural net
		nn = try! NeuralNet(structure: structure)
		
		// Defines all aspects of the SKShapeNode to be displayed
		super.init()
		let diameter = circleOfRadius * 2
		self.path = CGPath(ellipseIn: CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter)), transform: nil)
		self.fillColor = SKColor(displayP3Red: CGFloat(Double.random(in: 0...255)/255), green: CGFloat(Double.random(in: 0...255)/255), blue: CGFloat(Double.random(in: 0...255)/255), alpha: 0.75)
		self.strokeColor = SKColor.black
		self.zPosition = 0.8
		self.alpha = 1.0
		self.physicsBody = SKPhysicsBody(circleOfRadius: 12)
		self.physicsBody?.usesPreciseCollisionDetection = true
		self.physicsBody?.collisionBitMask = 0b0010
		self.physicsBody?.categoryBitMask = 0b0001
		self.position = CGPoint(x: -((screenWidth/2)-100), y: -(screenHeight/2)+55)
				
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Converts neural net output to usable game input
	public func computeMove(player: SKNode) -> Bool{
		
		let arr = try! nn.infer(Features.genOutput(player: self as SKShapeNode))
				
		if arr.firstIndex(of: arr.max()!) == 0 {
			
			return true
			
		} else {
			
			return false
			
		}
		
	}
	
}
