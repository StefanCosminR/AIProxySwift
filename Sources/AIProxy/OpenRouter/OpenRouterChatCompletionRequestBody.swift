//
//  OpenRouterChatCompletionRequestBody.swift
//  AIProxy
//
//  Created by Lou Zell on 12/30/24.
//

import Foundation

/// OpenRouter applies some of its own special parameters to the otherwise general purpose chat completion request.
/// Search this file for 'OpenRouter-specific' for parameters that you may have not encountered with other chat completions.
///
/// Chat completion request body. See the OpenRouter reference for available fields.
/// https://openrouter.ai/docs/api-reference/chat-completion
public struct OpenRouterChatCompletionRequestBody: Encodable {
    // Required

    /// A list of messages comprising the conversation so far
    public let messages: [Message]

    // Optional

    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
    /// See more information here: https://platform.openai.com/docs/guides/text-generation
    /// Defaults to 0
    public let frequencyPenalty: Double?

    /// Deprecated! See the `reasoning` property instead.
    /// Include reasoning content in the response. Useful to understand how a reasoning model arrives at its response.
    public let includeReasoning: Bool?

    /// Modify the likelihood of specified tokens appearing in the completion.
    /// Accepts an object that maps tokens (specified by their token ID in the tokenizer) to an associated bias value from -100 to 100. Mathematically, the bias is added to the logits generated by the model prior to sampling. The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
    public let logitBias: [String: Double]?

    /// Whether to return log probabilities of the output tokens or not. If true, returns the log probabilities of each output token returned in the `content` of `message`.
    /// Defaults to false
    public let logprobs: Bool?

    /// An upper bound for the number of tokens that can be generated for a completion, including visible output tokens and reasoning tokens: https://platform.openai.com/docs/guides/reasoning
    public let maxTokens: Int?

    /// Developer-defined tags and values used for filtering completions in the dashboard.
    /// Dashboard: https://platform.openai.com/chat-completions
    public let metadata: [String: AIProxyJSONValue]?

    /// Set this with the model ID of the model you'd like to use.
    /// There are handy copy icons in this list for copying a model ID to clipboard:
    /// https://openrouter.ai/models
    ///
    /// If this is left unset, OpenRouter will use your default choice which you can find here:
    /// https://openrouter.ai/settings/preferences
    public let model: String?

    // OpenRouter-specific parameter
    // See "Model Routing" section: openrouter.ai/docs/model-routing
    public let models: [String]?

    /// How many chat completion choices to generate for each input message. Note that you will be charged based on the number of generated tokens across all of the choices. Keep `n` as `1` to minimize costs.
    /// Defaults to 1
    public let n: Int?

    /// Whether to enable parallel function calling during tool use.
    /// https://platform.openai.com/docs/guides/function-calling#configuring-parallel-function-calling
    /// Defaults to true
    public let parallelToolCalls: Bool?

    // Reduce latency by providing the model with a predicted output
    // https://platform.openai.com/docs/guides/latency-optimization#use-predicted-outputs
    public let prediction: Prediction?

    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
    /// More information about frequency and presence penalties: https://platform.openai.com/docs/guides/text-generation
    /// Defaults to 0
    public let presencePenalty: Double?

    /// OpenRouter-specific parameter
    /// See "Provider Routing" section: openrouter.ai/docs/provider-routing
    public let provider: ProviderPreferences?

    /// Configuration for model reasoning/thinking tokens
    public let reasoning: Reasoning?

    /// Acceptable range is (0, 2]
    public let repetitionPenalty: Double?

    /// Specifies the format that the model must output.
    /// Set to `.jsonObject` for json mode.
    /// Set to `.jsonSchema` for structured outputs.
    /// See this guide for structured outputs: https://openrouter.ai/docs/structured-outputs
    public let responseFormat: ResponseFormat?

    // OpenRouter-specific parameter
    // See "Model Routing" section: https://openrouter.ai/docs/model-routing
    public let route: Route?

    /// This feature is in Beta. If specified, our system will make a best effort to sample deterministically, such that repeated requests with the same `seed` and parameters should return the same result. Determinism is not guaranteed, and you should refer to the `systemFingerprint` response parameter to monitor changes in the backend.
    public let seed: Int?

    /// Up to 4 sequences where the API will stop generating further tokens.
    public let stop: [String]?

