//
//  SelectScene.swift
//  FlappyBird
//
//  Created by 伊藤敬 on 2023/01/12.
//

import SpriteKit

class SelectScene: SKScene {
    let userDefaults:UserDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        backgroundColor = .lightGray
        
        let label = SKLabelNode(text: "FLAPPY BIRD")
        label.fontColor = .white
        label.fontSize = 60
        
        let buttonEasy = SKShapeNode(rectOf: CGSize(width: self.frame.size.width - 150, height: 40))
        buttonEasy.fillColor = .systemCyan
        let buttonEasytext = SKLabelNode(text: "かんたん")
        buttonEasytext.name = "easy"
        buttonEasytext.fontColor = .white
        buttonEasytext.fontSize = 30
        
        let buttonNorm = SKShapeNode(rectOf: CGSize(width: self.frame.size.width - 150, height: 40))
        buttonNorm.fillColor = .systemCyan
        let buttonNormtext = SKLabelNode(text: "普通")
        buttonNormtext.name = "normal"
        buttonNormtext.fontColor = .white
        buttonNormtext.fontSize = 30
        
        let buttonHard = SKShapeNode(rectOf: CGSize(width: self.frame.size.width - 150, height: 40))
        buttonHard.fillColor = .systemCyan
        let buttonHardtext = SKLabelNode(text: "難しい")
        buttonHardtext.name = "hard"
        buttonHardtext.fontColor = .white
        buttonHardtext.fontSize = 30
        
        let bestScoreLabel = SKLabelNode(text: "Ranking")
        bestScoreLabel.fontColor = .white
        bestScoreLabel.fontSize = 30
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        let bestScoreNode = SKLabelNode(text: "1:" + String(bestScore))
        bestScoreNode.fontColor = .white
        bestScoreNode.fontSize = 30
        
        let secondScore = userDefaults.integer(forKey: "SECOND")
        let secondScoreNode = SKLabelNode(text: "2:" + String(secondScore))
        secondScoreNode.fontColor = .white
        secondScoreNode.fontSize = 30
        
        let thirdScore = userDefaults.integer(forKey: "THIRD")
        let thirdScoreNode = SKLabelNode(text: "3:" + String(thirdScore))
        thirdScoreNode.fontColor = .white
        thirdScoreNode.fontSize = 30
        
        if self.frame.size.height > 400 {
            label.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 250)
            buttonEasy.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 340)
            buttonEasytext.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 350)
            buttonNorm.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 390)
            buttonNormtext.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 400)
            buttonHard.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 440)
            buttonHardtext.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 450)
            bestScoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 550)
            bestScoreNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 590)
            secondScoreNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 630)
            thirdScoreNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 670)
        } else {
            label.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 100)
            buttonEasy.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 140)
            buttonEasytext.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 150)
            buttonNorm.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 180)
            buttonNormtext.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 190)
            buttonHard.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 220)
            buttonHardtext.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 230)
            bestScoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 270)
            bestScoreNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 300)
            secondScoreNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 330)
            thirdScoreNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 360)
        }
        addChild(label)
        addChild(buttonEasy)
        addChild(buttonEasytext)
        addChild(buttonNorm)
        addChild(buttonNormtext)
        addChild(buttonHard)
        addChild(buttonHardtext)
        addChild(bestScoreLabel)
        addChild(bestScoreNode)
        addChild(secondScoreNode)
        addChild(thirdScoreNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        // ビューと同じサイズでシーンを作成する
        let scene = GameScene(size: self.frame.size)
        scene.mode = atPoint(touch.location(in: self)).name ?? "normal"
        view?.presentScene(scene)
    }
}
