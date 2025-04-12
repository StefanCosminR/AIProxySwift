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
    
    // Fields specific to different event types
    /// The annotation object when type is "response.output_text.annotation.added"
    public let annotation: [String: Any]?
    /// The annotation index when type is "response.output_text.annotation.added"
    public let annotationIndex: Int?
    /// The text content when type is "response.output_text.done"
    public let text: String?
    /// The refusal text when type is "response.refusal.done"
    public let refusal: String?
    /// The arguments text when type is "response.function_call_arguments.done"
    public let arguments: String?
    /// The item object when type is an item-related event
    public let item: [String: Any]?
    /// The part object when type is a content-part event
    public let part: [String: Any]?
    /// The error information when type is "error"
    public let errorCode: String?
    public let errorMessage: String?
    public let errorParam: String?
    
    // Fields for final response chunk
    /// The full response object when the type is a response status event
    /// (response.created, response.in_progress, response.completed, response.failed, response.incomplete)
    public let response: [String: Any]?
    
    /// The ID of the response, extracted from the response object for convenience
    public let responseId: String?
    
    // Fields for tool call events
    /// The function call information if this is a function call chunk
    public let functionCall: FunctionCall?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case delta
        case itemId = "item_id"
        case outputIndex = "output_index"
        case contentIndex = "content_index"
        case annotation
        case annotationIndex = "annotation_index"
        case text
        case refusal
        case arguments
        case item
        case part
        case response
        case functionCall = "function_call"
        case errorCode = "code"
        case errorMessage = "message"
        case errorParam = "param"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the standard fields
        self.type = try container.decode(String.self, forKey: .type)
        self.delta = try container.decodeIfPresent(String.self, forKey: .delta)
        self.itemId = try container.decodeIfPresent(String.self, forKey: .itemId)
        self.outputIndex = try container.decodeIfPresent(Int.self, forKey: .outputIndex)
        self.contentIndex = try container.decodeIfPresent(Int.self, forKey: .contentIndex)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.refusal = try container.decodeIfPresent(String.self, forKey: .refusal)
        self.arguments = try container.decodeIfPresent(String.self, forKey: .arguments)
        self.annotationIndex = try container.decodeIfPresent(Int.self, forKey: .annotationIndex)
        
        // For complex objects, we'll need to decode them as [String: Any]
        // Use JSONSerialization to convert the JSON data to dictionaries
        if let responseData = try? container.decodeIfPresent(Data.self, forKey: .response) {
            self.response = try JSONSerialization.jsonObject(with: responseData) as? [String: Any]
            self.responseId = (self.response?["id"] as? String)
        } else {
            self.response = nil
            self.responseId = nil
        }
        
        if let itemData = try? container.decodeIfPresent(Data.self, forKey: .item) {
            self.item = try JSONSerialization.jsonObject(with: itemData) as? [String: Any]
        } else {
            self.item = nil
        }
        
        if let partData = try? container.decodeIfPresent(Data.self, forKey: .part) {
            self.part = try JSONSerialization.jsonObject(with: partData) as? [String: Any]
        } else {
            self.part = nil
        }
        
        if let annotationData = try? container.decodeIfPresent(Data.self, forKey: .annotation) {
            self.annotation = try JSONSerialization.jsonObject(with: annotationData) as? [String: Any]
        } else {
            self.annotation = nil
        }
        
        // Error fields for error events
        self.errorCode = try container.decodeIfPresent(String.self, forKey: .errorCode)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.errorParam = try container.decodeIfPresent(String.self, forKey: .errorParam)
        
        // Function call for function_call event types
        self.functionCall = try container.decodeIfPresent(FunctionCall.self, forKey: .functionCall)
    }
    
    public static func deserialize(fromLine line: String) -> Self? {
        // Only process lines that start with "data: "
        guard line.hasPrefix("data: ") else {
            logIf(.debug)?.debug("Received unexpected line format from OpenAI Responses API: \(line)")
            return nil
        }
        
        let jsonString = String(line.dropFirst(6))
        
        // Handle all event types with the standard decoder
        guard let chunkJSON = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Self.self, from: chunkJSON)
        } catch {
            // If standard decoding fails, attempt manual JSON parsing for complex structures
            do {
                let json = try JSONSerialization.jsonObject(with: chunkJSON) as? [String: Any]
                guard let type = json?["type"] as? String else { 
                    return nil 
                }
                
                var delta: String? = nil
                var itemId: String? = nil
                var outputIndex: Int? = nil
                var contentIndex: Int? = nil
                var responseDict: [String: Any]? = nil
                var responseId: String? = nil
                var functionCall: FunctionCall? = nil
                
                switch type {
                case "response.output_text.delta":
                    delta = json?["delta"] as? String
                    itemId = json?["item_id"] as? String
                    outputIndex = json?["output_index"] as? Int
                    contentIndex = json?["content_index"] as? Int
                    
                case "response.created", "response.in_progress", "response.completed", 
                     "response.failed", "response.incomplete":
                    responseDict = json?["response"] as? [String: Any]
                    responseId = responseDict?["id"] as? String
                    
                default:
                    break
                }
                
                let chunk = OpenAIResponseChunk(
                    type: type,
                    delta: delta,
                    itemId: itemId,
                    outputIndex: outputIndex,
                    contentIndex: contentIndex,
                    annotation: nil,
                    annotationIndex: nil,
                    text: nil,
                    refusal: nil,
                    arguments: nil,
                    item: nil,
                    part: nil,
                    errorCode: nil,
                    errorMessage: nil,
                    errorParam: nil,
                    response: responseDict,
                    responseId: responseId,
                    functionCall: functionCall
                )
                return chunk
            } catch {
                logIf(.warning)?.warning("Failed to decode OpenAI response chunk with manual parsing: \(error.localizedDescription)")
                logIf(.warning)?.warning("Raw JSON content: \(jsonString)")
                return nil
            }
        }
    }
    
    /// Convenience initializer for manual creation (used in the special handling case)
    private init(
        type: String, 
        delta: String?, 
        itemId: String?, 
        outputIndex: Int?, 
        contentIndex: Int?,
        annotation: [String: Any]?,
        annotationIndex: Int?,
        text: String?,
        refusal: String?,
        arguments: String?,
        item: [String: Any]?,
        part: [String: Any]?,
        errorCode: String?,
        errorMessage: String?,
        errorParam: String?,
        response: [String: Any]?, 
        responseId: String?,
        functionCall: FunctionCall?
    ) {
        self.type = type
        self.delta = delta
        self.itemId = itemId
        self.outputIndex = outputIndex
        self.contentIndex = contentIndex
        self.annotation = annotation
        self.annotationIndex = annotationIndex
        self.text = text
        self.refusal = refusal
        self.arguments = arguments
        self.item = item
        self.part = part
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.errorParam = errorParam
        self.response = response
        self.responseId = responseId
        self.functionCall = functionCall
    }
    
    // MARK: - Convenience accessors
    
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
    
    /// Convenience method to check if there was an error
    public var isFailed: Bool {
        return type == "response.failed" || type == "error"
    }
    
    /// Convenience method to check if the response is incomplete
    public var isIncomplete: Bool {
        return type == "response.incomplete"
    }
    
    /// Get the response ID from the completed response
    public var completedResponseId: String? {
        if type.starts(with: "response.") && response != nil {
            return responseId
        }
        return nil
    }
    
    /// Get the error message if this is an error chunk
    public var error: String? {
        if type == "error" {
            return errorMessage
        } else if type == "response.failed", let errorDict = response?["error"] as? [String: Any] {
            return errorDict["message"] as? String
        }
        return nil
    }
    
    /// Get the reason for the incomplete response if available
    public var incompleteReason: String? {
        if type == "response.incomplete", 
           let details = response?["incomplete_details"] as? [String: Any] {
            return details["reason"] as? String
        }
        return nil
    }
    
    /// Convenience method to get the full completed text when type is "response.output_text.done"
    public var completedText: String? {
        if type == "response.output_text.done" {
            return text
        }
        return nil
    }
}

/// Structure to represent a function call in the OpenAI streaming response
public struct FunctionCall: Decodable {
    public let name: String
    public let arguments: String
}