    /// Whether or not to store the output of this chat completion request for use in our model distillation or evals products.
    /// Model distillation: https://platform.openai.com/docs/guides/distillation
    /// Evals: https://platform.openai.com/docs/guides/evals
    /// Deafults to false
    public let store: Bool?

    /// If set, partial message deltas will be sent. Using the `OpenAIService.streamingChatCompletionRequest`
    /// method is the easiest way to use streaming chats.
    public var stream: Bool?

    /// Options for streaming response. Only set this when you set stream: true
    public var streamOptions: StreamOptions?

    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the
    /// output more random, while lower values like 0.2 will make it more focused and
    /// deterministic.
    ///
    /// We generally recommend altering this or `top_p` but not both.
    ///
    /// If not set, OpenAI defaults this value to 1.
    public let temperature: Double?

    /// A list of tools the model may call. Currently, only functions are supported as a tool. Use this to
    /// provide a list of functions the model may generate JSON inputs for. A max of 128 functions are
    /// supported.
    public let tools: [Tool]?

    /// Controls which (if any) tool is called by the model.
    public let toolChoice: ToolChoice?

    /// Consider only the top tokens with "sufficiently high" probabilities based on the probability of the most likely token.
    /// Think of it like a dynamic Top-P. A lower Top-A value focuses the choices based on the highest probability token but
    /// with a narrower scope. A higher Top-A value does not necessarily affect the creativity of the output, but rather
    /// refines the filtering process based on the maximum probability.
    ///
    /// Acceptable range is [0, 1.0]
    /// Default to 0
    public let topA: Double?

    /// An integer between 0 and 20 specifying the number of most likely tokens to return at each token position, each with an associated log probability. `logprobs` must be set to `true` if this parameter is used.
    public let topLogprobs: Int?

    /// An alternative to sampling with `temperature`, called nucleus sampling, where the model
    /// considers the results of the tokens with `top_p` probability mass. So 0.1 means only the
    /// tokens comprising the top 10% probability mass are considered.
    ///
    /// We generally recommend altering this or `temperature` but not both.
    /// If not set, OpenAI defaults this value to 1
    public let topP: Double?

    /// OpenRouter-specific parameter
    /// See "Prompt Transforms" section: openrouter.ai/docs/transforms
    public let transforms: [String]?

    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// Learn more: https://platform.openai.com/docs/guides/safety-best-practices#end-user-ids
    public let user: String?

    private enum CodingKeys: String, CodingKey {
        // required
        case messages

        // optional
        case frequencyPenalty = "frequency_penalty"
        case includeReasoning = "include_reasoning"
        case logitBias = "logit_bias"
        case logprobs
        case maxTokens = "max_tokens"
        case metadata
        case model
        case models
        case n
        case parallelToolCalls = "parallel_tool_calls"
        case prediction
        case provider
        case presencePenalty = "presence_penalty"
        case reasoning
        case repetitionPenalty = "repetition_penalty"
        case responseFormat = "response_format"
        case route
        case seed
        case stop
        case store
        case stream
        case streamOptions = "stream_options"
        case temperature
        case tools
        case toolChoice = "tool_choice"
        case topA = "top_a"
        case topLogprobs = "top_logprobs"
        case topP = "top_p"
        case transforms
        case user
    }

