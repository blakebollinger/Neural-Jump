//
//  File Name: MainScene.swift
//  Project: Neural Jump
//  By: Blake Bollinger
//

/*

 This is the backbone of the graphcis for the game. Also serves as a central communication point for interfacing between the game, players, and genetic algorithm

*/

import PlaygroundSupport
import SpriteKit
import UIKit
import Foundation


public class MainScene: SKScene, SKPhysicsContactDelegate {
	
    // MARK: Initialization
	// Initialies a LOT of variables each used for drawing on the screen
    let screenHeight: Double = 768.0
    let screenWidth: Double = 1024.0
    private var totalBricks: Int = 0
    private var title : SKLabelNode!
	private var score: SKLabelNode!
	private var highScore: SKLabelNode!
	private var player: SKShapeNode!
    private var ground: SKShapeNode!
    private var brick: SKSpriteNode!
    private var brickList: Array<SKSpriteNode> = []
	private var brickSplinePoints = [CGPoint(x: 0, y: 0), CGPoint(x: 40, y: 0)]
    private var building : SKSpriteNode!
	private var plane : SKSpriteNode!
    public static var obstacles: Array<SKSpriteNode> = []
	private var cloud: SKSpriteNode!
	private var cloudList: Array<SKSpriteNode> = []
	private var jumped = false
	private var frameCounter = 0
	private let playerNum = 1
	private var players: Array<Player> = []
	private var playersRemainingLabel: SKLabelNode!
	private var population: Population = Population()
	private var generation: Int = 1
	private var avgFit: Double = 0.0
	private var generationLabel: SKLabelNode!
	private var avgFitLabel: SKLabelNode!
	private var line: SKShapeNode!
	private var jumpToLabel: SKLabelNode!
	private var jumpGenLabelOne: SKLabelNode!
	private var jumpGenLabelTwo: SKLabelNode!
	private var jumpGenLabelThree: SKLabelNode!
	private var jumpGenNumberOne: SKLabelNode!
	private var jumpGenNumberTwo: SKLabelNode!
	private var jumpGenNumberThree: SKLabelNode!
	private var jumpClickBox: SKShapeNode!
	private var jumpClickBoxOne: SKShapeNode!
	private var jumpClickBoxTwo: SKShapeNode!
	private var jumpClickBoxThree: SKShapeNode!
	private var freePlayLabel: SKLabelNode!
	private var freePlayClickBoxOn: SKShapeNode!
	private var freePlayButtonLabelOn: SKLabelNode!
	private var freePlayButtonLabelOff: SKLabelNode!
	private var freePlayClickBoxOff: SKShapeNode!
	private var freePlay: Bool = false
	private var populationsGenerated: Int = 0
	
	// MARK: Move To View
	
