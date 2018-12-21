//
//  ViewController.swift
//  CardFlip
//
//  Created by Erica Geraldes on 17/12/2018.
//  Copyright © 2018 Erica Geraldes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cvcLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var card: UIImageView!
    
    @IBOutlet weak var numberTextfield: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    var oldCard: UIImageView? = nil
    private var showingBack = false
    private var hasUpdatedCard = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberTextfield.delegate = self
        expiryDateTextField.delegate = self
        cvvTextField.delegate = self
        nameTextField.delegate = self
        
        hideBackLabel(true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        numberTextfield.assignedLabel = numberLabel
        expiryDateTextField.assignedLabel = expirationDateLabel
        cvvTextField.assignedLabel = cvcLabel
        nameTextField.assignedLabel = nameLabel
        
    }
    func masterCard() {
        oldCard = UIImageView(image: card.image)
        guard let oldCard = oldCard else { return }
        oldCard.bounds = card.bounds
        oldCard.frame = card.frame
        view.insertSubview(oldCard, belowSubview: card)
        let fullHeight = card.bounds.width
        let extremePoint = CGPoint(x: card.center.x - fullHeight,
                                   y: card.center.y)
        let radius = sqrt((extremePoint.x*extremePoint.x) +
            (extremePoint.y*extremePoint.y))
        
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(x: 0, y: -radius, width: 1, height: card.bounds.height))
        let circleMaskPathFinal = UIBezierPath(ovalIn: card.frame.insetBy(dx: -radius, dy: -radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        card.layer.mask = maskLayer
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.delegate = self
        maskLayerAnimation.duration = 1.0
        maskLayer.add(maskLayerAnimation, forKey: "path")
        hasUpdatedCard = true
    }
    
    @objc func flip() {
        let transitionOptions: UIView.AnimationOptions = self.showingBack ? [.transitionFlipFromLeft] : [.transitionFlipFromRight]
        UIView.transition(with: card, duration: 1.0, options: transitionOptions, animations: nil, completion: { _ in
            self.showingBack = !self.showingBack
        })
        UIView.transition(with: self.card, duration: 1.0, options: transitionOptions, animations: {
            self.card.image = self.showingBack ? (self.numberLabel.text?.count ?? 0 > 2 ? UIImage(named: "master_card_front") : UIImage(named:"blank_card_front")) :UIImage(named: "blank_card_rear")
        })
        
        
    }

    func hideFrontLabels(_ hide: Bool) {
        UIView.transition(with: nameLabel, duration: 1.1, options: .transitionCrossDissolve, animations: {
            self.nameLabel.isHidden = hide
            }, completion: nil)
        UIView.transition(with: expirationDateLabel, duration: 1.1, options: .transitionCrossDissolve, animations: {
            self.expirationDateLabel.isHidden = hide
        }, completion: nil)
        UIView.transition(with: numberLabel, duration: 1.1, options: .transitionCrossDissolve, animations: {
            self.numberLabel.isHidden = hide
        }, completion: nil)
    }
    
    func hideBackLabel(_ hide: Bool) {
        UIView.transition(with: cvcLabel, duration: 1.1, options: .transitionCrossDissolve, animations: {
            self.cvcLabel.isHidden = hide
        }, completion: nil)
        
    }

}

extension ViewController: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        UIView.transition(with: card, duration: 1.0, options: .curveLinear, animations: {
             self.card.image = UIImage(named: "master_card_front")
            }, completion: nil)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag, let oldCard = oldCard else { return }
        oldCard.removeFromSuperview()
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let frame = scrollView.convert(textField.frame.origin, from: scrollView)
        
        UIView.animate(withDuration: 1.0, animations: {
                self.scrollView.contentOffset = CGPoint(x: frame.x + textField.bounds.width, y: 0)
        })
        switch  textField {
        case cvvTextField:
            if !self.showingBack { flip() }
            hideFrontLabels(!self.showingBack)
            hideBackLabel(self.showingBack)
        default:
            if self.showingBack {
                hideFrontLabels(!self.showingBack)
                hideBackLabel(self.showingBack)
                flip()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = (strcmp(char, "\\b") == -92)
        
        guard let label = textField.assignedLabel else { return false }
        if !isBackSpace { label.text?.append(string) } else { label.text?.removeLast() }
        if textField == numberTextfield {
            if let text = textField.text, text.count > 2 && !hasUpdatedCard {
                self.masterCard()
            }
        }
        return true
    }
}