    // This memberwise initializer is autogenerated.
    // To regenerate, use `cmd-shift-a` > Generate Memberwise Initializer
    // To format, place the cursor in the initializer's parameter list and use `ctrl-m`
    public init(
        messages: [OpenRouterChatCompletionRequestBody.Message],
        frequencyPenalty: Double? = nil,
        includeReasoning: Bool? = nil,
        logitBias: [String : Double]? = nil,
        logprobs: Bool? = nil,
        maxTokens: Int? = nil,
        metadata: [String : AIProxyJSONValue]? = nil,
        model: String? = nil,
        models: [String]? = nil,
        n: Int? = nil,
        parallelToolCalls: Bool? = nil,
        prediction: OpenRouterChatCompletionRequestBody.Prediction? = nil,
        presencePenalty: Double? = nil,
        provider: OpenRouterChatCompletionRequestBody.ProviderPreferences? = nil,
        reasoning: Reasoning? = nil,
        repetitionPenalty: Double? = nil,
        responseFormat: OpenRouterChatCompletionRequestBody.ResponseFormat? = nil,
        route: OpenRouterChatCompletionRequestBody.Route? = nil,
        seed: Int? = nil,
        stop: [String]? = nil,
        store: Bool? = nil,
        stream: Bool? = nil,
        streamOptions: OpenRouterChatCompletionRequestBody.StreamOptions? = nil,
        temperature: Double? = nil,
        tools: [OpenRouterChatCompletionRequestBody.Tool]? = nil,
        toolChoice: OpenRouterChatCompletionRequestBody.ToolChoice? = nil,
        topA: Double? = nil,
        topLogprobs: Int? = nil,
        topP: Double? = nil,
        transforms: [String]? = nil,
        user: String? = nil
    ) {
        self.messages = messages
        self.frequencyPenalty = frequencyPenalty
        self.includeReasoning = includeReasoning
        self.logitBias = logitBias
        self.logprobs = logprobs
        self.maxTokens = maxTokens
        self.metadata = metadata
        self.model = model
        self.models = models
        self.n = n
        self.parallelToolCalls = parallelToolCalls
        self.prediction = prediction
        self.presencePenalty = presencePenalty
        self.provider = provider
        self.reasoning = reasoning
        self.repetitionPenalty = repetitionPenalty
        self.responseFormat = responseFormat
        self.route = route
        self.seed = seed
        self.stop = stop
        self.store = store
        self.stream = stream
        self.streamOptions = streamOptions
        self.temperature = temperature
        self.tools = tools
        self.toolChoice = toolChoice
        self.topA = topA
        self.topLogprobs = topLogprobs
        self.topP = topP
        self.transforms = transforms
        self.user = user
    }
}

// MARK: - RequestBody.Route
extension OpenRouterChatCompletionRequestBody {
    public enum Route: String, Encodable {
        case fallback
    }
}

// MARK: - RequestBody.Message
extension OpenRouterChatCompletionRequestBody {
    public enum Message: Encodable {
        /// Assistant message
        /// - Parameters:
        ///   - content: The contents of the assistant message
        ///   - name: An optional name for the participant. Provides the model information to differentiate
        ///           between participants of the same role.
        case assistant(content: AssistantContent, name: String? = nil)

        /// A system message
        /// - Parameters:
        ///   - content: The contents of the system message.
        ///   - name: An optional name for the participant. Provides the model information to differentiate
        ///           between participants of the same role.
        case system(content: SystemContent, name: String? = nil)

        /// A user message
        /// - Parameters:
        ///   - content: The contents of the user message.
        ///   - name: An optional name for the participant. Provides the model information to differentiate
        ///           between participants of the same role.
        case user(content: UserContent, name: String? = nil)

        private enum RootKey: String, CodingKey {
            case content
            case role
            case name
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: RootKey.self)
            switch self {
            case .assistant(let content, let name):
                try container.encode(content, forKey: .content)
                try container.encode("assistant", forKey: .role)
                if let name = name {
                    try container.encode(name, forKey: .name)
                }
            case .system(let content, let name):
                try container.encode(content, forKey: .content)
                try container.encode("system", forKey: .role)
                if let name = name {
                    try container.encode(name, forKey: .name)
                }
            case .user(let content, let name):
                try container.encode(content, forKey: .content)
                try container.encode("user", forKey: .role)
                if let name = name {
                    try container.encode(name, forKey: .name)
                }
            }
        }
    }
}

// MARK: - RequestBody.Message.AssistantContent
extension OpenRouterChatCompletionRequestBody.Message {
    /// Assistant messages can consist of a single string or an array of strings
    public enum AssistantContent: Encodable {
        case text(String)

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .text(let text):
                try container.encode(text)
            }
        }
    }
}


// MARK: - RequestBody.Message.SystemContent
extension OpenRouterChatCompletionRequestBody.Message {
    /// System messages can consist of a single string or an array of strings
    public enum SystemContent: Encodable {
        case text(String)

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .text(let text):
                try container.encode(text)
            }
        }
    }
}


// MARK: - RequestBody.Message.UserContent
extension OpenRouterChatCompletionRequestBody.Message {
    /// User messages can consist of a single string or an array of parts, each part capable of containing a
    /// string or image
    public enum UserContent: Encodable {
        /// The text contents of the message.
        case text(String)

