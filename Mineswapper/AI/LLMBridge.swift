// LLMBridge.swift
// Mineswapper AI - LM Studio Integration
//
// Connects to local LM Studio for natural language explanations
// and strategy analysis.

import Foundation

/// LLM response for move explanation
struct LLMExplanation {
    /// The explanation text
    let text: String
    /// Whether the LLM was available
    let isAvailable: Bool
    /// Error message if any
    let error: String?
}

/// Bridge to LM Studio for natural language explanations
///
/// Uses OpenAI-compatible API to communicate with LM Studio.
/// Falls back gracefully if LM Studio is not available.
final class LLMBridge {
    
    /// LM Studio API endpoint
    private let baseURL: String
    
    /// Model to use
    private let model: String
    
    /// Request timeout
    private let timeout: TimeInterval
    
    /// Whether LM Studio is available
    private(set) var isAvailable: Bool = false
    
    /// Initialize with LM Studio configuration
    /// - Parameters:
    ///   - baseURL: API endpoint (default: http://127.0.0.1:1234/v1)
    ///   - model: Model name (default: qwen3.5-35b-a3b)
    ///   - timeout: Request timeout in seconds (default: 30)
    init(
        baseURL: String = "http://127.0.0.1:1234/v1",
        model: String = "qwen3.5-35b-a3b",
        timeout: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.model = model
        self.timeout = timeout
    }
    
    // MARK: - Public API
    
    /// Check if LM Studio is available
    func checkAvailability() async -> Bool {
        guard let url = URL(string: "\(baseURL)/models") else {
            isAvailable = false
            return false
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                isAvailable = true
                return true
            }
        } catch {
            // LM Studio not available
        }
        
        isAvailable = false
        return false
    }
    
    /// Explain a move in natural language
    /// - Parameters:
    ///   - move: The move position (row, col)
    ///   - strategy: The AI strategy used
    ///   - confidence: Confidence level
    ///   - boardDescription: Text description of the board state
    /// - Returns: LLMExplanation with natural language explanation
    func explainMove(
        move: (Int, Int),
        strategy: AIStrategy,
        confidence: Double,
        boardDescription: String
    ) async -> LLMExplanation {
        guard isAvailable else {
            return LLMExplanation(
                text: strategy.displayName + " was used to determine this move.",
                isAvailable: false,
                error: "LM Studio not available"
            )
        }
        
        let prompt = """
        You are a Minesweeper expert. Explain why this move was chosen:
        
        Move: Row \(move.0 + 1), Column \(move.1 + 1)
        Strategy: \(strategy.displayName)
        Confidence: \(Int(confidence * 100))%
        
        Board state:
        \(boardDescription)
        
        Provide a brief, clear explanation (2-3 sentences) of why this is a good move.
        Focus on the reasoning, not technical details.
        """
        
        return await queryLLM(prompt: prompt)
    }
    
    /// Provide a hint for the current board state
    /// - Parameter boardDescription: Text description of the board state
    /// - Returns: LLMExplanation with hint
    func getHint(boardDescription: String) async -> LLMExplanation {
        guard isAvailable else {
            return LLMExplanation(
                text: "Look for cells where all adjacent mines are already flagged.",
                isAvailable: false,
                error: "LM Studio not available"
            )
        }
        
        let prompt = """
        You are a Minesweeper coach. Give the player a helpful hint.
        
        Current board:
        \(boardDescription)
        
        Provide ONE specific, actionable hint (1-2 sentences).
        Don't reveal the exact move, but guide their thinking.
        """
        
        return await queryLLM(prompt: prompt)
    }
    
    /// Analyze a completed game
    /// - Parameters:
    ///   - outcome: Game outcome (won/lost)
    ///   - stats: Game statistics
    /// - Returns: LLMExplanation with game analysis
    func analyzeGame(outcome: GameState, stats: GameStats) async -> LLMExplanation {
        guard isAvailable else {
            return LLMExplanation(
                text: "Game \(outcome == .won ? "won" : "lost"). " +
                      "Used constraint solver for \(stats.constraintMoves) moves, " +
                      "Monte Carlo for \(stats.monteCarloMoves) moves.",
                isAvailable: false,
                error: "LM Studio not available"
            )
        }
        
        let prompt = """
        Analyze this Minesweeper game:
        
        Outcome: \(outcome == .won ? "Won" : "Lost")
        Duration: \(stats.duration) seconds
        Total moves: \(stats.totalMoves)
        Constraint solver moves: \(stats.constraintMoves)
        Monte Carlo moves: \(stats.monteCarloMoves)
        Guesses: \(stats.guessMoves)
        
        Provide a brief analysis (3-4 sentences):
        1. What went well?
        2. What could be improved?
        3. One tip for the next game.
        """
        
        return await queryLLM(prompt: prompt)
    }
    
    // MARK: - Private
    
    /// Query the LLM with a prompt
    private func queryLLM(prompt: String) async -> LLMExplanation {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            return LLMExplanation(text: "", isAvailable: false, error: "Invalid URL")
        }
        
        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a helpful Minesweeper expert. Be concise and clear."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 200
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeout
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let first = choices.first,
               let message = first["message"] as? [String: Any],
               let content = message["content"] as? String {
                return LLMExplanation(text: content, isAvailable: true, error: nil)
            }
        } catch {
            return LLMExplanation(text: "", isAvailable: false, error: error.localizedDescription)
        }
        
        return LLMExplanation(text: "", isAvailable: false, error: "Failed to parse response")
    }
}

/// Game statistics for LLM analysis
struct GameStats {
    let duration: Int
    let totalMoves: Int
    let constraintMoves: Int
    let monteCarloMoves: Int
    let guessMoves: Int
}
