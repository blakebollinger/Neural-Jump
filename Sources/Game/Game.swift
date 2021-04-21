//
//  File Name: Game.swift
//  Project: Neural Jump
//  By: Blake Bollinger
//

/*

 Handles all game processing and timing, including object generation, cloud generation, and ending the game

*/

import Foundation
import SpriteKit

public class Game {
    
	public static var interval: Double = 0.5
	public static var cloudCount = 0
    public static var obstacleCount = 0
    public static var canGenerateObstacle: Bool = true
	public static var canGenerateCloud: Bool = true
    public static var stepCounter = 0
	public static var score = 0
	public static var isRunning: Bool = false
	public static var highScore: Int = 0
	public static var stepsSincePlane: Int = 0
	
	
	/// Starts the game and the game's timer
	public static func startGame() {

		
		isRunning = true
		
        /// Begins a timer to handle the speed of the game
        _ = Timer.scheduledTimer(withTimeInterval: Game.interval, repeats: false) { timer in
            self.stepGame()
        }
    }
	
	
	/// Handles all object generation for the game, including randomizing what type of obstacle is generated.
	static func handleObstacleGeneration() {
		
		// Ensures obstacles arent generated on top of each other
		if !canGenerateObstacle {
			
			canGenerateObstacle = true
			
		} else {
		
			// Randomizes what obstacle is generated
			if Int.random(in: 1...3) == 2 {
				
				// Generates the obstacle
				obstacleCount += 1
				
				canGenerateObstacle = false
				
			}
			
		}
		
	}
	
	/// Handles all cloud generation for the game
	static func handleClouds() {
		
		// Ensures clouds arent generated on top of each other
		if !canGenerateCloud {
			
			canGenerateCloud = true
			
		} else {
		
			// Randomizes if a cloud is generated
			if Int.random(in: 1...8) == 1 {
				
				// Generates a cloud
				cloudCount += 1
								
				canGenerateCloud = false
				
			}
			
		}
		
	}
    
    /// Moves the game forward one step
    static func stepGame() {
                
		// If the game is still running, obstacles will be genrated and the timer will be reset
		if isRunning {
			
			handleObstacleGeneration()
			
			handleClouds()
			
			stepCounter += 1
			
			/// Set a timer for the next game step
			_ = Timer.scheduledTimer(withTimeInterval: Game.interval, repeats: false) { timer in
				self.stepGame()
			}
		}
    }
	
	/// Handles stopping the game when all players are dead or a new mode is selected
	public static func stopGame() {
		
		// Turns off the boolean for if the game is running
		isRunning = false
		
		// Updates the high score if necessary
		if score > highScore {
			
			highScore = score
			
		}
		
		// Resets variables
		interval = 0.5
		cloudCount = 0
		obstacleCount = 0
		canGenerateObstacle = true
		canGenerateCloud = true
		stepCounter = 0
		score = 0
		
	}
    
    
}
