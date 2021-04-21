

/**
 
 ***WELCOME TO NEURAL JUMP**
 
 */

///  NOTE: May take a second to compile because of type checking on the saved genetic data that is used for the "Jump To" function. (About 25 sec on my 2019 16" MBP)
///  NOTE: I had some issues with random errors involving items out of scope, but this is only a visual bug as they go away when the playground is built.

/**
 
 - Neural Jump is a showcase of how a genetic algorithm can be used to train a fully custom neural network. In this playground, the neural network is learning to play a simple side-scrolling game.

 - The neural network features a 10x10x2 neuron structure that takes in data from the enviornment about the height and distance of nearby objects. This is then processed using Apple's Accelerate framework to make quick and efficient inferences.

 - The genetic algorithm provides a method of evolving the neural network over time to achieve a more fit neural network. It has been tuned for maximum efficiency as it must process +1,000,000 genes per generation.

 - Because the game is randomly generated, some generations may perform better than others by chance. The important thing to notice is the evolution of decision making as the generations progress. More trained generations make more complex decisions and moves.

	- Generation 1 is random
	- Generation 100 is mostly simple and dies quickly
	- Generation 1000 develops to primarily hug the ceiling
	- Generation 5000 begins to develop more complex game moves
 
 More information can be found in my essay submissions.

 I hope you enjoy!
 
 */

/// This Playgound was built fron scratch in pure Swift by Blake Bollinger from 3/30/2021 - 4/19/2021

// Please run all code
import PlaygroundSupport
import SpriteKit
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
if let scene = MainScene(fileNamed: "MainScene") {
    scene.scaleMode = .aspectFill
    sceneView.presentScene(scene)
}
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
Game.startGame()
