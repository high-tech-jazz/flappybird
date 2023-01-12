//
//  GameScene.swift
//  FlappyBird
//
//  Created by 伊藤敬 on 2023/01/04.
//

import UIKit
import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var ringoNode1:SKNode!
    var ringoNode2:SKNode!
    var ringoNode3:SKNode!
    var ringoNode4:SKNode!
    var player: AVAudioPlayer?
    var playerBGM: AVAudioPlayer?
    
    // 衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let ringoCategory1: UInt32 = 1 << 4
    let ringoCategory2: UInt32 = 1 << 5
    let ringoCategory3: UInt32 = 1 << 6
    let ringoCategory4: UInt32 = 1 << 7
    var cnt = 0
    
    // スコア用
    var score = 0
    var scoreRingo = 0
    var scoreLabelNode:SKLabelNode!
    var ringoLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard

    var mode : String = ""
    
    // SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        print(mode)
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        // 背景色を指定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.9, alpha: 1)
        
        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        // 壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        // リンゴ用のノード
        ringoNode1 = SKNode()
        scrollNode.addChild(ringoNode1)
        ringoNode2 = SKNode()
        scrollNode.addChild(ringoNode2)
        ringoNode3 = SKNode()
        scrollNode.addChild(ringoNode3)
        ringoNode4 = SKNode()
        scrollNode.addChild(ringoNode4)
        
        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupRingo()
        
        // スコア表示ラベルの設定
        setupScoreLabel()
        
        playKakkoWalts()
    }
    
    func setupGround(){
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール→元の位置→左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置する
        for i in 0..<needNumber{
            let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置を指定する
            if self.frame.size.height > 400 {
                sprite.position = CGPoint(
                    x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                    y: groundTexture.size().height / 2
                )
            } else {
                sprite.position = CGPoint(
                    x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                    y: groundTexture.size().height / 8
                )
            }
            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理体を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            // 衝突の時に動かないようにする
            sprite.physicsBody?.isDynamic = false
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        // スクロールするアクションを生成
        // 左方向に画像一枚分移動させるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール→元の位置→左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            // スプライトにアクションを設定する
            sprite.run(repeatScrollCloud)
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
        
    }
    
    func setupWall(){
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingDistance = self.frame.size.width + wallTexture.size().width
        
        var durationNum : Double = 4
        if self.mode == "easy" {
            durationNum = 8
        }else if self.mode == "normal" {
            durationNum = 4
        }else if self.mode == "hard" {
            durationNum = 2
        }
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: durationNum)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // ２つのアニメーションを順に実行させるアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 鳥が通り抜ける隙間の大きさを鳥のサイズの４倍とする
        let slit_length = birdSize.height * 4
        
        // 隙間位置の上下の揺れ幅を60ptとする
        let random_y_range : CGFloat = 60
        
        // 空の中央位置(y座標)を取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        let sky_center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        
        // 空の中央位置を基準にして下側の壁の中央位置を取得
        let under_wall_center_y = sky_center_y - slit_length / 2 - wallTexture.size().height / 2
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁をまとめるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50
            
            // 下側の壁の中央位置にランダム値を足して、下側の壁の表示位置を決定する
            let random_y = CGFloat.random(in: -random_y_range...random_y_range)
            let under_wall_y = under_wall_center_y + random_y
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            // 下側の壁に物理体を設定
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            under.physicsBody?.isDynamic = false
            
            // 壁をまとめるノードに下側の壁を追加
            wall.addChild(under)
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // 上側の壁に物理体を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            upper.physicsBody?.isDynamic = false
            
            // 壁をまとめるノードに上側の壁を追加
            wall.addChild(upper)
            
            // スコアカウント用の透明な壁を作成
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.size.height)
            // 透明な壁に物理体を設定する
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.isDynamic = false
            // 壁をまとめるノードに透明な壁を追加
            wall.addChild(scoreNode)
            
            // 壁をまとめるノードにアニメーションを設定
            wall.run(wallAnimation)
            
            // 壁を表示するノードに今回作成した壁を追加
            self.wallNode.addChild(wall)
        })
        //次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: durationNum / 2)
        
        // 壁を作成→時間待ち→壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        // 壁を表示するノードに壁の作成を無限に繰り返すアクションを設定
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupRingo() {
        // リンゴの画像を読み込む
        let ringoTexture = SKTexture(imageNamed: "ringo")
        ringoTexture.filteringMode = .nearest
        
        // 移動する距離を計算
        let movingDistance = self.frame.size.width + ringoTexture.size().width
        
        var durationNum : Double = 10
        if self.mode == "easy" {
            durationNum = 20
        }else if self.mode == "normal" {
            durationNum = 10
        }else if self.mode == "hard" {
            durationNum = 4
        }
        
        // 画面外まで移動するアクションを作成
        let moveRingo = SKAction.moveBy(x: -movingDistance, y: 0, duration: durationNum)
        
        // 自身を取り除くアクションを作成
        let removeRingo = SKAction.removeFromParent()
        
        // ２つのアニメーションを順に実行させるアクションを作成
        let ringoAnimation = SKAction.sequence([moveRingo, removeRingo])
        
        // 空の中央位置(y座標)を取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        let sky_center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        
        // 空の中央位置を基準にして下側の壁の中央位置を取得
        let ringo_center_y = sky_center_y - ringoTexture.size().height / 2
        
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        
        // リンゴを配置するアクションを作成
        let createRingoAnimation = SKAction.run({
            // リンゴをまとめるノードを作成
            let ringo = SKNode()
            ringo.position = CGPoint(x: ringoTexture.size().width, y: 0)
            ringo.zPosition = 100
            
            // 下側の壁の中央位置にランダム値を足して、リンゴの表示位置を決定する
            let random_y = CGFloat.random(in: -100...100)
            let ringo_y = ringo_center_y + random_y
            
            // リンゴのスプライトを配置する
            let spriteRingo = SKSpriteNode(texture: ringoTexture)
            spriteRingo.size = CGSize(width: 50, height: 50)
            
            // リンゴの出現確率設定
            let random_num = Int.random(in: 0...100)
            var possiblity : Int = 100
            if self.mode == "easy" {
                possiblity = 100
            }else if self.mode == "normal" {
                possiblity = 50
            }else if self.mode == "hard" {
                possiblity = 10
            }
            if random_num < possiblity{
                spriteRingo.position = CGPoint(x: 0, y: wallTexture.size().height + ringo_y)
                
                // リンゴに物理体を設定する
                spriteRingo.physicsBody = SKPhysicsBody(circleOfRadius: 25)
                if self.cnt == 0 {
                    spriteRingo.physicsBody?.categoryBitMask = self.ringoCategory1
                }else if self.cnt == 1 {
                    spriteRingo.physicsBody?.categoryBitMask = self.ringoCategory2
                }else if self.cnt == 2 {
                    spriteRingo.physicsBody?.categoryBitMask = self.ringoCategory3
                }else if self.cnt == 3 {
                    spriteRingo.physicsBody?.categoryBitMask = self.ringoCategory4
                }
                spriteRingo.physicsBody?.isDynamic = false
                
                // リンゴをまとめるノードにリンゴを追加
                ringo.addChild(spriteRingo)
                
                // リンゴをまとめるノードにアニメーションを設定
                ringo.run(ringoAnimation)
                
                // リンゴを表示するノードに今回作成したリンゴを追加
                if self.cnt == 0 {
                    self.ringoNode1.addChild(ringo)
                }else if self.cnt == 1 {
                    self.ringoNode2.addChild(ringo)
                }else if self.cnt == 2 {
                    self.ringoNode3.addChild(ringo)
                }else if self.cnt == 3 {
                    self.ringoNode4.addChild(ringo)
                    self.cnt = -1
                }
                
                self.cnt = self.cnt + 1
            }
        })
        //次のリンゴ作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: durationNum / 4)
        
        // リンゴを作成→時間待ち→リンゴを作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createRingoAnimation, waitAnimation]))
        
        // リンゴを表示するノードにリンゴの作成を無限に繰り返すアクションを設定
        if self.cnt == 0 {
            ringoNode1.run(repeatForeverAnimation)
        }else if self.cnt == 1 {
            ringoNode2.run(repeatForeverAnimation)
        }else if self.cnt == 2 {
            ringoNode3.run(repeatForeverAnimation)
        }else if self.cnt == 3 {
            ringoNode4.run(repeatForeverAnimation)
        }
    }

    func setupBird(){
        // 鳥の画像を２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // ２種類のテクスチャを交互に変更するアニメーションを作成
        let textureAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(textureAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        // 物理体を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        // カテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | scoreCategory | ringoCategory1 | ringoCategory2 | ringoCategory3 | ringoCategory4
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            //restart()
            view?.presentScene(SelectScene(size: self.frame.size))
        }
    }
    
    // SKPhysicsContactDelegateのメソッド。衝突した時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーの時は何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコアカウント用の透明な壁と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            // ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            var secondScore = userDefaults.integer(forKey: "SECOND")
            var thirdScore = userDefaults.integer(forKey: "THIRD")
            
            if score > bestScore {
                if(score == bestScore + 1){
                    userDefaults.set(bestScore, forKey: "SECOND")
                    userDefaults.set(secondScore, forKey: "THIRD")
                }
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }else if score > secondScore {
                if(score == secondScore + 1){
                    userDefaults.set(secondScore, forKey: "THIRD")
                }
                secondScore = score
                userDefaults.set(secondScore, forKey: "SECOND")
                userDefaults.synchronize()
            }else if score > thirdScore {
                thirdScore = score
                userDefaults.set(thirdScore, forKey: "THIRD")
                userDefaults.synchronize()
            }
        } else if
            (contact.bodyA.categoryBitMask & ringoCategory1) == ringoCategory1 || (contact.bodyB.categoryBitMask & ringoCategory1) == ringoCategory1
        {
            // リンゴと衝突した
            print("Get Ringo")
            scoreRingo += 1
            ringoLabelNode.text = "Ringo:\(scoreRingo)"
            ringoNode1.removeAllChildren()
            playKakkoo()
        } else if  (contact.bodyA.categoryBitMask & ringoCategory2) == ringoCategory2 || (contact.bodyB.categoryBitMask & ringoCategory2) == ringoCategory2
        {
            // リンゴと衝突した
            print("Get Ringo")
            scoreRingo += 1
            ringoLabelNode.text = "Ringo:\(scoreRingo)"
            ringoNode2.removeAllChildren()
            playKakkoo()
        } else if (contact.bodyA.categoryBitMask & ringoCategory3) == ringoCategory3 || (contact.bodyB.categoryBitMask & ringoCategory3) == ringoCategory3
        {
            // リンゴと衝突した
            print("Get Ringo")
            scoreRingo += 1
            ringoLabelNode.text = "Ringo:\(scoreRingo)"
            ringoNode3.removeAllChildren()
            playKakkoo()
        } else if (contact.bodyA.categoryBitMask & ringoCategory4) == ringoCategory4 || (contact.bodyB.categoryBitMask & ringoCategory4) == ringoCategory4 {
            // リンゴと衝突した
            print("Get Ringo")
            scoreRingo += 1
            ringoLabelNode.text = "Ringo:\(scoreRingo)"
            ringoNode4.removeAllChildren()
            playKakkoo()
        } else {
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
            // ゲームオーバーの効果音
            playGameover()
            
            // ゲームオーバーの表示
            let label = SKLabelNode(text: "GAME OVER")
            label.fontColor = .white
            label.fontSize = 60
            label.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 + 30)
            addChild(label)
            
            // 衝突後は地面と反発するのみとする(リスタートするまで壁と反発させない)
            bird.physicsBody?.collisionBitMask = groundCategory
            
            // 衝突後１秒間、鳥をくるくる回転させる
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.run(roll, completion: {
                self.bird.speed = 0
            })
        }
    }
    
    func playKakkoo(){
        if let soundURL = Bundle.main.url(forResource: "kakkoo", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: soundURL)
                player?.currentTime = 6
                player?.play()
            } catch {
                print("sound error")
            }
        }
    }
    
    func playGameover(){
        if let soundURL = Bundle.main.url(forResource: "gameover", withExtension: "mp3") {
            do {
                playerBGM = try AVAudioPlayer(contentsOf: soundURL)
                playerBGM?.play()
            } catch {
                print("sound error")
            }
        }
    }
    
    func playKakkoWalts(){
        print("playKakkoWalts")
        if let bgmURL = Bundle.main.url(forResource: "kakkoo_walts", withExtension: "mp3") {
            do {
                playerBGM = try AVAudioPlayer(contentsOf: bgmURL)
                playerBGM?.play()
            } catch {
                print("sound error")
            }
        }
    }
    
    func restart() {
        // スコアを0にする
        score = 0
        scoreRingo = 0
        scoreLabelNode.text = "Score:\(score)"
        ringoLabelNode.text = "Ringo:\(scoreRingo)"
        
        // 鳥を初期位置に戻し、壁と地面の両方に反発するように戻す
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        // 全ての壁を取り除く
        wallNode.removeAllChildren()
        ringoNode1.removeAllChildren()
        ringoNode2.removeAllChildren()
        ringoNode3.removeAllChildren()
        ringoNode4.removeAllChildren()
        
        // 鳥の羽ばたきを戻す
        bird.speed = 1
        
        // スクロールを再開させる
        scrollNode.speed = 1
        
        playKakkoWalts()
    }
    
    func setupScoreLabel() {
        // スコア表示を作成
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        
        // ベストスコア表示を作成
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        
        // リンゴ表示を作成
        scoreRingo = 0
        ringoLabelNode = SKLabelNode()
        ringoLabelNode.fontColor = UIColor.red
        ringoLabelNode.zPosition = 100
        ringoLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        ringoLabelNode.text = "Ringo:\(scoreRingo)"
        
        if self.frame.size.height > 400 {
            scoreLabelNode.position = CGPoint(x: 10, y: frame.size.height - 60)
            bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
            ringoLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        } else {
            scoreLabelNode.position = CGPoint(x: 10, y: frame.size.height - 60)
            bestScoreLabelNode.position = CGPoint(x: self.frame.size.width / 2 - 100, y: self.frame.size.height - 60)
            ringoLabelNode.position = CGPoint(x: self.frame.size.width - 150, y: self.frame.size.height - 60)
        }
        self.addChild(scoreLabelNode)
        self.addChild(bestScoreLabelNode)
        self.addChild(ringoLabelNode)
        
    }
}
