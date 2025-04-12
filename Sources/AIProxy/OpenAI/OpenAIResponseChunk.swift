//
//  OpenAIResponseChunk.swift
//  AIProxy
//
//  Created on 4/12/25.
//

import Foundation

/// Represents a streamed chunk of a response returned by the OpenAI Responses API
/// https://platform.openai.com/docs/api-reference/responses/streaming
public struct OpenAIResponseChunk: Decodable {
    /// A unique identifier for the response. Each chunk has the same ID.
    public let id: String?
    /// The object type, which is always "response.chunk"
    public let object: String?
    /// The Unix timestamp (in seconds) of when the response was created. Each chunk has the same timestamp.
    public let createdAt: Double?
    /// The delta content of this chunk.
    public let delta: Delta
    /// The usage information for the chunk. This is only available in the final chunk.
    public let usage: OpenAIResponse.ResponseUsage?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case delta
        case usage
    }
    
    /// Helper method to deserialize from a line of streaming data
    static func deserialize(fromLine line: String) -> Self? {
        guard line.hasPrefix("data: "),
              let chunkJSON = line.dropFirst(6).data(using: .utf8),
              let chunk = try? JSONDecoder().decode(Self.self, from: chunkJSON) else {
            logIf(.warning)?.warning("Received unexpected JSON from OpenAI Responses API: \(line)")
            return nil
        }
        return chunk
    }
}

// MARK: - Delta
extension OpenAIResponseChunk {
    public struct Delta: Decodable {
        /// The text content of this chunk
        public let text: String?
        /// The tool calls delta, if any
        public let toolCalls: [ToolCall]?
        /// The reasoning delta, if the model is providing reasoning
        public let reasoning: String?
        
        private enum CodingKeys: String, CodingKey {
            case text
            case toolCalls = "tool_calls"
            case reasoning
        }
    }
    
    /// Represents a tool call in a streaming response chunk
    public struct ToolCall: Decodable {
        /// The ID of the tool call
        public let id: String?
        /// The index of the tool call in the list of tool calls
        public let index: Int?
        /// The type of the tool call (e.g., "function")
        public let type: String?
        /// The function details if the tool call is a function
        public let function: Function?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case index
            case type
            case function
        }
    }
    
    /// Represents a function in a tool call
    public struct Function: Decodable {
        /// The name of the function to call
        public let name: String?
        /// The arguments to the function, represented as a JSON string
        public let arguments: String?
        
        private enum CodingKeys: String, CodingKey {
            case name
            case arguments
        }
    }
}