	/// Initializes first positions of objects when the playground is started up
	public override func didMove(to view: SKView) {
        
		// Initializes background color
        self.backgroundColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
           
		// Initializes physics for the scene
        view.showsPhysics = false
        physicsWorld.contactDelegate = self
		physicsWorld.speed = 0.999
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
		// Initializes the arcade font
        let cfURL = Bundle.main.url(forResource: "Arcade", withExtension: "TTF")! as CFURL
        CTFontManagerRegisterFontsForURL(cfURL, CTFontManagerScope.process, nil)
		
		// Initializes title Node
		title = SKLabelNode(text: "Neural Jump")
        title.fontName = "ArcadeNormal"
		title.fontSize = 30
		title.zPosition = 1
		title.alpha = 1.0
		title.position = CGPoint(x: 0, y: (screenHeight/2)-75)
		addChild(title)
		
		// Initializes score Node
		score = SKLabelNode(text: "Score \(Game.score)")
		score.fontName = "ArcadeNormal"
		score.fontSize = 20
		score.zPosition = 1
		score.alpha = 1.0
		score.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
		score.position = CGPoint(x: -(screenWidth/2)+20, y: (screenHeight/2)-263)
		addChild(score)
		
		// Initializes remaining player Node
		playersRemainingLabel = SKLabelNode(text: "Players Left \(Population.POP_SIZE)")
		playersRemainingLabel.fontName = "ArcadeNormal"
		playersRemainingLabel.fontSize = 20
		playersRemainingLabel.zPosition = 1
		playersRemainingLabel.alpha = 1.0
		playersRemainingLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
		playersRemainingLabel.position = CGPoint(x: -(screenWidth/2)+20, y: (screenHeight/2)-303)
		addChild(playersRemainingLabel)
		
		// Initializes a line to seperate values pertaining to the whole population from the current game
		var lineSplinePoints = [CGPoint(x: -(screenWidth/2)+20, y: (screenHeight/2)-223), CGPoint(x:  -(screenWidth/2)+280, y: (screenHeight/2)-223)]
		let line = SKShapeNode(splinePoints: &lineSplinePoints, count: lineSplinePoints.count)
		line.lineWidth = 2
		line.strokeColor = SKColor.white
		addChild(line)
		
		// Initialize high score Node
		highScore = SKLabelNode(text: "High Score \(Game.score)")
		highScore.fontName = "ArcadeNormal"
		highScore.fontSize = 20
		highScore.zPosition = 1
		highScore.alpha = 1.0
		highScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
		highScore.position = CGPoint(x: -(screenWidth/2)+20, y: (screenHeight/2)-123)
		addChild(highScore)
				
		// Initialize generation label Node
		generationLabel = SKLabelNode(text: "Generations \(generation)")
		generationLabel.fontName = "ArcadeNormal"
		generationLabel.fontSize = 20
		generationLabel.zPosition = 1
		generationLabel.alpha = 1.0
		generationLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
		generationLabel.position = CGPoint(x: -(screenWidth/2)+20, y: (screenHeight/2)-163)
		addChild(generationLabel)
		
		// Initialize average fitness label Node
		avgFitLabel = SKLabelNode(text: "Avg Fitness \(Int(avgFit))")
		avgFitLabel.fontName = "ArcadeNormal"
		avgFitLabel.fontSize = 20
		avgFitLabel.zPosition = 1
		avgFitLabel.alpha = 1.0
		avgFitLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
		avgFitLabel.position = CGPoint(x: -(screenWidth/2)+20, y: (screenHeight/2)-203)
		addChild(avgFitLabel)
		
		// Initializes jump to label
		jumpToLabel = SKLabelNode(text: "Jump To")
		jumpToLabel.fontName = "ArcadeNormal"
		jumpToLabel.fontSize = 20
		jumpToLabel.zPosition = 1
		jumpToLabel.alpha = 1.0
		jumpToLabel.position = CGPoint(x: 25, y: 221)
		addChild(jumpToLabel)
		
		// Initializes jump to buttons
		jumpClickBox = SKShapeNode(rectOf: CGSize(width: 75, height: 75))
		jumpClickBox.fillColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
		jumpClickBox.strokeColor = SKColor.white
		jumpClickBox.lineWidth = 5
		jumpClickBox.position = CGPoint(x: -75, y: 161)
		jumpClickBoxOne = (jumpClickBox.copy() as! SKShapeNode)
		addChild(jumpClickBoxOne)
		jumpClickBoxTwo = (jumpClickBoxOne.copy() as! SKShapeNode)
		jumpClickBoxTwo.position.x = jumpClickBoxTwo.position.x+CGFloat((100))
		addChild(jumpClickBoxTwo)
		jumpClickBoxThree = (jumpClickBoxTwo.copy() as! SKShapeNode)
		jumpClickBoxThree.position.x = jumpClickBoxThree.position.x+CGFloat((100))
		addChild(jumpClickBoxThree)
		
		// Initializes labels representing which values can be jumped to
		let jumpVals = [100, 1000, 5000]
		jumpGenLabelOne = SKLabelNode(text: "Gen")
		jumpGenLabelOne.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
		jumpGenLabelOne.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
		jumpGenLabelOne.preferredMaxLayoutWidth = 70
		jumpGenLabelOne.numberOfLines = 2
		jumpGenLabelOne.lineBreakMode = NSLineBreakMode.init(rawValue: 3)!
		jumpGenLabelOne.fontName = "ArcadeNormal"
		jumpGenLabelOne.fontSize = 15
		jumpGenLabelOne.zPosition = 1
		jumpGenLabelOne.alpha = 1.0
		jumpGenLabelOne.position = CGPoint(x: -75, y: 171)
		addChild(jumpGenLabelOne)
		
		jumpGenLabelTwo = (jumpGenLabelOne.copy() as! SKLabelNode)
		jumpGenLabelTwo.position.x = jumpGenLabelOne.position.x+CGFloat(100)
		addChild(jumpGenLabelTwo)
		
		jumpGenLabelThree = (jumpGenLabelTwo.copy() as! SKLabelNode)
		jumpGenLabelThree.position.x = jumpGenLabelThree.position.x+CGFloat(100)
		addChild(jumpGenLabelThree)
		
		jumpGenNumberOne = SKLabelNode(text: "\(jumpVals[0])")
		jumpGenNumberOne.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
		jumpGenNumberOne.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
		jumpGenNumberOne.preferredMaxLayoutWidth = 70
		jumpGenNumberOne.numberOfLines = 2
		jumpGenNumberOne.lineBreakMode = NSLineBreakMode.init(rawValue: 3)!
		jumpGenNumberOne.fontName = "ArcadeNormal"
		jumpGenNumberOne.fontSize = 15
		jumpGenNumberOne.zPosition = 1
		jumpGenNumberOne.alpha = 1.0
		jumpGenNumberOne.position = CGPoint(x: -75, y: 151)
		addChild(jumpGenNumberOne)
		
		jumpGenNumberTwo = (jumpGenNumberOne.copy() as! SKLabelNode)
		jumpGenNumberTwo.text = "\(jumpVals[1])"
		jumpGenNumberTwo.position.x = jumpGenNumberTwo.position.x+CGFloat((100))
		addChild(jumpGenNumberTwo)
		
		jumpGenNumberThree = (jumpGenNumberTwo.copy() as! SKLabelNode)
		jumpGenNumberThree.text = "\(jumpVals[2])"
		jumpGenNumberThree.position.x = jumpGenNumberThree.position.x+CGFloat((100))
		addChild(jumpGenNumberThree)
		
		// Initializes free play label
		freePlayLabel = SKLabelNode(text: "Free Play")
		freePlayLabel.fontName = "ArcadeNormal"
		freePlayLabel.fontSize = 20
		freePlayLabel.zPosition = 1
		freePlayLabel.alpha = 1.0
		freePlayLabel.position = CGPoint(x: (screenWidth/2)-173, y: 221)
		addChild(freePlayLabel)
		
		// Initializes free play buttons
		freePlayClickBoxOn = SKShapeNode(rectOf: CGSize(width: 75, height: 75))
		freePlayClickBoxOn.fillColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
		freePlayClickBoxOn.strokeColor = SKColor.white
		freePlayClickBoxOn.lineWidth = 5
		freePlayClickBoxOn.position = CGPoint(x: (screenWidth/2)-223, y: 161)
		addChild(freePlayClickBoxOn)
		
		// Initializes free play button labels
		freePlayButtonLabelOn = SKLabelNode(text: "On")
		freePlayButtonLabelOn.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
		freePlayButtonLabelOn.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
		freePlayButtonLabelOn.preferredMaxLayoutWidth = 70
		freePlayButtonLabelOn.numberOfLines = 2
		freePlayButtonLabelOn.lineBreakMode = NSLineBreakMode.init(rawValue: 3)!
		freePlayButtonLabelOn.fontName = "ArcadeNormal"
		freePlayButtonLabelOn.fontSize = 15
		freePlayButtonLabelOn.zPosition = 1
		freePlayButtonLabelOn.alpha = 1.0
		freePlayButtonLabelOn.position = CGPoint(x: (screenWidth/2)-223, y: 161)
		addChild(freePlayButtonLabelOn)
		
		freePlayButtonLabelOff = freePlayButtonLabelOn.copy() as? SKLabelNode
		
		freePlayButtonLabelOff.text = "Off"
		freePlayButtonLabelOff.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
		freePlayButtonLabelOff.position.x = freePlayButtonLabelOn.position.x+CGFloat(100)
		addChild(freePlayButtonLabelOff)
		
		freePlayClickBoxOff = (freePlayClickBoxOn.copy() as! SKShapeNode)

		freePlayClickBoxOff.position.x = freePlayClickBoxOn.position.x+CGFloat(100)
		freePlayClickBoxOff.fillColor = SKColor.white
		addChild(freePlayClickBoxOff)
		
		// Initializes fist population
		initNewPop(vals: JumpToGenes.initialGenes, newGeneration: 1)

		// Initializes the ground
        var groundSplinePoints = [CGPoint(x: -(screenWidth/2), y: -(screenHeight/2)+15), CGPoint(x: screenWidth/2, y: -(screenHeight/2)+15)]
        let ground = SKShapeNode(splinePoints: &groundSplinePoints, count: groundSplinePoints.count)
        ground.lineWidth = 10
		ground.strokeColor = SKColor(displayP3Red: 94/255, green: 94/255, blue: 94/255, alpha: 1)
		ground.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -(screenWidth/2), y: -(screenHeight/2)+15), to: CGPoint(x: screenWidth/2, y: -(screenHeight/2)+15))
		ground.physicsBody?.restitution = 0.75
        ground.physicsBody?.isDynamic = false
        addChild(ground)
		
		// Initializes the brick texture
		brick = SKSpriteNode(imageNamed: "Brick.jpeg")
		brick.anchorPoint = CGPoint(x: 0.0, y: 0.0)
		brick.position = CGPoint(x: -(screenWidth/2), y: -(screenHeight/2)-480)
		brick.xScale = 0.2
		brick.yScale = 0.2
		brick.zPosition = 1
		guard let b = brick.copy() as? SKSpriteNode else { return }
		addChild(b)
		brickList.append(b)
        
		// Initializes the roof
        var roofSplinePoints = [CGPoint(x: -(screenWidth/2), y: (screenHeight/2)-350), CGPoint(x: screenWidth/2, y: (screenHeight/2)-350)]
        let roof = SKShapeNode(splinePoints: &roofSplinePoints, count: roofSplinePoints.count)
        roof.lineWidth = 5
		roof.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -(screenWidth/2), y: (screenHeight/2)-350), to: CGPoint(x: (screenWidth/2), y: (screenHeight/2)-350))
        roof.physicsBody?.restitution = 0
        roof.physicsBody?.isDynamic = false
        addChild(roof)
        
		// Initializes a generic building
        building = SKSpriteNode(imageNamed: "Building 1.png")
		building.zPosition = 0.9

		// Initializes a generic plane
		plane = SKSpriteNode(imageNamed: "Plane.png")
		plane.zPosition = 1
		plane.xScale = 0.05
		plane.yScale = 0.05
		plane.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "Plane.png"), size: CGSize(width: plane.size.width, height: plane.size.height))
		plane.physicsBody?.restitution = 0.75
		plane.physicsBody?.isDynamic = false
		
		// Initializes a generic cloud
		cloud = SKSpriteNode(imageNamed: "Plane.png")
		cloud.zPosition = 0.1
		cloud.xScale = 0.05
		cloud.yScale = 0.05
		cloud.alpha = 0.75
		cloud.anchorPoint = CGPoint(x: 0.0, y: 0.0)
		
		// Initializes the timer to check for collisions with the player
		_ = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { timer in
			self.checkCollision()
		}
		
	}
	
	@objc static public override var supportsSecureCoding: Bool {
		// SKNode conforms to NSSecureCoding, so any subclass going
		// through the decoding process must support secure coding
		get {
			return true
		}
	}
	
	// MARK: Gen Players
	
	/// Draws all `players` on the start of a game
	func genPlayers() {
						
		// Iterates through all individuals in a population and converts them to players
		for i in Range(0...Population.POP_SIZE-1) {
			
			let p = Player(circleOfRadius: 10)
			
			try! p.nn.setWeights(population.getPopulation()[i].getGenes())
			
			self.players.append(p)
			
			addChild(p)

		}
		
		// Resets the old population
		population.setPopulation(newPop: [])
		
	}
	
	//MARK: Gen Cloud
	
	
	/// Draws clouds
	func generateCloud() {
	
		guard let n = cloud.copy() as? SKSpriteNode else { return }
		
		// Randomizes what cloud is created
		switch Int.random(in: 1...3) {
		
			case 1:
				n.texture = SKTexture(imageNamed: "Cloud 1.png")
				break
			case 2:
				n.texture = SKTexture(imageNamed: "Cloud 2.png")
				break
			case 3:
				n.texture = SKTexture(imageNamed: "Cloud 3.png")
			default:
				print("Error assigning cloud texture")
			
		}
		
		// Sets position
		n.position = CGPoint(x: Int((screenWidth))/2, y: Int.random(in: -130...(30-Int(n.frame.height)-10)))
		
		// Adds the cloud to the scene
		addChild(n)
		cloudList.append(n)
		
	}
	
	//MARK: Handle Scroll
	
	/// Ensures all objects scroll with the game
	func handleScroll() {
		
		// Scrolls bricks and removes them if necessary
		for i in brickList {
			
			i.position.x = i.position.x - CGFloat(1/(Game.interval/3))
			
			if (i.position.x + i.size.width < (CGFloat(-(screenWidth/2)))) {
				
				i.removeFromParent()
				
				brickList.remove(at: 0)
								
			}
		
		}
		
		// adds a brick if necessary
		if ((brickList.last?.position.x)! + brickList.last!.size.width < (CGFloat(screenWidth/2))) {

			guard let b = brick.copy() as? SKSpriteNode else { return }

			b.position.x = CGFloat(screenWidth/2)-2
			addChild(b)
			brickList.append(b)

		}
		
		// Scrolls all obstacles and updates the score if they move off the screen
		for i in MainScene.obstacles {
			
			i.position.x = i.position.x - CGFloat(1/(Game.interval/3))
			
			if i.position.x + i.frame.width < -(CGFloat(screenWidth)/2) {
				
				i.removeFromParent()
				MainScene.obstacles.remove(at: 0)
				Game.obstacleCount -= 1
				
				if Game.isRunning {
					
					Game.score += 1
					
					if Game.score > 1 && Game.score % 10 == 0 {
						
						Game.interval -= 0.05
						
					}
					
					score.text = "Score \(Game.score)"
				
				}
				
			}
			
		}
		
		// Scrolls all clouds
		for i in cloudList {
			
			i.position.x = i.position.x - CGFloat(1/(Game.interval))
			
		}
		
	}
    
	//MARK: Jump
	
	/// Handles the jumping for a passed `player`
	/// - Parameter body: the player that will be jumping
	func jump(body: SKShapeNode) {
                
		// Zeroes out their velocity if negative
		if (body.physicsBody?.velocity.dy)! < 0 {
			body.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
		}
				
		// Applies the impulse to jump
		body.run(SKAction.applyImpulse(CGVector(dx: 0, dy: 10), duration: 0.01))

        
    }
	
    //MARK: Gen Obstacles
	
	/// Draws obstacles generated by the game
    func generateObstacle() {
		
		// Randomizes what obstacle is generated
		if Int.random(in: 1...2) == 1  && (!(MainScene.obstacles.last?.position.y ?? 0 > -130) || MainScene.obstacles.last?.position.x ?? -1 < 100) {
			
			guard let n = building.copy() as? SKSpriteNode else { return }
        
			// Randomizes the texture of buildings
			switch Int.random(in: 1...3) {
				case 1:
					n.texture = SKTexture(imageNamed: "Building 1.png")
					n.xScale = 0.25
					n.yScale = 0.25
					break
				case 2:
					n.texture = SKTexture(imageNamed: "Building 2.png")
					n.xScale = 0.2
					n.yScale = 0.15
					break
				case 3:
					n.texture = SKTexture(imageNamed: "Building 3.png")
					n.xScale = 0.2
					n.yScale = 0.1
					break
				default:
					print("Error assigning building texture")
			}
			
			// Sets the position
			n.position = CGPoint(x: CGFloat((screenWidth))/2, y: (-CGFloat(screenHeight)/2)+(n.size.height/2)+20)

			// Gives it a physics body
			n.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: n.size.width, height: n.size.height))
			n.physicsBody?.restitution = 0.75
			n.physicsBody?.isDynamic = false
			
			// Adds the building to the scene
			addChild(n)
			MainScene.obstacles.append(n)
			
		} else {
			
			// Generates a plane
			guard let n = plane.copy() as? SKSpriteNode else { return }
			
			// Sets the position
			n.position = CGPoint(x: Int((screenWidth))/2+100, y: Int.random(in: -100...(30-Int(n.size.height*0.2)-10)))
			
			// Adds the plane to the scene
			addChild(n)
			MainScene.obstacles.append(n)
			
		}
        
    }
	
	// MARK: Kill Player
	
	/// Kills the passed `player` and adds that `player` to the `population`
	///
	/// - Parameter p: The player that will be killed
	func killPlayer(p: Player) {
		
		// Adds the player's genes to the population
		population.addMember(genes: p.nn.allWeights(), fitness: Game.score)

		// Removes the player from the players array
		if players.contains(p) {
		
			players.remove(at: players.firstIndex(of: p)!)
		
		}
		
		// Updates the players remaining label
		playersRemainingLabel.text = "Players Left \(players.count)"
		
		// Removes the player from the scene
		p.removeFromParent()
		
	}
    
	// MARK: Check Collision
	
	/// Checks for collisions between `players` and `obstacle`
    func checkCollision() {
		
		// Iterates through players and checks if players have hit obstacles or are currently in contact with an obstacle
		for p in players {
		
			if p.physicsBody?.velocity.dx != 0 || p.position.x <= (CGFloat(-(screenWidth/2))+75) ||  p.position.x >= (CGFloat(-(screenWidth/2))+175) {
					
				killPlayer(p: p)
				
				break
															
			}
			
			if let contacts = p.physicsBody?.allContactedBodies() {
				
				for i in contacts {
					
					for j in MainScene.obstacles {
						
						if i == j.physicsBody {
							
							killPlayer(p: p)
														
						}
					}
				}
			}
			
		}
		
		// If the game score hits 95, the game will be terminated to prevent visual bugs
		if Game.score > 95 {
			
			for i in players {
				
				killPlayer(p: i)
				
			}
			
		}
		
		// If there are no players left in the game, restart the game
		if players.count == 0 {
						
			if freePlay {
				startHumanGame()
			} else {
				endGame()
			}
			
		}
		
    }

	// MARK: End Game
	
	/// Ends the game if all `player` have died
	func endGame() {
		
		// If the game is still running
		if Game.isRunning {
			
			// Fade iut all clouds
			for i in cloudList {
				
				i.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 2), .removeFromParent()]))
							
			}
			
			// Fade out all obstacles
			for i in MainScene.obstacles {
				
				i.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 2), .removeFromParent()]))

			}
			
			// Stop the game
			Game.stopGame()
			
			// Remove all players
			players = []
						
			// Set a timer for the next game step
			_ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
				Game.startGame()
				
				// Generates a new population based off of the current population
				self.genNewPopulation()
							
				// Draws players based off of the generated population
				self.genPlayers()
				
				// Increases the generation
				self.generation += 1
				
				// Updates all labels in the game
				self.generationLabel.text = "Generation \(self.generation)"
				
				self.playersRemainingLabel.text = "Players Left \(self.players.count)"
				
				Game.score = 0
				
				self.score.text = "Score \(Game.score)"
				
				self.highScore.text = "High Score \(Game.highScore)"
				
				let totalAvg = self.avgFit/Double(self.populationsGenerated)
				
				self.avgFitLabel.text = String(format: "Avg Fitness %.2f", totalAvg/Double(Population.POP_SIZE))
				
			}
			
		}
		
	}
	
	// MARK: Gen New Population
	
	/// Generates a new `population` based off of the current `population`
	func genNewPopulation() {
		
		// Evaluates all individuals in the current population
		let fit = population.evaluate()
		
		// Increment Populations Generated
		populationsGenerated += 1
		
		// Determines the average fitness
		avgFit += fit
		
		// Initializes variables for the generation of a population
		var count = 0

		var newPop: Array<Individual> = []
		
		var individuals: Array<Individual> = []
						
		// Places best individual into the new populatio
		for _ in Range(1...Population.ELITISM_K) {
			newPop.append(population.findBestIndividual())
			count += 1
			
		}
				
		// While the number of individuals in the new population is less than the population size
		while (count < Population.POP_SIZE) {
			
			// Selection of individuals
			individuals.append(population.weightedSelection())
			individuals.append(population.weightedSelection())
							
			// Crossover of genes
			if (Double.random(in: 0.0...1.0) < Population.CROSSOVER_RATE ) {
				individuals = Population.crossover(indiv1: individuals[0], indiv2: individuals[1])
			}
						
			// Mutation of genes
			if (Double.random(in: 0.0...1.0) < Population.MUTATION_RATE ) {
				individuals[0].mutate()
			}
			if (Double.random(in: 0.0...1.0) < Population.MUTATION_RATE ) {
				individuals[1].mutate()
			}
				
			// Add the generated individuals to the new population
			newPop.append(individuals[0])
			newPop.append(individuals[1])
			count += 2;
		}
		
		// Set the new population to the current population
		population.setPopulation(newPop: newPop)
		
	}
	
	// MARK: Init New Pop
	
	/// Loads a new `population` from the provided data
	///
	/// - Parameter vals: the gene values of the population to be added
	/// - Parameter newGeneration: the value to update the generation label to
	func initNewPop(vals: [[[Double]]], newGeneration: Int) {
		
		// Deletes old players
		players = []
				
		// Initializes a vairable to which the new gene data will be unpacked to
		var f: [Float] = []
	
		// Unpacks gene data
		for i in vals {
			
			f = []
			
			for j in i {
				
				for k in j {
					
					f.append(Float(k))
					
				}
				
			}
			
			// Packages up gene data for a the new population
			var out: [[Float]] = [[]]

			var build: [Float] = []

			out.append(contentsOf: [])

			out.append(contentsOf: [])

			out.append(contentsOf: [])

			for k in Range(0...99) {

				build.append(f[k])

			}

			out.append(build)

			build = []

			for k in Range(100...119) {

				build.append(f[k])

			}

			out.append(build)

			// Adds players until the population size is hit
			if players.count < 5 {

				let p = Player(circleOfRadius: 10)

				self.players.append(p)

				try! p.nn.setWeights(out)

				addChild(p)
				
			}
			
		}
		
		for i in players {
			
			killPlayer(p: i)
			
		}
					
		genNewPopulation()
		
		populationsGenerated -= 1
		
		genPlayers()
		
		playersRemainingLabel.text = "Players Left \(players.count)"
		
		// Updates the genration
		generation = newGeneration
		
		// Updates the generation label
		generationLabel.text = "Generation \(generation)"
		
	}
	
	// MARK: Start Human Game
	
	/// Begins a human game
	func startHumanGame() {
		
		// If the game is running, stop it
		if Game.isRunning {
			
			Game.isRunning = false
			
			// Remove all players
			if players.count > 0 {
				
				for i in players {
					
					i.removeFromParent()
					
				}
	
			}
			
			// Remove all clouds
			for i in cloudList {
				
				i.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 2), .removeFromParent()]))
							
			}
			
			// Remove all obstacles
			for i in MainScene.obstacles {
				
				i.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 2), .removeFromParent()]))

			}
			
			// Officially stop the game
			Game.stopGame()
			
			players = []
									
			// Set a timer for the next game step
			_ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
				
				// Generate a human player
				let p = Player(circleOfRadius: 10)

				// Add the player to the players list
				self.players.append(p)
				
				// Add the player to the scene
				self.addChild(p)
				
				// Update labels in game
				self.score.text = "Score \(Game.score)"
				
				self.playersRemainingLabel.text = "Players Left 1"
				
				// Start the game
				Game.startGame()
								
			}
		
		}
	
	}
	
	// MARK: Start Computer Game
	
	/// Starts a computer game based on the given gene data
	///
	/// - Parameter newPopVals: the data from which to generate a population
	/// - Parameter newGeneration: the value to update the generation labe to
	func startComputerGame(newPopVals: [[[Double]]], newGeneration: Int) {
		
		// Stop the game if running
		if Game.isRunning {
			
			Game.isRunning = false
			
			// Remove all players from the scene
			if players.count > 0 {
				
				for i in players {
					
					i.removeFromParent()
					
				}
	
			}
			
			// Remove all clouds
			for i in cloudList {
				
				i.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 2), .removeFromParent()]))
							
			}
			
			// Remove all obstacles
			for i in MainScene.obstacles {
				
				i.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 2), .removeFromParent()]))

			}
			
			// Officially stop the game
			Game.stopGame()
									
			// Set a timer for the next game step
			_ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
				
				// Erase all players
				self.players = []
				
				// Erase all obstacles
				MainScene.obstacles = []
				
				// Update the labels in the scene
				self.score.text = "Score \(Game.score)"
				
				self.playersRemainingLabel.text = "Players Left \(Population.POP_SIZE)"
				
				// Init the new population
				self.initNewPop(vals: newPopVals, newGeneration: newGeneration)
				
				// Start the game
				Game.startGame()
				
			}
			
		}
		
	}
	
	// MARK: Touch Down
	
	/// This function handles what do if buttons are clicked
	///
	/// - Parameter atPoint: the point at which the schreen was touched
	func touchDown(atPoint pos : CGPoint) {
        
		// If the first jump to button is clicked
		if jumpClickBoxOne.frame.contains(pos) {
			
			if !freePlay {
				
				// Start a computer game with the given data
				startComputerGame(newPopVals: JumpToGenes.oneHundredGenes, newGeneration: 100)
				
			}
			
			// Update button texture to show click
			jumpClickBoxOne.fillColor = SKColor.white
			jumpGenNumberOne.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			jumpGenLabelOne.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			
		} else if jumpClickBoxTwo.frame.contains(pos) {
			
			if !freePlay {
					
				// Start a computer game with the given data
				startComputerGame(newPopVals: JumpToGenes.oneThousandGenes, newGeneration: 1000)
				
			}
			
			// Update button texture to show click
			jumpClickBoxTwo.fillColor = SKColor.white
			jumpGenNumberTwo.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			jumpGenLabelTwo.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			
		} else if jumpClickBoxThree.frame.contains(pos) {
			
			if !freePlay {
				
				// Start a computer game with the given data
				startComputerGame(newPopVals: JumpToGenes.fiveThousandGenes, newGeneration: 5000)
				
			}
						
			// Update button texture to show click
			jumpClickBoxThree.fillColor = SKColor.white
			jumpGenNumberThree.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			jumpGenLabelThree.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			
		} else if freePlayClickBoxOn.frame.contains(pos) {
			
			// Update button texture to show click
			freePlayClickBoxOn.fillColor = SKColor.white
			freePlayButtonLabelOn.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			
			// Stop the game and start a human game
			if Game.isRunning && !freePlay {
			
				freePlay = true
				
				startHumanGame()
				
			}
			
		} else if freePlayClickBoxOff.frame.contains(pos) {
			
			// Update button texture to show click
			freePlayClickBoxOff.fillColor = SKColor.white
			freePlayButtonLabelOff.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)

			// Stop the game and start a computer game
			if Game.isRunning && freePlay {
				
				freePlay = false
				
				startComputerGame(newPopVals: JumpToGenes.initialGenes, newGeneration: 1)
				
			}
			
		} else if freePlay && Game.isRunning {
			
			jump(body: players[0])
			
		}
        
	}
	
	// MARKK: Touch Up
	
	/// Handles what happens when touches are released
	///
	/// - Parameter atPoint: the point at which the touch was released
	func touchUp(atPoint pos : CGPoint) {
		
		// Updates all button textures to normal (unpressed) texture
		jumpClickBoxOne.fillColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
		jumpClickBoxTwo.fillColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
		jumpClickBoxThree.fillColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
		
		jumpGenLabelOne.fontColor = SKColor.white
		jumpGenLabelTwo.fontColor = SKColor.white
		jumpGenLabelThree.fontColor = SKColor.white
		
		jumpGenNumberOne.fontColor = SKColor.white
		jumpGenNumberTwo.fontColor = SKColor.white
		jumpGenNumberThree.fontColor = SKColor.white
		
		// Update the freeplay toggle buttons to show correct texture
		if freePlay {
		
			freePlayClickBoxOff.fillColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			freePlayButtonLabelOff.fontColor = SKColor.white
			
			freePlayClickBoxOn.fillColor = SKColor.white
			freePlayButtonLabelOn.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			
		} else {
		
			freePlayClickBoxOff.fillColor = SKColor.white
			freePlayButtonLabelOff.fontColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			
			freePlayClickBoxOn.fillColor = SKColor(displayP3Red: 86/255, green: 163/255, blue: 184/255, alpha: 1)
			freePlayButtonLabelOn.fontColor = SKColor.white
			
		}
		        
	}
	
	/// Default SpriteKit generated function
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { touchDown(atPoint: t.location(in: self)) }
        
	}
	
	/// Default SpriteKit generated function
	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { touchUp(atPoint: t.location(in: self)) }
        		
	}
	
	/// Default SpriteKit generated function
	public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { touchUp(atPoint: t.location(in: self)) }
	}
	
	// MARK: Frame Update
	
	/// Default SpriteKit generated function that is called before each frame
	public override func update(_ currentTime: TimeInterval) {
        
		// Handles scrolling of all objects
		handleScroll()
		     
		// Generates objects if needed
		if MainScene.obstacles.count < Game.obstacleCount {

            generateObstacle()

        }
		
		// Generates clouds if needed
		if cloudList.count < Game.cloudCount {

			generateCloud()

		}
		
		// Updates frame counter
		frameCounter += 1

		// Infers from neural network on every 10th frame
		if frameCounter % 10 == 0 && !freePlay {

			for p in players {
								
				if p.computeMove(player: p as SKShapeNode) {
					
					jump(body: p)

				}
			}
		}
	}
}
