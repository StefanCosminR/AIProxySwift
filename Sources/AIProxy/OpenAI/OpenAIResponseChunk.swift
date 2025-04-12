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
    /// The type of event in the streaming response
    public let type: String
    
    // Fields for response.output_text.delta events
    /// The delta text content when type is "response.output_text.delta"
    public let delta: String?
    /// The ID of the item this delta belongs to
    public let itemId: String?
    /// The index of the output this delta belongs to
    public let outputIndex: Int?
    /// The index of the content this delta belongs to
    public let contentIndex: Int?
    
    // Fields for final response chunk
    /// The full response object when the type is "response.completed"
    public let response: OpenAIResponse?
    
    // Fields for tool call events (for future support)
    /// The function call information if this is a function call chunk
    public let functionCall: FunctionCall?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case delta
        case itemId = "item_id"
        case outputIndex = "output_index"
        case contentIndex = "content_index"
        case response
        case functionCall = "function_call"
    }
    
    /// Helper method to deserialize from a line of streaming data
    public static func deserialize(fromLine line: String) -> Self? {
        // Only process lines that start with "data: "
        guard line.hasPrefix("data: "),
              let chunkJSON = line.dropFirst(6).data(using: .utf8) else {
            logIf(.debug)?.debug("Received unexpected line from OpenAI Responses API: \(line)")
            return nil
        }
        
        do {
            return try JSONDecoder().decode(Self.self, from: chunkJSON)
        } catch {
            logIf(.warning)?.warning("Failed to decode OpenAI response chunk: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Convenience method to get text content from a delta event
    public var textDelta: String? {
        if type == "response.output_text.delta" {
            return delta
        }
        return nil
    }
    
    /// Convenience method to check if this is the final chunk
    public var isCompleted: Bool {
        return type == "response.completed"
    }
    
    /// Represents a function call in a streamed response
    public struct FunctionCall: Decodable {
        /// The name of the function to call
        public let name: String?
        /// The arguments to pass to the function
        public let arguments: String?
    }
}