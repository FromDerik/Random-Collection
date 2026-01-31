import Vapor

/// CORS Middleware for Stremio addon compatibility
struct CORSMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        // Handle preflight OPTIONS requests
        if request.method == .OPTIONS {
            var response = Response(status: .ok)
            addCORSHeaders(to: &response)
            return response
        }
        
        var response = try await next.respond(to: request)
        
        // Add CORS headers to all responses
        addCORSHeaders(to: &response)
        
        return response
    }
    
    private func addCORSHeaders(to response: inout Response) {
        response.headers.add(name: .accessControlAllowOrigin, value: "*")
        response.headers.add(name: .accessControlAllowMethods, value: "GET, POST, PUT, DELETE, OPTIONS, PATCH")
        response.headers.add(name: .accessControlAllowHeaders, value: "Accept, Authorization, Content-Type, Origin, X-Requested-With, User-Agent")
        response.headers.add(name: .accessControlAllowCredentials, value: "true")
    }
}

