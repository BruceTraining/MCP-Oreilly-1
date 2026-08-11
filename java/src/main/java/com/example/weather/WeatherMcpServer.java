package com.example.weather;

import io.modelcontextprotocol.json.McpJsonDefaults;
import io.modelcontextprotocol.json.McpJsonMapper;
import io.modelcontextprotocol.server.McpServer;
import io.modelcontextprotocol.server.McpServerFeatures;
import io.modelcontextprotocol.server.McpSyncServer;
import io.modelcontextprotocol.server.transport.StdioServerTransportProvider;
import io.modelcontextprotocol.spec.McpSchema;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

/**
 * Weather MCP Server — a Model Context Protocol (MCP) server built with the
 * official MCP Java SDK, version 2.0.
 *
 * <p>This server exposes two kinds of MCP capabilities to a client such as
 * Claude Desktop:</p>
 * <ul>
 *   <li><b>A tool</b> ({@code get_weather}) that the model can call to fetch
 *       weather for a city. The data is currently hardcoded (44&deg;F) so the
 *       course can focus on the protocol rather than on a weather API.</li>
 *   <li><b>Two prompts</b> ({@code weather_inquiry} and
 *       {@code weather_travel_advice}) — reusable, parameterized message
 *       templates that the <i>user</i> can invoke from the client UI.</li>
 * </ul>
 *
 * <p>Communication happens over the <b>STDIO transport</b>: the client (Claude
 * Desktop) launches this program as a child process and exchanges JSON-RPC 2.0
 * messages over stdin/stdout. For that reason, nothing in this program may
 * ever print to {@code System.out} — all logging goes to {@code System.err}.</p>
 *
 * <h2>What changed from the 0.x SDK?</h2>
 * <ul>
 *   <li>JSON handling: the SDK now owns serialization behind its
 *       {@link McpJsonMapper} abstraction ({@link McpJsonDefaults#getMapper()}),
 *       instead of us passing in a Jackson {@code ObjectMapper}.</li>
 *   <li>Construction: schema records ({@code Tool}, {@code Prompt},
 *       {@code CallToolResult}, ...) are created through <i>builders</i>;
 *       the old public constructors were removed or deprecated.</li>
 *   <li>Tool handlers now receive a typed {@code CallToolRequest} instead of a
 *       raw {@code Map} of arguments.</li>
 *   <li>The server automatically validates incoming tool arguments against the
 *       tool's JSON Schema before our handler runs, so handlers can trust
 *       required parameters are present.</li>
 * </ul>
 *
 * @see <a href="https://java.sdk.modelcontextprotocol.io/">MCP Java SDK documentation</a>
 * @see <a href="https://modelcontextprotocol.io/">Model Context Protocol specification</a>
 */
public class WeatherMcpServer {

    /**
     * The SDK's default JSON mapper (Jackson 3 under the hood, but the SDK
     * hides that detail). It is used in two places:
     * <ol>
     *   <li>by the STDIO transport, to serialize/deserialize JSON-RPC messages;</li>
     *   <li>by the {@code Tool} builder, to parse our JSON Schema string.</li>
     * </ol>
     */
    private static final McpJsonMapper JSON_MAPPER = McpJsonDefaults.getMapper();

