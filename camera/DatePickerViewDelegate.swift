//
//  DatePickerViewDelegate.swift
//  camera
//
//  Created by 中西航平 on 2018/10/02.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import Foundation
protocol DatePickerViewDelegate {
    func datePickerViewDidCancel(picker: AnimatedDatePickerView)
    func datePickerViewDidComplete(picker: AnimatedDatePickerView)
}
