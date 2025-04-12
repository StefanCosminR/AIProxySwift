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
    public let response: [String: Any]?
    /// The ID of the response, extracted from the response object for convenience
    public let responseId: String?
    
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the standard fields
        self.type = try container.decode(String.self, forKey: .type)
        self.delta = try container.decodeIfPresent(String.self, forKey: .delta)
        self.itemId = try container.decodeIfPresent(String.self, forKey: .itemId)
        self.outputIndex = try container.decodeIfPresent(Int.self, forKey: .outputIndex)
        self.contentIndex = try container.decodeIfPresent(Int.self, forKey: .contentIndex)
        self.functionCall = try container.decodeIfPresent(FunctionCall.self, forKey: .functionCall)
        
        // For the response field, handle it specially
        if type == "response.completed" {
            // Use JSONSerialization for flexible handling of the response object
            if let responseData = try container.decodeIfPresent(Data.self, forKey: .response) {
                self.response = try JSONSerialization.jsonObject(with: responseData) as? [String: Any]
                
                // Extract the response ID for convenience
                if let responseDict = self.response, let id = responseDict["id"] as? String {
                    self.responseId = id
                } else {
                    self.responseId = nil
                }
            } else {
                self.response = nil
                self.responseId = nil
            }
        } else {
            self.response = nil
            self.responseId = nil
        }
    }
    
    /// Helper method to deserialize from a line of streaming data
    public static func deserialize(fromLine line: String) -> Self? {
        // Only process lines that start with "data: "
        guard line.hasPrefix("data: ") else {
            logIf(.debug)?.debug("Received unexpected line format from OpenAI Responses API: \(line)")
            return nil
        }
        
        let jsonString = String(line.dropFirst(6))
        
        // Special handling for the completed response type
        if jsonString.contains("\"type\":\"response.completed\"") {
            do {
                guard let chunkJSON = jsonString.data(using: .utf8) else {
                    return nil
                }
                
                // Parse the JSON manually to handle the nested response object
                let json = try JSONSerialization.jsonObject(with: chunkJSON) as? [String: Any]
                
                guard let type = json?["type"] as? String, type == "response.completed" else {
                    return nil
                }
                
                var chunk = OpenAIResponseChunk(type: type, delta: nil, itemId: nil, 
                                              outputIndex: nil, contentIndex: nil, 
                                              response: json?["response"] as? [String: Any], 
                                              responseId: (json?["response"] as? [String: Any])?["id"] as? String, 
                                              functionCall: nil)
                return chunk
            } catch {
                logIf(.warning)?.warning("Failed to decode OpenAI completion response: \(error.localizedDescription)")
                logIf(.warning)?.warning("Raw JSON content: \(jsonString)")
                return nil
            }
        }
        
        // Handle other event types with the standard decoder
        guard let chunkJSON = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Self.self, from: chunkJSON)
        } catch {
            logIf(.warning)?.warning("Failed to decode OpenAI response chunk: \(error.localizedDescription)")
            logIf(.warning)?.warning("Raw JSON content: \(jsonString)")
            return nil
        }
    }
    
    /// Convenience initializer for manual creation (used in the special handling case)
    private init(
        type: String, 
        delta: String?, 
        itemId: String?, 
        outputIndex: Int?, 
        contentIndex: Int?, 
        response: [String: Any]?, 
        responseId: String?,
        functionCall: FunctionCall?
    ) {
        self.type = type
        self.delta = delta
        self.itemId = itemId
        self.outputIndex = outputIndex
        self.contentIndex = contentIndex
        self.response = response
        self.responseId = responseId
        self.functionCall = functionCall
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
    
    /// Get the response ID from the completed response
    public var completedResponseId: String? {
        if isCompleted {
            return responseId
        }
        return nil
    }
    
    /// Represents a function call in a streamed response
    public struct FunctionCall: Decodable {
        /// The name of the function to call
        public let name: String?
        /// The arguments to pass to the function
        public let arguments: String?
    }
}