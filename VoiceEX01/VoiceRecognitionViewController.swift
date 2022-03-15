//
//  VoiceRecognitionViewController.swift
//  VoiceEX-Test02
//
//  Created by 秋口俊輔 on 2020/01/07.
//  Copyright © 2020 秋口俊輔. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import RealmSwift

protocol TouchCellDelegate {
    func getNo(id: Int, wtext: String) -> Void
}

class VoiceRecognitionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TouchCellDelegate{
 
    func getNo(id: Int, wtext: String) {
        print(id)
        print(wtext)
        textListFinal[textListFinal.count - 1 - id] = wtext
        
        for i in 0 ..< textListFinal.count{
            if i == 0 {
                textViewSave = textListFinal[i]
            }
            else{
                textViewSave.append(textListFinal[i])
            }
        }
        
    }
    
    var isRecording = false
    //var w: CGFloat = 0
    //var h: CGFloat = 0
    //let d: CGFloat = 50
    //let l: CGFloat = 28

    let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine!
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    var textList = [String]()
    var textListFinal = [String]()
    var listCounter:Int = 0
    var listChageFlag:Int = 0
    var textViewSave:String = ""
    
    let commentTableViewCell = textCell()
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var outerCircle: UIView!
    @IBOutlet weak var innerCircle: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet var mainView: UIView!
    @IBOutlet var wakachiSwitch: UISwitch!
    
    @IBAction func wakachiSwitch(_ sender: Any) {
        if wakachiSwitch.isOn == true{
            hiraganawakachiFlag = 3
        }else{
            hiraganawakachiFlag = 0
        }
    }
    
    
    //形態素解析
    var hiraganawakachiFlag:Int = 0 //０；変換無し、1：わかちのみ、２：平仮名のみ、３：平仮名わかち
    let hiraganawakachi = HiraganaWakachi()
    
    @IBAction func resetButton(_ sender: Any) {
        
        textView.text = ""
        resetLiveTranscription()
        try! startLiveTranscription()
    }
 
    override func viewDidLoad() {
      super.viewDidLoad()
  
        print("音声認識 = 　\(recognizer.supportsOnDeviceRecognition)")
        
        mainView.backgroundColor = UIColor.init(red: 220/255, green: 255/255, blue: 255/255, alpha: 100/100)
        
        tableView.layer.borderColor = UIColor.systemBlue.cgColor
        tableView.layer.borderWidth = 2.0
        
        textView.layer.borderColor = UIColor.systemBlue.cgColor
        textView.layer.borderWidth = 2.0

        audioEngine = AVAudioEngine()
        textView.text = ""
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.textView.isEditable = false
        self.textView.isSelectable = false
        
        //tableviewでセルの高さ調整
        tableView.rowHeight = UITableView.automaticDimension //追加
        tableView.estimatedRowHeight = 10000 //追加
        
        //保存ボタンの装飾
        saveButton.layer.cornerRadius = 10.0  // 角丸のサイズ
        
        //リストボタンの装飾
        listButton.layer.cornerRadius = 10.0  // 角丸のサイズ
        listButton.tintColor = UIColor.lightText
        
        //録音ボタンの装飾
        recordButton.setTitle("停止中", for: .normal)
        recordButton.setTitleColor(UIColor.white, for: .normal)
        //recordButton.backgroundColor = UIColor(red:0/255,green:0/255,blue:0/255,alpha:0.7)
        recordButton.backgroundColor = UIColor.black
        
        //画面のどこかがタップされた時にdismissKeyboard()関数が呼ばれる
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR) //dismissKeyboard実行
        
