//
//  AnimatedDatePickerView.swift
//  camera
//
//  Created by 中西航平 on 2018/10/02.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit

class AnimatedDatePickerView: UIView {
    let picker = UIDatePicker()
    var delegate: DatePickerViewDelegate?
    
    private let screenSize    = UIScreen.main.bounds.size
    private let viewHeight    = CGFloat(260.0)
    private let toolbarHeight = CGFloat(44.0)
    private let pickerHeight  = CGFloat(216.0)
    
    init() {
        super.init(frame: .zero)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: viewHeight)
        self.backgroundColor = UIColor.white
        
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(origin: .zero, size: CGSize(width: screenSize.width, height: toolbarHeight))
        let buttonCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttonDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        toolbar.setItems([buttonCancel, flexSpace, buttonDone], animated: false)
        
        self.picker.datePickerMode = .time
        self.picker.locale = .current
        self.picker.frame = CGRect(x: 0, y: toolbarHeight, width: screenSize.width, height: pickerHeight)
        
        self.addSubview(toolbar)
        self.addSubview(picker)
    }
    
    @objc private func cancelButtonTapped() {
        self.delegate?.datePickerViewDidCancel(picker: self)
    }
    
    @objc private func doneButtonTapped() {
        self.delegate?.datePickerViewDidComplete(picker: self)
    }
    
    func show() {
        UIView.animate(withDuration: 0.2) {
            self.frame = CGRect(x: 0, y: self.screenSize.height - self.frame.height, width: self.frame.width, height: self.frame.height)
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: 0, y: self.screenSize.height, width: self.frame.width, height: self.frame.height)
        }) { _ in
            self.removeFromSuperview()
             self.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: self.viewHeight)        }
    }
}
