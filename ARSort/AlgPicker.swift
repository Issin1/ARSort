//
//  AlgPicker.swift
//  ARSort
//
//  Created by CuiZihan on 2020/7/23.
//  Copyright © 2020 CuiZihan. All rights reserved.
//

import Foundation
import UIKit

class AlgorithmPicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    let algorithms:[String] = ["Bubble Sort", "Quick Sort", "Merge Sort", "Insert Sort"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return algorithms[row]
    }

    
}
