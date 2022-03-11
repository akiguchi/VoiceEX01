//
//  VoiceRecognitionSaveViewController.swift
//  ATappSuiteProto
//
//  Created by 秋口俊輔 on 2021/01/13.
//

import UIKit
import RealmSwift

var selectCell:Int = -1

class VoiceRecognitionSaveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    let voiceRecognitionData = VoiceRecognitionData()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveTableView: UITableView!
    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.backgroundColor = UIColor.init(red: 220/255, green: 255/255, blue: 255/255, alpha: 100/100)
        
        saveTextView.layer.borderColor = UIColor.blue.cgColor  //textviewの枠の色
        saveTextView.layer.borderWidth = 2.0  //枠線の幅
        
        saveTableView.layer.borderColor = UIColor.blue.cgColor  //textviewの枠の色
        saveTableView.layer.borderWidth = 2.0  //枠線の幅
        
        //削除ボタンの装飾
        deleteButton.layer.cornerRadius = 10.0  // 角丸のサイズ
        deleteButton.tintColor = UIColor.lightText
        
        //戻るボタンの装飾
        backButton.layer.cornerRadius = 10.0  // 角丸のサイズ
        
        self.saveTextView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //let voiceRecognitionData = VoiceRecognitionData()

        let realmVoiceRecognitionData = try! Realm()
        
        let results = realmVoiceRecognitionData.objects(VoiceRecognitionData.self)
        
        let realmCount = results.count
    
        return realmCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "saveCell", for: indexPath)
                // セルに表示する値を設定する
        
        //let voiceRecognitionData = VoiceRecognitionData()

        let realmVoiceRecognitionData = try! Realm()
        
        let results = realmVoiceRecognitionData.objects(VoiceRecognitionData.self)
        
        cell.textLabel!.text = results[indexPath.row].title
        //cell.textLabel!.text = results[results.count - 1 - indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        let realmVoiceRecognitionData = try! Realm()
        
        let results = realmVoiceRecognitionData.objects(VoiceRecognitionData.self)
        
        saveTextView.text = ""
        saveTextView.text = results[indexPath.row].text
            // タップされたセルの行番号を出力
        
        selectCell = indexPath.row
            print("\(indexPath.row)番目の行が選択されました。")
        
        //tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if selectCell == -1 {
            print("削除")
            saveTextView.text = ""
        }
        else{
            print(selectCell)
            
            let voiceRecognitionData = VoiceRecognitionData()

            let realmVoiceRecognitionData = try! Realm()
            
            let results = realmVoiceRecognitionData.objects(VoiceRecognitionData.self)
 
            try! realmVoiceRecognitionData.write{
                    //realmVoiceRecognitionData.add(voiceRecognitionData)
                results[selectCell].text = saveTextView.text
            }
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "VoiceRecognition", bundle: nil) // storyboardのインスタンスを名前指定で取得
        let nextVC = storyboard.instantiateInitialViewController() as! VoiceRecognitionViewController // storyboard内で"is initial"に指定されているViewControllerを取得
        // FullScreenにする
        nextVC.modalPresentationStyle = .fullScreen
        // Subへ渡す値
        //nextVC.text = "hello" // <--- SubViewControllerのプロパティ`text`
        self.present(nextVC,animated: true, completion: nil) // presentする
        
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        
        //print(selectCell)
        
        /*let realmVoiceRecognitionData = try! Realm()
        
        let results = realmVoiceRecognitionData.objects(VoiceRecognitionData.self)
        
        try! realmVoiceRecognitionData.write{
            realmVoiceRecognitionData.delete(results[selectCell])
        }
        
        saveTableView.reloadData()
        
        selectCell = -1*/
        
        let deletealert: UIAlertController = UIAlertController(title: "データを削除します", message: "一度削除すると元には戻せません。\n削除しますか？", preferredStyle:  UIAlertController.Style.alert)

            // ② Actionの設定
            // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
            // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
            // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                //print("OK")
            
            let realmVoiceRecognitionData = try! Realm()
            
            let results = realmVoiceRecognitionData.objects(VoiceRecognitionData.self)
            
            let realmCount = results.count
            
            if realmCount == 0{
                print("保存なし")
            }
            else{
                print(realmCount)
                try! realmVoiceRecognitionData.write{
                    realmVoiceRecognitionData.delete(results[selectCell])
                }
            }
            self.saveTableView.reloadData()
            self.saveTextView.text = ""
            
            selectCell = -1
            
            })
            // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                //print("Cancel")
            })

            // ③ UIAlertControllerにActionを追加
            deletealert.addAction(cancelAction)
            deletealert.addAction(defaultAction)

            // ④ Alertを表示
        present(deletealert, animated: true, completion: nil)
        
        
        
    }
    
}