        /// An array of content parts. You can pass multiple images by adding multiple imageURL content parts.
        /// Image input is only supported when using the gpt-4o model.
        case parts([Part])

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .text(let text):
                try container.encode(text)
            case .parts(let parts):
                try container.encode(parts)
            }
        }
    }
}

// MARK: - RequestBody.Message.UserContent.Part
extension OpenRouterChatCompletionRequestBody.Message.UserContent {
    public enum Part: Encodable {
        /// The text content.
        case text(String)

        /// The URL is a "local URL" containing base64 encoded image data. See the helper `AIProxy.openaiEncodedImage`
        /// to construct this URL.
        ///
        /// By controlling the detail parameter, which has three options, low, high, or auto, you have control over
        /// how the model processes the image and generates its textual understanding. By default, the model will use
        /// the auto setting which will look at the image input size and decide if it should use the low or high setting.
        ///
        /// "low" will enable the "low res" mode. The model will receive a low-res 512px x 512px version of the image, and
        /// represent the image with a budget of 85 tokens. This allows the API to return faster responses and consume
        /// fewer input tokens for use cases that do not require high detail.
        ///
        /// "high" will enable "high res" mode, which first allows the model to first see the low res image (using 85
        /// tokens) and then creates detailed crops using 170 tokens for each 512px x 512px tile.
        case imageURL(URL, detail: ImageDetail? = nil)

        private enum RootKey: String, CodingKey {
            case type
            case text
            case imageURL = "image_url"
        }

        private enum ImageKey: CodingKey {
            case url
            case detail
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: RootKey.self)
            switch self {
            case .text(let text):
                try container.encode("text", forKey: .type)
                try container.encode(text, forKey: .text)
            case .imageURL(let url, let detail):
                try container.encode("image_url", forKey: .type)
                var nestedContainer = container.nestedContainer(keyedBy: ImageKey.self, forKey: .imageURL)
                try nestedContainer.encode(url, forKey: .url)
                if let detail = detail {
                    try nestedContainer.encode(detail, forKey: .detail)
                }
            }
        }
    }
}

// MARK: - RequestBody.Message.UserContent.Part.ImageDetail
extension OpenRouterChatCompletionRequestBody.Message.UserContent.Part {
    public enum ImageDetail: String, Encodable {
        case auto
        case low
        case high
    }
}

// MARK: - RequestBody.Reasoning
extension OpenRouterChatCompletionRequestBody {
    public struct Reasoning: Encodable {
        public enum Effort: String, Encodable {
            case low
            case medium
            case high
        }

        /// OpenAI-style reasoning effort setting
        public let effort: Effort?

        /// Non-OpenAI-style reasoning effort setting. Cannot be used simultaneously with effort.
        public let maxTokens: Int?

        /// Whether to exclude reasoning from the response
        /// Defaults to false
        public let exclude: Bool?

        public init(
            effort: OpenRouterChatCompletionRequestBody.Reasoning.Effort? = nil,
            maxTokens: Int? = nil,
            exclude: Bool? = nil
        ) {
            self.effort = effort
            self.maxTokens = maxTokens
            self.exclude = exclude
        }
    }
}


// MARK: - RequestBody.ResponseFormat
extension OpenRouterChatCompletionRequestBody {
    /// An object specifying the format that the model must output. Compatible with GPT-4o, GPT-4o mini, GPT-4
    /// Turbo and all GPT-3.5 Turbo models newer than gpt-3.5-turbo-1106.
    public enum ResponseFormat: Encodable {

        /// Enables JSON mode, which ensures the message the model generates is valid JSON. Note, if you want to
        /// supply your own schema use `jsonSchema` instead.
        ///
        /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a
        /// system or user message. Without this, the model may generate an unending stream of whitespace until
        /// the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request.
        /// Also note that the message content may be partially cut off if finish_reason="length", which indicates
        /// the generation exceeded max_tokens or the conversation exceeded the max context length.
        case jsonObject

