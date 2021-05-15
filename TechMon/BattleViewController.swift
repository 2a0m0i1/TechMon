//
//  BattleViewController.swift
//  TechMon
//
//  Created by 阿部亜未 on 2021/05/15.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPLabel: UILabel!
    @IBOutlet var enemyMPLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var player: Character!
    var enemy: Character!
    var gameTimer: Timer!
    var isPlayerAttackAvilable: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //キャラクターの読み込み
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        
        
        
        //ゲームスタート
        gameTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateGame),
            userInfo: nil,
            repeats: true)
        gameTimer.fire()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    //ステータスの反映
    func updateUI(){
        //プレイヤーのステータスを反映
        playerNameLabel.text = "勇者"
        playerImageView.image = UIImage(named: "yusya.png")
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)/"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)/"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)/"
        
        //敵のステータスを反映
        enemyNameLabel.text = "龍"
        enemyImageView.image = UIImage(named: "monster.png")
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)/"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)/"
    }
    //0.1秒ごとにゲームの状態を更新する
    @objc func updateGame(){
        
        //プレイヤーのステータスを更新
        player.currentMP += 1
        if player.currentMP >= 20{
            isPlayerAttackAvilable = true
            player.currentMP = 20
        } else {
            isPlayerAttackAvilable = false
        }
        
        //敵のステータスを更新
        enemy.currentMP += 1
        if enemy.currentMP >= 35{
            enemyAttack()
            enemy.currentMP = 0
        }
        updateUI()
    }
    //敵の攻撃
    func enemyAttack(){
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= 20
        
        playerHPLabel.text = "\(player.currentHP) / 100"
        
        if player.currentHP <= 0 {
            
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }
        playerMPLabel.text = "\(player.currentMP) / 20"
        enemyMPLabel.text = "\(enemy.currentMP) / 35"
    }
    
    //勝敗判定をする
    func judgeBattle(){
        if player.currentHP <= 0{
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        } else if enemy.currentHP <= 0{
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    //勝敗が決定した時の処理
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool){
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvilable = false
        
        var finishiMessage: String = ""
        if isPlayerWin{
            
            techMonManager.playSE(fileName: "SE_fanfare")
            finishiMessage = "勇者の勝利！！"
        } else {
            
            techMonManager.playSE(fileName: "SE_gameover")
            finishiMessage = "勇者の敗北..."
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishiMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:  { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //ボタンを押した時の処理、0.1秒ごとに画面は更新されるのでステータスだけ変える
    @IBAction func attackAction(){
        
        if isPlayerAttackAvilable{
            
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP{
                
                player.currentTP = player.maxTP
            }
            
            enemy.currentHP -= 30
            player.currentMP = 0
            
            enemyHPLabel.text = "\(enemy.currentHP) / 200"
            playerMPLabel.text = "\(player.currentMP) / 20"
            
            if enemy.currentHP <= 0{
                finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
            }
        }
    }
    
    @IBAction func fireAction() {
        
        if isPlayerAttackAvilable && player.currentTP >= 40 {
            
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            if player.currentTP <= 0 {
                
                player.currentTP = 0
                
            }
            player.currentMP = 0
            
            judgeBattle()
        }
    }
    
    @IBAction func tameruAction(){
        
        if isPlayerAttackAvilable{
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP{
                
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
        }
    }
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


