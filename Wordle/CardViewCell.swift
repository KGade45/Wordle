//
//  CardViewCell.swift
//  Wordle
//
//  Created by Kaustubh kailas gade on 26/07/25.
//

import UIKit

class CardViewCell: UICollectionViewCell {
    static let identifier = "CardViewCell"

    private let textField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .center
        tf.font = .systemFont(ofSize: 28, weight: .bold)
        tf.textColor = .label
        tf.keyboardType = .asciiCapable
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .allCharacters
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    var onTextEntered: ((String) -> Void)?
    var onTextDeleted: (() -> Void)?
    
    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textField)
        textField.delegate = self

        backgroundColor = .systemGray4
        contentView.clipsToBounds = true

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(focusTextField))
        contentView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods

    @objc func focusTextField() {
        textField.becomeFirstResponder()
    }
    
    func configure(with letter: String) {
        if letter != " " && letter != "~" {
            textField.text = letter.uppercased()
        } else {
            textField.text = ""
        }
        resetColor()
    }

    func getText() -> String? {
        return textField.text
    }

    func setTextFieldInteraction(enabled: Bool) {
        textField.isUserInteractionEnabled = enabled
        textField.alpha = enabled ? 1.0 : 0.6 // Dim non-editable cells
    }

    // Applies the color feedback based on the Wordle result ("Correct", "Contains", "Incorrect")
    func applyResult(_ result: String?) {
        guard let result = result else {
            return
        }
        print("Applying result: \(result) for character: \(textField.text ?? "")") // Debugging print

        UIView.transition(with: self, duration: 0.3, options: .transitionFlipFromTop, animations: {
            switch result {
            case "Correct":
                self.backgroundColor = .systemGreen
            case "Contains":
                self.backgroundColor = .systemYellow
            case "Incorrect":
                self.backgroundColor = .systemGray
            default:
                self.backgroundColor = .systemGray4
            }
        })
    }
    
    func resetColor() {
        backgroundColor = .systemGray4 // Default background color
    }
    
    func clear() {
        textField.text = ""
        resetColor()
    }
}

// MARK: - UITextFieldDelegate

extension CardViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField.isUserInteractionEnabled else { return false }

        if string.isEmpty {
            onTextDeleted?()
            textField.text = ""
            return false
        } else {
            if (textField.text ?? "").isEmpty {
                onTextEntered?(string)
                textField.text = string.uppercased()
                return false
            }
        }
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}
