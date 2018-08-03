//
//  Session.swift
//  Hop iOS
//
//  Created by poisson florent on 27/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

public enum SessionError: ErrorType {
    
    case fileError
    
    public func getDescription() -> String {
        switch self {
        case .fileError:
            return "File Error"
        }
    }

}

public class Session {

    // External environment properties
    // -------------------------------

    // Debug mode activation
    public let isDebug: Bool

    // Messenger used to propagate interpreter message outside
    let messenger: Messenger?

    let searchPaths: [URL]?         // Directory search paths for packages & modules
    private(set) var runPath: URL?  // Directory path of the main module run by the session

    // Internal environment properties
    // -------------------------------

    // Global scope used to:
    // - store global class like Array, Dictionary, ...
    // - store imported modules
    let globalScope: Scope = getInitializedGlobalScope()

    public init(isDebug: Bool,
                messenger: Messenger?,
                searchPaths: [URL]?) {

        self.isDebug = isDebug
        self.messenger = messenger
        self.searchPaths = searchPaths
    }

    // MARK: - State management

    private static func getInitializedGlobalScope() -> Scope {
        let globalScope = Scope(parent: nil)

        // Inject array class
        // ...

        // Inject dictionary class
        // ...

        return globalScope
    }

    public func run(script: String) throws {
        let lexer = Lexer(script: script, isDebug: self.isDebug)
        let parser = Parser(with: lexer, isDebug: self.isDebug)
        if let program = try parser.parseProgram() {
            try program.perform(with: self)
        }
    }
    
    public func runScript(at url: URL) throws {
        guard let script = Session.getScript(at: url) else {
            throw ProgramError(errorType: SessionError.fileError,
                               debugInfo: nil)
        }
        
        self.runPath = url.deletingLastPathComponent()
        
        try run(script: script)
    }

}

// MARK: - Package & module search management
extension Session {
    
    static func getModule(for path: String, in directories: [URL]) -> [String: String]? {
        let pathComponents = path.components(separatedBy: ".")
        
        for directory in directories {
            if let modules = getModule(for: pathComponents,
                                       pathComponentIndex: 0,
                                       directory: directory) {
                return modules
            }
        }
        
        return nil
    }
    
    private static func getModule(for pathComponents: [String],
                                  pathComponentIndex: Int,
                                  directory: URL) -> [String: String]? {
        do {
            let directoryContents = try FileManager
                .default
                .contentsOfDirectory(at: directory,
                                     includingPropertiesForKeys: nil,
                                     options: .skipsHiddenFiles)
            let pathComponentsCount = pathComponents.count
            
            for directoryContent in directoryContents {
                let lastComponent = directoryContent.deletingPathExtension().lastPathComponent
                if lastComponent == pathComponents[pathComponentIndex] {
                    var isDirectory: ObjCBool = false
                    if FileManager.default.fileExists(atPath: directoryContent.path,
                                                      isDirectory: &isDirectory) {
                        if isDirectory.boolValue {
                            if pathComponentIndex < pathComponentsCount - 1 {
                                // Go deeper!
                                return getModule(for: pathComponents,
                                                 pathComponentIndex: pathComponentIndex + 1,
                                                 directory: directoryContent)
                            } else { // Last path component
                                // Return all modules in targeted package
                                
                                let moduleUrls = try FileManager
                                    .default
                                    .contentsOfDirectory(at: directoryContent,
                                                         includingPropertiesForKeys: nil,
                                                         options: .skipsHiddenFiles)
                                    .filter { (url) -> Bool in
                                        return (url.pathExtension.lowercased() == "hop")
                                }
                                
                                var modules = [String: String]()
                                let package = pathComponents.joined(separator: ".")
                                
                                for moduleUrl in moduleUrls {
                                    if let script = getScript(at: moduleUrl) {
                                        let lastPathComponent = moduleUrl
                                            .deletingPathExtension()
                                            .lastPathComponent
                                        modules[package + "." + lastPathComponent] = script
                                    }
                                }
                                
                                if modules.count > 0 { return modules }
                                
                                return nil
                            }
                        } else if pathComponentIndex >= pathComponentsCount - 1,
                            directoryContent.pathExtension.lowercased() == "hop" { // Last path component
                            // Return targeted module
                            
                            guard let script = getScript(at: directoryContent) else {
                                return nil
                            }
                            
                            return [pathComponents.joined(separator: "."): script]
                        }
                    }
                }
            }
        } catch let error {
            print("Error: failed to get directory contents, with error = \(error.localizedDescription)")
        }
        
        return nil
    }
    
    public static func getScript(at url: URL) -> String? {
        var isDirectory: ObjCBool = false
        
        if FileManager
            .default
            .fileExists(atPath: url.path,
                        isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                do {
                    return try String(contentsOf: url,
                                      encoding: .utf8)
                } catch let error {
                    print("Error: failed to load script from \(url.path), with error: \(error.localizedDescription)")
                }
            } else {
                print("Error: url target is not a file!")
            }
        } else {
            print("Error: module file does not exists at url: \(url)!")
        }
        
        return nil
    }
    
}