        /// Enables Structured Outputs which ensures the model will match your supplied JSON schema.
        /// Learn more in the Structured Outputs guide: https://platform.openai.com/docs/guides/structured-outputs
        ///
        /// - Parameters:
        ///   - name: The name of the response format. Must be a-z, A-Z, 0-9, or contain underscores and dashes,
        ///           with a maximum length of 64.
        ///
        ///   - description: A description of what the response format is for, used by the model to determine how
        ///                  to respond in the format.
        ///
        ///   - schema: The schema for the response format, described as a JSON Schema object.
        ///
        ///   - strict: Whether to enable strict schema adherence when generating the output. If set to true, the
        ///             model will always follow the exact schema defined in the schema field. Only a subset of JSON Schema
        ///             is supported when strict is true. To learn more, read the Structured Outputs guide.
        case jsonSchema(
            name: String,
            description: String? = nil,
            schema: [String: AIProxyJSONValue]? = nil,
            strict: Bool? = nil
        )

        /// Instructs the model to produce text only.
        case text

        private enum RootKey: String, CodingKey {
            case type
            case jsonSchema = "json_schema"
        }

        private enum SchemaKey: String, CodingKey {
            case description
            case name
            case schema
            case strict
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: RootKey.self)
            switch self {
            case .jsonObject:
                try container.encode("json_object", forKey: .type)
            case .jsonSchema(
                name: let name,
                description: let description,
                schema: let schema,
                strict: let strict
            ):
                try container.encode("json_schema", forKey: .type)
                var nestedContainer = container.nestedContainer(
                    keyedBy: SchemaKey.self,
                    forKey: .jsonSchema
                )
                try nestedContainer.encode(name, forKey: .name)
                try nestedContainer.encodeIfPresent(description, forKey: .description)
                try nestedContainer.encodeIfPresent(schema, forKey: .schema)
                try nestedContainer.encodeIfPresent(strict, forKey: .strict)
            case .text:
                try container.encode("text", forKey: .type)
            }
        }
    }
}

// MARK: - RequestBody.StreamOptions
extension OpenRouterChatCompletionRequestBody {
    public struct StreamOptions: Encodable {
       /// If set, an additional chunk will be streamed before the data: [DONE] message.
       /// The usage field on this chunk shows the token usage statistics for the entire request,
       /// and the choices field will always be an empty array. All other chunks will also include
       /// a usage field, but with a null value.
       let includeUsage: Bool

       private enum CodingKeys: String, CodingKey {
           case includeUsage = "include_usage"
       }
    }
}

// MARK: - RequestBody.Tool
extension OpenRouterChatCompletionRequestBody {
    public enum Tool: Encodable {

        /// A function that chatGPT can instruct us to call when appropriate
        ///
        /// - Parameters:
        ///   - name: The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and
        ///           dashes, with a maximum length of 64.
        ///
        ///   - description: A description of what the function does, used by the model to choose when and how to
        ///                  call the function.
        ///
        ///   - parameters: The parameters the functions accepts, described as a JSON Schema object. See the guide
        ///                 for examples, and the JSON Schema reference for documentation about the format.
        ///                 Omitting parameters defines a function with an empty parameter list.
        ///
        ///   - strict: Whether to enable strict schema adherence when generating the function call. If set to
        ///             true, the model will follow the exact schema defined in the parameters field. Only a subset of JSON
        ///             Schema is supported when strict is true. Learn more about Structured Outputs in the function calling
        ///             guide: https://platform.openai.com/docs/api-reference/chat/docs/guides/function-calling
        case function(
            name: String,
            description: String?,
            parameters: [String: AIProxyJSONValue]?,
            strict: Bool?
        )

        private enum RootKey: CodingKey {
            case type
            case function
        }

        private enum FunctionKey: CodingKey {
            case description
            case name
            case parameters
            case strict
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: RootKey.self)
            switch self {
            case .function(
                name: let name,
                description: let description,
                parameters: let parameters,
                strict: let strict
            ):
                try container.encode("function", forKey: .type)
                var functionContainer = container.nestedContainer(
                    keyedBy: FunctionKey.self,
                    forKey: .function
                )
                try functionContainer.encode(name, forKey: .name)
                try functionContainer.encodeIfPresent(description, forKey: .description)
                try functionContainer.encodeIfPresent(parameters, forKey: .parameters)
                try functionContainer.encodeIfPresent(strict, forKey: .strict)
            }
        }
    }
}

