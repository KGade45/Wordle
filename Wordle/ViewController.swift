//
//  ViewController.swift
//  Wordle
//
//  Created by Kaustubh kailas gade on 26/07/25.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    // The correct answer for the Wordle game.
    // TODO: take dynamic words through some api
    var answer: [Character] = ["H", "A", "U", "N", "T"]
    
    // A 2D array to store the guesses for all 5 rows.
    // Each inner array represents a 5-character guess for a row.
    var guesses: [[Character]] = Array(repeating: Array(repeating: " ", count: 5), count: 5)
    
    // Tracks the index of the row the user is currently allowed to edit.
    var currentGuessRowIndex: Int = 0
    
    // MARK: - UI Elements
    
    private let headingLabel: UILabel = {
        let label = UILabel()
        label.text = "Guess the Word"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        // Register the custom CardCollectionView cell
        tableView.register(CardCollectionView.self, forCellReuseIdentifier: CardCollectionView.identifier)
        tableView.separatorStyle = .none // No lines between table view cells
        tableView.backgroundColor = .systemBackground
        tableView.isScrollEnabled = false // No scrolling needed for a fixed number of rows
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        // Add target for the button tap action
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add UI elements to the view
        view.addSubview(headingLabel)
        view.addSubview(tableView)
        view.addSubview(submitButton)
        
        // Activate Auto Layout constraints
        activateConstraints()
        
        // Initially set the first row as editable and focus its first text field
        // This needs a slight delay to ensure the cell is laid out and ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let firstCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.currentGuessRowIndex)) as? CardCollectionView {
                firstCell.focusFirstTextField()
            }
        }
    }
    
    // MARK: - Layout Constraints
    
    func activateConstraints() {
        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headingLabel.heightAnchor.constraint(equalToConstant: 32),
            
            tableView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 600),
            
            submitButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    
    @objc func buttonTapped() {
        let indexPath = IndexPath(row: 0, section: currentGuessRowIndex)
        guard let cell = tableView.cellForRow(at: indexPath) as? CardCollectionView else {
            print("Error: Could not get active guess cell.")
            return
        }
        
        let currentGuessCharacters = self.guesses[currentGuessRowIndex]
        
        guard currentGuessCharacters.count == 5 && !currentGuessCharacters.contains(" ") else {
            let alert = UIAlertController(title: "Incomplete Word", message: "Please enter a full 5-letter word.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let normalizedAnswer = answer.map { Character($0.uppercased()) }
        let normalizedGuess = currentGuessCharacters.map { Character($0.uppercased()) }
        
        var resultColorsForPositions: [String] = Array(repeating: "", count: 5)
        var mutableAnswer = normalizedAnswer
        
        for i in 0..<5 {
            if normalizedGuess[i] == mutableAnswer[i] {
                resultColorsForPositions[i] = "Correct"
                mutableAnswer[i] = " "
            }
        }
        
        for i in 0..<5 {
            if resultColorsForPositions[i] == "" {
                if let indexInAnswer = mutableAnswer.firstIndex(of: normalizedGuess[i]) {
                    resultColorsForPositions[i] = "Contains"
                    mutableAnswer[indexInAnswer] = " "
                } else {
                    resultColorsForPositions[i] = "Incorrect"
                }
            }
        }
        
        cell.setGuessedResult(resultColorsForPositions)
        cell.revealGuessResult()
        
        let allCorrect = resultColorsForPositions.allSatisfy { $0 == "Correct" }
        
        if allCorrect {
            print("You guessed the word! Congratulations!")
            let alert = UIAlertController(title: "Congratulations!", message: "You guessed the word!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
                self.resetGame() // Reset game state
            }))
            present(alert, animated: true, completion: nil)
            
            cell.setEditable(false)
            
        } else if currentGuessRowIndex < 4 {
            currentGuessRowIndex += 1
            cell.setEditable(false)
            tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let nextCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.currentGuessRowIndex)) as? CardCollectionView {
                    nextCell.focusFirstTextField()
                }
            }
            
        } else {
            print("Game Over! The word was \(answer)")
            let alert = UIAlertController(title: "Game Over", message: "The word was \(String(answer)).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
                self.resetGame()
            }))
            present(alert, animated: true, completion: nil)
            cell.setEditable(false)
        }
    }
    
    // MARK: - Game Management
    
    func resetGame() {
        currentGuessRowIndex = 0 // Reset to the first guess row
        guesses = Array(repeating: Array(repeating: " ", count: 5), count: 5)
        
        let possibleWords = ["APPLE", "BAKER", "CRANE", "DREAM", "FLAME"]
        answer = Array(possibleWords.randomElement()?.uppercased() ?? "HAUNT")
        
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let firstCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CardCollectionView {
                firstCell.focusFirstTextField()
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardCollectionView.identifier, for: indexPath) as? CardCollectionView else {
            return UITableViewCell()
        }
        
        cell.guess = self.guesses[indexPath.section]
        
        // Determine if this row should be editable (only the current guess row)
        let isEditing = (indexPath.section == currentGuessRowIndex)
        cell.setEditable(isEditing)
        
        cell.didStartEditing = { [weak self] character, charIndex in
            guard let self = self else { return }
            self.guesses[indexPath.section][charIndex] = character
        }
        
        // For rows that have already been submitted
        if indexPath.section < currentGuessRowIndex {
            let submittedGuess = self.guesses[indexPath.section]
            let normalizedSubmittedGuess = submittedGuess.map { Character($0.uppercased()) }
            let normalizedAnswer = answer.map { Character($0.uppercased()) }
            
            var resultColorsForPreviousRow: [String] = Array(repeating: "", count: 5)
            var mutableAnswerForPreviousRow = normalizedAnswer
            
            for i in 0..<5 {
                if normalizedSubmittedGuess[i] == mutableAnswerForPreviousRow[i] {
                    resultColorsForPreviousRow[i] = "Correct"
                    mutableAnswerForPreviousRow[i] = " "
                }
            }
            for i in 0..<5 {
                if resultColorsForPreviousRow[i] == "" {
                    if let indexInAnswer = mutableAnswerForPreviousRow.firstIndex(of: normalizedSubmittedGuess[i]) {
                        resultColorsForPreviousRow[i] = "Contains"
                        mutableAnswerForPreviousRow[indexInAnswer] = " "
                    } else {
                        resultColorsForPreviousRow[i] = "Incorrect"
                    }
                }
            }
            cell.setGuessedResult(resultColorsForPreviousRow)
            cell.revealGuessResult()
        } else if indexPath.section > currentGuessRowIndex {
            // For future rows that haven't been guessed yet, they are not editable and are clear
            cell.setEditable(false)
            cell.shouldRevealResult = false
            cell.guess = Array(repeating: " ", count: 5)
        }
        return cell
    }
}