        commentTableViewCell.delegate = self
        
    }
    
    //キーボードを閉じる（編集終了）のメソッド
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
        
    }

    //テーブル行数の指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listCounter = textListFinal.count
        return textListFinal.count
    }
    //各セルを生成して返却
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //カスタムセル生成
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! textCell
        cell.textLabel?.numberOfLines=0  //改行を無限にする
        
        cell.delegate = self

        cell.setCell(titleText: textListFinal[textListFinal.count - 1 - indexPath.row])
        
        cell.layoutIfNeeded()
        tableView.beginUpdates() //セルの高さ可変
        tableView.endUpdates() //セルの高さ可変
        
        //tableview部分の表示の入れ替え処理
        if indexPath.row == 0 {
            textViewSave = textListFinal[indexPath.row]
            textViewSave.append("。")
        } else {
            textViewSave.append(textListFinal[indexPath.row])
            textViewSave.append("。")
        }
        
        cell.id = indexPath.row
        
        //画面遷移後に保存される内容
        print(textViewSave)
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
      
      SFSpeechRecognizer.requestAuthorization { (authStatus) in
        DispatchQueue.main.async {
          if authStatus != SFSpeechRecognizerAuthorizationStatus.authorized {
            //self.recordButton.isEnabled = false
            //self.recordButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
          }
        }
      }
    }
    
    func stopLiveTranscription() {
        if textList.isEmpty == false && listChageFlag == 1{
            self.textListFinal.append(textList[0])
            self.tableView.reloadData()
            listChageFlag = 0
        }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionReq?.endAudio()
    }
    
    func resetLiveTranscription() {
        if textList.isEmpty == false && listChageFlag == 1{
            listChageFlag = 0
        }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionReq?.endAudio()
    }
    
    func startLiveTranscription() throws {
      // もし前回の音声認識タスクが実行中ならキャンセル
      if let recognitionTask = self.recognitionTask {
        recognitionTask.cancel()
        self.recognitionTask = nil
      }
      textView.text = ""

      // 音声認識リクエストの作成
      recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        recognitionReq?.requiresOnDeviceRecognition = true
      guard let recognitionReq = recognitionReq else {
        return
      }
      recognitionReq.shouldReportPartialResults = true

      // オーディオセッションの設定
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
      let inputNode = audioEngine.inputNode

      // マイク入力の設定
      let recordingFormat = inputNode.outputFormat(forBus: 0)
      inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, time) in
        recognitionReq.append(buffer)
      }
      audioEngine.prepare()
      try audioEngine.start()

        listChageFlag = 0
        
      recognitionTask = recognizer.recognitionTask(with: recognitionReq, resultHandler: { (result, error) in
        if let error = error {
            self.listChageFlag = 0

        } else {
            DispatchQueue.main.async {
            self.textList.insert((result?.bestTranscription.formattedString)!, at: 0)
                
                //self.hiraganawakachiFlag = 3
                
                self.textView.text = self.hiraganawakachi.hiraganaWakachi(recognitionText: self.textList[0], changeFlag: self.hiraganawakachiFlag)
                self.textList[0] = self.textView.text
                
            //self.textView.text = self.textList[0]
            self.listChageFlag  = 1
            }
        }
      })
        
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        if isRecording {
            /*
            UIView.animate(withDuration: 0.2) {
                self.showStartButton()
            }
            */
            wakachiSwitch.isEnabled = true
            recordButton.layer.cornerRadius = 0
            recordButton.setTitle("停止中", for: .normal)
            recordButton.backgroundColor = UIColor.black
            stopLiveTranscription()
        }else{
            /*
            UIView.animate(withDuration: 0.2) {
                self.showStopButton()
            }
             */
            wakachiSwitch.isEnabled = false
            recordButton.layer.cornerRadius = 24
            recordButton.setTitle("翻訳中", for: .normal)
            recordButton.backgroundColor = UIColor.red
            try! startLiveTranscription()
        }
        
        isRecording = !isRecording
        
    }
    
    /*
    func initRoundCorners(){
        recordButton.layer.masksToBounds = true

        baseView.layer.masksToBounds = true
        baseView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        outerCircle.layer.masksToBounds = true
        outerCircle.layer.cornerRadius = 31
        outerCircle.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        innerCircle.layer.masksToBounds = true
        innerCircle.layer.cornerRadius = 29
        innerCircle.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
    }
          
    func showStartButton() {
        recordButton.frame = CGRect(x:(w-d)/2,y:(h-d)/2,width:d,height:d)
        recordButton.layer.cornerRadius = d/2
    }
          
    func showStopButton() {
        recordButton.frame = CGRect(x:(w-l)/2,y:(h-l)/2,width:l,height:l)
        recordButton.layer.cornerRadius = 3.0
    }
    */
    
    @IBAction func saveButton(_ sender: Any) {
    
        var alertTextField: UITextField?

        let alert = UIAlertController(
            title: "ファイル名を入力",
            message: "名前をつけて保存",
            preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(
            configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
        })
        alert.addAction(
            UIAlertAction(
                title: "キャンセル",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default) { _ in
                if let text = alertTextField?.text {
                    if text == ""{
                        let dialog = UIAlertController(title: "保存されませんでした", message: "ファイル名を入力して下さい", preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(dialog, animated: true, completion: nil)
                        
                    }
                    else{
                        //データベースに書き込む処理
                        let voiceRecognitionData = VoiceRecognitionData()

                        let realmVoiceRecognitionData = try! Realm()
                        
                        let results = realmVoiceRecognitionData.objects(VoiceRecognitionData.self).filter("title == %@", text)
                        
                        let realmCount = results.count
                        
                        if realmCount == 0{
                            voiceRecognitionData.title = text
                            voiceRecognitionData.text = self.textViewSave
                            
                            try! realmVoiceRecognitionData.write{
                                realmVoiceRecognitionData.add(voiceRecognitionData)
                            }
                            //データベースに書き込む処理（ここまでセット）
                            
                            let dialog = UIAlertController(title: "保存完了", message: "データは保存されました", preferredStyle: .alert)
                            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(dialog, animated: true, completion: nil)
                            
                            print("保存しました")
                            
                        }
                        else{
                            let dialog = UIAlertController(title: "保存されませんでした", message: "既に使用されているファイル名です", preferredStyle: .alert)
                            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(dialog, animated: true, completion: nil)
                                print("同じデータがあります。")
                        }
                            
                        print(self.textViewSave)
                    }
                }
            }
        )

        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func listButton(_ sender: Any) {
        
        let nextalert: UIAlertController = UIAlertController(title: "保存データへ移動します", message: "保存していないデータは削除されます。\n移動しますか？", preferredStyle:  UIAlertController.Style.alert)

            // ② Actionの設定
            // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
            // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
            // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                //print("OK")
            
            let storyboard = UIStoryboard(name: "VoiceRecognitionSave", bundle: nil) // storyboardのインスタンスを名前指定で取得
            let nextVC = storyboard.instantiateInitialViewController() as! VoiceRecognitionSaveViewController // storyboard内で"is initial"に指定されているViewControllerを取得
            // FullScreenにする
            nextVC.modalPresentationStyle = .fullScreen
            // Subへ渡す値
            self.present(nextVC,animated: true, completion: nil) // presentする
            
            
            })
            // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                //print("Cancel")
            })

            // ③ UIAlertControllerにActionを追加
            nextalert.addAction(cancelAction)
            nextalert.addAction(defaultAction)

            // ④ Alertを表示
        present(nextalert, animated: true, completion: nil)
        
    }
   
}

//各セルの内容を管理するクラス
class textCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var cellTextView: UITextView!
    
    var id:Int?
    var wtext:String?
    var delegate: TouchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellTextView.delegate = self
    }
 
    //セルを選択した時に呼ばれる
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

 
        // Configure the view for the selected state
    }
 
    // 画像・タイトル・説明文を設定するメソッド
    func setCell(titleText: String) {
        cellTextView.text = titleText
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("OK")
        //self.delegate?.getNo(id:self.id!,wtext: self.wtext!)
        self.delegate?.getNo(id: self.id!, wtext: cellTextView.text)
    }
    
}