// MARK: - RequestBody.ToolChoice
extension OpenRouterChatCompletionRequestBody {
    /// Controls which (if any) tool is called by the model.
    public enum ToolChoice: Encodable {

        /// The model will not call any tool and instead generates a message.
        /// This is the default when no tools are present in the request body
        case none

        /// The model can pick between generating a message or calling one or more tools.
        /// This is the default when tools are present in the request body
        case auto

        /// The model must call one or more tools
        case required

        /// Forces the model to call a specific tool
        case specific(functionName: String)

        private enum RootKey: CodingKey {
            case type
            case function
        }

        private enum FunctionKey: CodingKey {
            case name
        }

        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .none:
                var container = encoder.singleValueContainer()
                try container.encode("none")
            case .auto:
                var container = encoder.singleValueContainer()
                try container.encode("auto")
            case .required:
                var container = encoder.singleValueContainer()
                try container.encode("required")
            case .specific(let functionName):
                var container = encoder.container(keyedBy: RootKey.self)
                try container.encode("function", forKey: .type)
                var functionContainer = container.nestedContainer(
                    keyedBy: FunctionKey.self,
                    forKey: .function
                )
                try functionContainer.encode(functionName, forKey: .name)
            }
        }
    }
}


// MARK: - RequestBody.Prediction
extension OpenRouterChatCompletionRequestBody {
    public struct Prediction: Encodable {
        let content: String

        private enum CodingKeys: CodingKey {
            case content
            case type
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.content, forKey: .content)
            try container.encode("content", forKey: .type)
        }
    }
}

// MARK: - RequestBody.ProviderPreferences
extension OpenRouterChatCompletionRequestBody {
    /// https://openrouter.ai/docs/provider-routing
    public struct ProviderPreferences: Encodable {
        public enum Quantization: String, Encodable {
            case int4 = "int4"
            case int8 = "int8"
            case fp6 = "fp6"
            case fp8 = "fp8"
            case fp16 = "fp16"
            case bf16 = "bf16"
            case unknown = "unknown"
        }
        public enum DataCollection: String, Encodable {
            case allow
            case deny

        }
        /// Whether to allow backup providers to serve requests
        /// - true: (default) when the primary provider (or your custom providers in \"order\") is unavailable, use the next best provider.
        /// - false: use only the primary/custom provider, and return the upstream error if it's unavailable.
        public let allowFallbacks: Bool?

        /// Data collection setting. If no available model provider meets the requirement, your request will return an error.
        /// - allow: (default) allow providers which store user data non-transiently and may train on it
        /// - deny: use only providers which do not collect user data.
        public let dataCollection: DataCollection?

        /// List of provider names to ignore. If provided, this list is merged with your account-wide ignored provider settings for this request.
        public let ignore: [String]?

        /// An ordered list of provider names. The router will attempt to use the first provider in the subset of this list that supports
        /// your requested model, and fall back to the next if it is unavailable.
        /// If no providers are available, the request will fail with an error message.
        public let order: [String]?

        /// A list of quantization levels to filter the provider by.
        public let quantizations: [Quantization]?

        /// Whether to filter providers to only those that support the parameters you've provided.
        /// If this setting is omitted or set to false, then providers will receive only the parameters they support, and ignore the rest.
        public let requireParameters: Bool?

        private enum CodingKeys: String, CodingKey {
            case allowFallbacks = "allow_fallbacks"
            case dataCollection = "data_collection"
            case ignore
            case order
            case quantizations
            case requireParameters = "require_parameters"
        }

        // This memberwise initializer is autogenerated.
        // To regenerate, use `cmd-shift-a` > Generate Memberwise Initializer
        // To format, place the cursor in the initializer's parameter list and use `ctrl-m`
        public init(
            allowFallbacks: Bool? = nil,
            dataCollection: OpenRouterChatCompletionRequestBody.ProviderPreferences.DataCollection? = nil,
            ignore: [String]? = nil,
            order: [String]? = nil,
            quantizations: [OpenRouterChatCompletionRequestBody.ProviderPreferences.Quantization]? = nil,
            requireParameters: Bool? = nil
        ) {
            self.allowFallbacks = allowFallbacks
            self.dataCollection = dataCollection
            self.ignore = ignore
            self.order = order
            self.quantizations = quantizations
            self.requireParameters = requireParameters
        }
    }
}
