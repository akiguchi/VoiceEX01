//
//  HiraganaWakachi.swift
//  VoiceEX01
//
//  Created by 秋口俊輔 on 2022/03/15.
//

import Foundation

class HiraganaWakachi{
    
    let tokenizer = Tokenizer()
    //let voicerecognitionviewcontroller = VoiceRecognitionViewController()
    //０；変換無し、1：わかちのみ、２：平仮名のみ、３：平仮名わかち
    
    func hiraganaWakachi(recognitionText: String,changeFlag:Int)->String{
 
        var outputText:String = ""
        
        let tokens = tokenizer.parse(recognitionText)
        
        // append information from each token
        for token: Token in tokens {
            
            switch changeFlag{
            case 0:
                outputText = recognitionText
            case 1:
                outputText += "\(token.surface)　"
            case 2:
                if let reading = token.reading {
                    let reading2 = reading.applyingTransform(.hiraganaToKatakana, reverse: true)
                    outputText += "\(reading2 ?? "")"
                }
            case 3:
                if let reading = token.reading {
                    let reading2 = reading.applyingTransform(.hiraganaToKatakana, reverse: true)
                    outputText += "\(reading2 ?? "")　"
                }
            default:
                outputText = recognitionText
                
            }
            
            
            // all tokens have a surface property (the exact substring)
            //outputText += "\(token.surface)\n"
            
            // but the other properties aren't required, so they're optional
            /*
            if let reading = token.reading {
                let reading2 = reading.applyingTransform(.hiraganaToKatakana, reverse: true)
                //outputText += "読み: \(reading2 ?? "")\n"
                outputText += "\(reading2 ?? "")　"
            }
             */

        }

        return outputText
        
    }
    
}
