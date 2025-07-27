//
//  CardView.swift
//  Wordle
//
//  Created by Kaustubh kailas gade on 26/07/25.
//

import UIKit

class CardCollectionView: UITableViewCell {
    var guess: [Character] = Array(repeating: " ", count: 5)
    
    // This will hold the "Correct", "Contains", "Incorrect" results for each position
    private var guessResultForPositions: [String]?
    var didStartEditing: ((Character, Int) -> Void)?
    
    static let identifier = "CardCollectionView"
    var shouldRevealResult: Bool = false
    var isEditable: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 80)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CardViewCell.self, forCellWithReuseIdentifier: CardViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This method is called by ViewController to set the editability of this row
    func setEditable(_ editable: Bool) {
        self.isEditable = editable
        collectionView.isUserInteractionEnabled = editable
        
        for cell in collectionView.visibleCells {
            if let cardCell = cell as? CardViewCell {
                cardCell.setTextFieldInteraction(enabled: editable)
            }
        }
        if editable {
            self.shouldRevealResult = false
        }
        collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    func setGuessedResult(_ result: [String]) {
        self.guessResultForPositions = result
    }
    
    func revealGuessResult() {
        self.shouldRevealResult = true
        collectionView.reloadData()
    }

    func focusFirstTextField() {
        collectionView.layoutIfNeeded()
        let indexPath = IndexPath(item: 0, section: 0)
        if let firstCell = collectionView.cellForItem(at: indexPath) as? CardViewCell {
            firstCell.focusTextField()
        }
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func getGuess() -> [Character] {
        return self.guess
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension CardCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardViewCell.identifier, for: indexPath) as? CardViewCell else {
            return UICollectionViewCell()
        }
        cell.layer.cornerRadius = 10
        cell.configure(with: String(guess[indexPath.item]))
        cell.setTextFieldInteraction(enabled: self.isEditable)
        
        cell.onTextEntered = { [weak self] text in
            guard let self = self else { return }
            let upperChar = text.uppercased().first ?? " "
            self.guess[indexPath.item] = upperChar
            self.didStartEditing?(upperChar, indexPath.item)
            
            let nextIndex = indexPath.item + 1
            if nextIndex < 5 {
                let nextIndexPath = IndexPath(item: nextIndex, section: indexPath.section)
                if let nextCell = collectionView.cellForItem(at: nextIndexPath) as? CardViewCell {
                    nextCell.focusTextField()
                }
            }
        }
        
        cell.onTextDeleted = { [weak self] in
            guard let self = self else { return }
            self.guess[indexPath.item] = " "
            self.didStartEditing?(" ", indexPath.item)
            
            if indexPath.item > 0 {
                let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
                if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? CardViewCell {
                    previousCell.focusTextField()
                }
            }
        }
        
        if shouldRevealResult {
            if let result = guessResultForPositions?[indexPath.item] {
                cell.applyResult(result)
                print("Guessing '\(guess[indexPath.item])' -> Result: \(result)")
            } else {
                print("Error: No result found for position \(indexPath.item) in guess '\(guess[indexPath.item])'")
            }
        } else {
            cell.resetColor()
        }
        
        return cell
    }
}
