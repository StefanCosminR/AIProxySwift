//
//  OpenAIResponseStreamHandler.swift
//  AIProxy
//
//  Created on 4/12/25.
//

import Foundation

/// A custom implementation for handling streaming chunks from OpenAI's Responses API
/// The Responses API has a unique streaming format with multiple event types
public struct OpenAIResponseStreamHandler: AsyncSequence {
    public typealias Element = OpenAIResponseChunk
    
    private let asyncLines: AsyncLineSequence<URLSession.AsyncBytes>
    
    public init(asyncLines: AsyncLineSequence<URLSession.AsyncBytes>) {
        self.asyncLines = asyncLines
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(asyncBytesIterator: self.asyncLines.makeAsyncIterator())
    }
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        var asyncBytesIterator: AsyncLineSequence<URLSession.AsyncBytes>.AsyncIterator
        
        public mutating func next() async throws -> OpenAIResponseChunk? {
            while true {
                guard let line = try await asyncBytesIterator.next() else {
                    return nil  // No more lines to process
                }
                
                // Skip empty lines
                if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    continue
                }
                
                // Skip lines that don't start with "data: "
                if !line.hasPrefix("data: ") {
                    logIf(.debug)?.debug("Received unexpected line from aiproxy: \(line)")
                    continue
                }
                
                // Attempt to parse the line
                if let chunk = OpenAIResponseChunk.deserialize(fromLine: line) {
                    return chunk
                }
            }
        }
    }
}