    /**
     * Main entry point. Wires up the transport, registers the tool and the
     * prompts, and then keeps the process alive so the transport can keep
     * serving requests.
     *
     * @param args command line arguments (not used)
     */
    public static void main(String[] args) {
        try {
            // 1. Transport: STDIO. The client launches us as a subprocess and
            //    speaks JSON-RPC over our stdin/stdout. The transport provider
            //    needs a JSON mapper to encode/decode those messages.
            StdioServerTransportProvider transportProvider =
                    new StdioServerTransportProvider(JSON_MAPPER);

            // 2. Server: the sync (blocking) facade. Handlers are plain
            //    functions that return results directly — no reactive types.
            //    "capabilities" advertises to the client, during the MCP
            //    initialize handshake, which protocol features we support.
            McpSyncServer server = McpServer.sync(transportProvider)
                    .serverInfo("weather-server", "2.0.0")
                    .capabilities(McpSchema.ServerCapabilities.builder()
                            .tools(true)    // we expose callable tools
                            .prompts(true)  // we expose prompt templates
                            .build())
                    .tools(createWeatherToolSpecification())
                    .prompts(createWeatherPromptSpecifications())
                    .build();

            // stdout is reserved for the protocol, so log to stderr only.
            System.err.println("Weather MCP Server (SDK 2.0) started — listening on STDIO");
            System.err.println("Registered tool: get_weather; prompts: weather_inquiry, weather_travel_advice");

            // 3. Stay alive. The transport reads stdin on a background thread;
            //    parking the main thread here keeps the JVM running until the
            //    client closes the pipe or kills the process.
            Thread.currentThread().join();

            // (Unreachable in practice, but this is how you would shut down
            // deliberately: server.closeGracefully();)
            server.closeGracefully();

        } catch (Exception e) {
            // Errors also go to stderr, never stdout.
            System.err.println("Failed to start Weather MCP Server: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    /**
     * Builds the {@code get_weather} tool specification.
     *
     * <p>A tool specification pairs two things:</p>
     * <ul>
     *   <li>the <b>tool definition</b> — name, description, and a JSON Schema
     *       describing the arguments. This is what the client shows the model
     *       so it knows the tool exists and how to call it;</li>
     *   <li>the <b>call handler</b> — the Java code that runs when the model
     *       actually invokes the tool.</li>
     * </ul>
     *
     * <p>SDK 2.0 note: the server validates incoming arguments against
     * {@code inputSchema} <i>before</i> invoking our handler (this default can
     * be turned off with {@code validateToolInputs(false)} on the server
     * builder). A call that is missing {@code city} is rejected by the SDK, so
     * the handler no longer needs the defensive argument-checking helper the
     * 0.x version of this server carried.</p>
     *
     * @return the complete tool specification, ready to register on the server
     */
    private static McpServerFeatures.SyncToolSpecification createWeatherToolSpecification() {

        // JSON Schema (draft 2020-12) for the tool's arguments. Written as a
        // plain string for readability; Tool.builder parses and validates it.
        String inputSchema = """
                {
                    "type": "object",
                    "properties": {
                        "city": {
                            "type": "string",
                            "description": "Name of the city to get weather for (e.g., 'New York', 'London', 'Tokyo')"
                        }
                    },
                    "required": ["city"]
                }
                """;

        // Tool definition. 0.x used `new McpSchema.Tool(name, description,
        // schemaString)`; 2.0 uses a builder, and the schema is stored as a
        // Map<String, Object> internally (the mapper parses our string).
        McpSchema.Tool weatherTool = McpSchema.Tool.builder("get_weather", JSON_MAPPER, inputSchema)
                .description("Get current weather information for a specified city. "
                        + "Returns temperature data for the requested location.")
                .build();

        // Tool spec = definition + handler. The handler is a BiFunction:
        //   (exchange, request) -> result
        // "exchange" is the per-session channel back to the client (used for
        // logging notifications, sampling, etc. — not needed here).
        // "request" is a typed CallToolRequest, replacing 0.x's raw Map.
        return McpServerFeatures.SyncToolSpecification.builder()
                .tool(weatherTool)
                .callHandler((exchange, request) -> {
                    // Arguments arrive already schema-validated, so "city" is
                    // guaranteed present and of type string.
                    String city = ((String) request.arguments().get("city")).trim();
                    System.err.println("Processing weather request for city: " + city);

                    String weatherReport = getWeatherData(city);

                    // 0.x: new CallToolResult(contents, false)
                    // 2.0: builder, with addTextContent as a shortcut for
                    //      wrapping a string in a TextContent block.
                    return McpSchema.CallToolResult.builder()
                            .addTextContent(weatherReport)
                            .build();
                })
                .build();
    }

    /**
     * Builds the prompt specifications offered by this server.
     *
     * <p>Prompts are user-facing templates: the client lists them in its UI
     * (e.g. the "+" menu in Claude Desktop), the user picks one and fills in
     * its arguments, and the server expands it into one or more chat messages.
     * Unlike tools (model-invoked), prompts are human-invoked.</p>
     *
     * <p>Like tools, each specification pairs a <b>definition</b> (name,
     * description, argument list) with a <b>handler</b> that produces the
     * final messages from the supplied arguments.</p>
     *
     * @return the prompt specifications, ready to register on the server
     */
    private static List<McpServerFeatures.SyncPromptSpecification> createWeatherPromptSpecifications() {

        // --- Prompt 1: weather_inquiry -----------------------------------
        // A single required argument, "location".
        McpSchema.Prompt inquiryPrompt = McpSchema.Prompt.builder("weather_inquiry")
                .description("Template for asking about weather conditions in a specific location")
                .arguments(List.of(
                        McpSchema.PromptArgument.builder("location")
                                .description("The city or location to inquire about")
                                .required(true)
                                .build()))
                .build();

        McpServerFeatures.SyncPromptSpecification inquirySpec =
                new McpServerFeatures.SyncPromptSpecification(
                        inquiryPrompt,
                        (exchange, request) -> {
                            Map<String, Object> promptArgs = request.arguments();
                            String location = String.valueOf(promptArgs.get("location"));

                            String promptText = String.format(
                                    "I need current weather information for %s. "
                                            + "Please provide the temperature and any relevant weather conditions. "
                                            + "If you need to use a tool to get this information, please do so.",
                                    location);

                            // A prompt expands to a list of chat messages; here
                            // just one user-role text message.
                            return McpSchema.GetPromptResult.builder(List.of(
                                            new McpSchema.PromptMessage(
                                                    McpSchema.Role.USER,
                                                    McpSchema.TextContent.builder(promptText).build())))
                                    .description("Weather Inquiry for " + location)
                                    .build();
                        });

        // --- Prompt 2: weather_travel_advice ------------------------------
        // A required "destination" plus an optional "travel_date".
        McpSchema.Prompt travelPrompt = McpSchema.Prompt.builder("weather_travel_advice")
                .description("Template for getting weather-based travel advice for a destination")
                .arguments(List.of(
                        McpSchema.PromptArgument.builder("destination")
                                .description("Travel destination city")
                                .required(true)
                                .build(),
                        McpSchema.PromptArgument.builder("travel_date")
                                .description("Planned travel date (optional)")
                                .required(false)
                                .build()))
                .build();

        McpServerFeatures.SyncPromptSpecification travelSpec =
                new McpServerFeatures.SyncPromptSpecification(
                        travelPrompt,
                        (exchange, request) -> {
                            Map<String, Object> promptArgs = request.arguments();
                            String destination = String.valueOf(promptArgs.get("destination"));
                            Object travelDate = promptArgs.get("travel_date");

                            // Optional arguments may simply be absent from the map.
                            String dateInfo = (travelDate != null)
                                    ? " for travel on " + travelDate
                                    : " for current conditions";

                            String promptText = String.format(
                                    "I'm planning to travel to %s%s. "
                                            + "Please check the current weather conditions and provide advice on "
                                            + "what to pack and any weather-related considerations for my trip. "
                                            + "Use the weather tool to get current temperature data.",
                                    destination, dateInfo);

                            return McpSchema.GetPromptResult.builder(List.of(
                                            new McpSchema.PromptMessage(
                                                    McpSchema.Role.USER,
                                                    McpSchema.TextContent.builder(promptText).build())))
                                    .description("Travel Weather Advice for " + destination)
                                    .build();
                        });

        return List.of(inquirySpec, travelSpec);
    }

    /**
     * Produces the weather report for a city.
     *
     * <p>Currently returns hardcoded sample data so the course can focus on
     * the MCP mechanics. Swapping in a real weather API only changes this one
     * method — the protocol plumbing above stays identical.</p>
     *
     * @param city the city to report on (already validated by the SDK)
     * @return a human-readable, plain-text weather report
     */
    private static String getWeatherData(String city) {
        String timestamp = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        String weatherReport = String.format("""
                Weather Report for %s
                ========================
                Current Temperature: 44F
                Conditions: Clear
                Humidity: 65%%
                Wind: Light breeze
                Last Updated: %s

                Note: This is sample data. Weather API integration coming soon!""",
                city,
                timestamp);

        System.err.println("Returning weather data for " + city);
        return weatherReport;
    }
}
